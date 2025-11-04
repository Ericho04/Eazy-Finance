-- =============================================
-- Easy Finance - Production Database Schema
-- Malaysia Personal Finance App
-- =============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================
-- USERS
-- =============================================
CREATE TABLE app_user (
  id UUID PRIMARY KEY DEFAULT auth.uid(),
  email TEXT UNIQUE,
  full_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- CATEGORIES
-- =============================================
CREATE TABLE category (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('expense','income')),
  icon TEXT,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- TRANSACTIONS
-- =============================================
CREATE TABLE txn (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  category_id UUID REFERENCES category(id) ON DELETE SET NULL,
  amount NUMERIC(12,2) NOT NULL,
  direction TEXT NOT NULL CHECK (direction IN ('inflow','outflow')),
  occurred_on DATE NOT NULL,
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- MONTHLY BUDGET
-- =============================================
CREATE TABLE budget (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  year INT NOT NULL,
  month INT NOT NULL CHECK (month BETWEEN 1 AND 12),
  monthly_income NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, year, month)
);

-- =============================================
-- BUDGET CAPS PER CATEGORY
-- =============================================
CREATE TABLE budget_cap (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  budget_id UUID NOT NULL REFERENCES budget(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES category(id) ON DELETE CASCADE,
  planned_amount NUMERIC(12,2) NOT NULL,
  dynamic_amount NUMERIC(12,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(budget_id, category_id)
);

-- =============================================
-- GOALS + CONTRIBUTIONS
-- =============================================
CREATE TABLE goal (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  target_amount NUMERIC(12,2) NOT NULL,
  deadline DATE,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','completed','archived')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE goal_contribution (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_id UUID NOT NULL REFERENCES goal(id) ON DELETE CASCADE,
  amount NUMERIC(12,2) NOT NULL,
  contributed_on DATE NOT NULL DEFAULT (NOW()::DATE),
  note TEXT
);

-- =============================================
-- LUCKY DRAW
-- =============================================
CREATE TABLE reward (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE lucky_draw_entry (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  goal_id UUID REFERENCES goal(id) ON DELETE SET NULL,
  awarded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  outcome TEXT
);

-- =============================================
-- DEBTS & PAYMENTS
-- =============================================
CREATE TABLE debt (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  principal NUMERIC(14,2) NOT NULL,
  apr NUMERIC(6,3) NOT NULL,
  term_months INT NOT NULL,
  due_day INT CHECK (due_day BETWEEN 1 AND 28),
  start_date DATE NOT NULL,
  extra_monthly_payment NUMERIC(12,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE debt_payment (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  debt_id UUID NOT NULL REFERENCES debt(id) ON DELETE CASCADE,
  amount NUMERIC(12,2) NOT NULL,
  paid_on DATE NOT NULL,
  note TEXT
);

-- =============================================
-- REMINDERS
-- =============================================
CREATE TABLE reminder (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('debt_due')),
  entity_id UUID,
  due_at TIMESTAMPTZ NOT NULL,
  lead_days INT DEFAULT 3,
  status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled','sent','read','snoozed','cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- TAX
-- =============================================
CREATE TABLE tax_profile (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  assessment_year INT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, assessment_year)
);

CREATE TABLE tax_relief_category (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL,
  label TEXT NOT NULL,
  annual_limit NUMERIC(12,2) NOT NULL
);

CREATE TABLE tax_claim (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tax_profile_id UUID NOT NULL REFERENCES tax_profile(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES tax_relief_category(id) ON DELETE RESTRICT,
  amount NUMERIC(12,2) NOT NULL,
  claimed_on DATE NOT NULL DEFAULT (NOW()::DATE),
  note TEXT
);

-- =============================================
-- SNAPSHOTS FOR SUGGESTIONS
-- =============================================
CREATE TABLE suggestion_snapshot (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  month_start DATE NOT NULL,
  data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, month_start)
);

-- =============================================
-- PERFORMANCE INDEXES
-- =============================================

-- Transaction indexes
CREATE INDEX idx_txn_user_occurred ON txn(user_id, occurred_on DESC);
CREATE INDEX idx_txn_category ON txn(category_id);

-- Budget indexes
CREATE INDEX idx_budget_user_period ON budget(user_id, year, month);
CREATE INDEX idx_budget_cap_budget ON budget_cap(budget_id, category_id);

-- Goal indexes
CREATE INDEX idx_goal_user ON goal(user_id);
CREATE INDEX idx_goal_contribution_goal ON goal_contribution(goal_id);

-- Debt indexes
CREATE INDEX idx_debt_user ON debt(user_id);
CREATE INDEX idx_debt_payment_debt_date ON debt_payment(debt_id, paid_on);

-- Reminder indexes
CREATE INDEX idx_reminder_user_due ON reminder(user_id, due_at);

-- Tax indexes
CREATE INDEX idx_tax_claim_profile_category ON tax_claim(tax_profile_id, category_id, claimed_on);

-- Category indexes
CREATE INDEX idx_category_user ON category(user_id);

-- =============================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================

-- Enable RLS on all tables
ALTER TABLE app_user ENABLE ROW LEVEL SECURITY;
ALTER TABLE category ENABLE ROW LEVEL SECURITY;
ALTER TABLE txn ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget_cap ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal_contribution ENABLE ROW LEVEL SECURITY;
ALTER TABLE reward ENABLE ROW LEVEL SECURITY;
ALTER TABLE lucky_draw_entry ENABLE ROW LEVEL SECURITY;
ALTER TABLE debt ENABLE ROW LEVEL SECURITY;
ALTER TABLE debt_payment ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminder ENABLE ROW LEVEL SECURITY;
ALTER TABLE tax_profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE tax_relief_category ENABLE ROW LEVEL SECURITY;
ALTER TABLE tax_claim ENABLE ROW LEVEL SECURITY;
ALTER TABLE suggestion_snapshot ENABLE ROW LEVEL SECURITY;

-- app_user policies
CREATE POLICY "Users can select self" ON app_user FOR SELECT USING (id = auth.uid());
CREATE POLICY "Users can insert self" ON app_user FOR INSERT WITH CHECK (id = auth.uid());
CREATE POLICY "Users can update self" ON app_user FOR UPDATE USING (id = auth.uid());

-- category policies
CREATE POLICY "Users manage own categories" ON category FOR ALL USING (user_id = auth.uid());

-- txn policies
CREATE POLICY "Users manage own transactions" ON txn FOR ALL USING (user_id = auth.uid());

-- budget policies
CREATE POLICY "Users manage own budgets" ON budget FOR ALL USING (user_id = auth.uid());

-- budget_cap policies
CREATE POLICY "Users manage own budget caps" ON budget_cap FOR ALL USING (
  EXISTS (SELECT 1 FROM budget WHERE budget.id = budget_cap.budget_id AND budget.user_id = auth.uid())
);

-- goal policies
CREATE POLICY "Users manage own goals" ON goal FOR ALL USING (user_id = auth.uid());

-- goal_contribution policies
CREATE POLICY "Users manage own goal contributions" ON goal_contribution FOR ALL USING (
  EXISTS (SELECT 1 FROM goal WHERE goal.id = goal_contribution.goal_id AND goal.user_id = auth.uid())
);

-- reward policies
CREATE POLICY "Users manage own rewards" ON reward FOR ALL USING (user_id = auth.uid());

-- lucky_draw_entry policies
CREATE POLICY "Users manage own lucky draw entries" ON lucky_draw_entry FOR ALL USING (user_id = auth.uid());

-- debt policies
CREATE POLICY "Users manage own debts" ON debt FOR ALL USING (user_id = auth.uid());

-- debt_payment policies
CREATE POLICY "Users manage own debt payments" ON debt_payment FOR ALL USING (
  EXISTS (SELECT 1 FROM debt WHERE debt.id = debt_payment.debt_id AND debt.user_id = auth.uid())
);

-- reminder policies
CREATE POLICY "Users manage own reminders" ON reminder FOR ALL USING (user_id = auth.uid());

-- tax_profile policies
CREATE POLICY "Users manage own tax profiles" ON tax_profile FOR ALL USING (user_id = auth.uid());

-- tax_relief_category policies (public read for all authenticated users)
CREATE POLICY "Authenticated users can read tax relief categories" ON tax_relief_category FOR SELECT TO authenticated USING (TRUE);

-- tax_claim policies
CREATE POLICY "Users manage own tax claims" ON tax_claim FOR ALL USING (
  EXISTS (SELECT 1 FROM tax_profile WHERE tax_profile.id = tax_claim.tax_profile_id AND tax_profile.user_id = auth.uid())
);

-- suggestion_snapshot policies
CREATE POLICY "Users manage own suggestion snapshots" ON suggestion_snapshot FOR ALL USING (user_id = auth.uid());

-- =============================================
-- TRIGGERS AND FUNCTIONS
-- =============================================

-- Function to automatically create user profile after signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.app_user (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to automatically create user profile
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update goal status on contribution
CREATE OR REPLACE FUNCTION update_goal_on_contribution()
RETURNS TRIGGER AS $$
DECLARE
  total_contributed NUMERIC(12,2);
  goal_target NUMERIC(12,2);
  goal_current_status TEXT;
BEGIN
  -- Calculate total contributions for this goal
  SELECT COALESCE(SUM(amount), 0) INTO total_contributed
  FROM goal_contribution
  WHERE goal_id = NEW.goal_id;

  -- Get goal target and status
  SELECT target_amount, status INTO goal_target, goal_current_status
  FROM goal
  WHERE id = NEW.goal_id;

  -- If goal is completed and was previously 'active', create lucky draw entry
  IF total_contributed >= goal_target AND goal_current_status = 'active' THEN
    UPDATE goal
    SET status = 'completed'
    WHERE id = NEW.goal_id;

    -- Award lucky draw entry
    INSERT INTO lucky_draw_entry (user_id, goal_id)
    SELECT user_id, id
    FROM goal
    WHERE id = NEW.goal_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_goal_on_contribution ON goal_contribution;
CREATE TRIGGER trigger_update_goal_on_contribution
  AFTER INSERT OR UPDATE ON goal_contribution
  FOR EACH ROW
  EXECUTE FUNCTION update_goal_on_contribution();

-- Function to recalculate budget caps dynamically on transaction insert/update
CREATE OR REPLACE FUNCTION recalculate_budget_caps()
RETURNS TRIGGER AS $$
DECLARE
  current_month_start DATE;
  current_month_end DATE;
  days_in_month INT;
  days_remaining INT;
  current_budget_id UUID;
BEGIN
  -- Get current month boundaries
  current_month_start := DATE_TRUNC('month', NEW.occurred_on)::DATE;
  current_month_end := (DATE_TRUNC('month', NEW.occurred_on) + INTERVAL '1 month - 1 day')::DATE;
  days_in_month := EXTRACT(DAY FROM current_month_end);
  days_remaining := EXTRACT(DAY FROM (current_month_end - CURRENT_DATE)) + 1;

  -- Get budget for this user and month
  SELECT id INTO current_budget_id
  FROM budget
  WHERE user_id = NEW.user_id
    AND year = EXTRACT(YEAR FROM NEW.occurred_on)
    AND month = EXTRACT(MONTH FROM NEW.occurred_on);

  -- Update dynamic_amount for all budget caps (prorated based on remaining days)
  IF current_budget_id IS NOT NULL AND days_remaining > 0 THEN
    UPDATE budget_cap
    SET dynamic_amount = planned_amount * (days_remaining::NUMERIC / days_in_month::NUMERIC)
    WHERE budget_id = current_budget_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_recalc_budget_caps ON txn;
CREATE TRIGGER trigger_recalc_budget_caps
  AFTER INSERT OR UPDATE ON txn
  FOR EACH ROW
  EXECUTE FUNCTION recalculate_budget_caps();

-- =============================================
-- SEED DATA - Malaysian Tax Relief Categories
-- =============================================

INSERT INTO tax_relief_category (code, label, annual_limit) VALUES
  ('SELF', 'Individual Relief', 9000.00),
  ('SPOUSE', 'Spouse Relief', 4000.00),
  ('CHILD', 'Child Relief (per child)', 2000.00),
  ('DISABLED_CHILD', 'Disabled Child Relief (per child)', 6000.00),
  ('EPF', 'EPF/KWSP Contributions', 4000.00),
  ('LIFE_INSURANCE', 'Life Insurance & EPF', 7000.00),
  ('EDUCATION_INSURANCE', 'Education & Medical Insurance', 3000.00),
  ('SSPN', 'SSPN (National Education Savings)', 8000.00),
  ('MEDICAL_PARENTS', 'Medical Expenses for Parents', 8000.00),
  ('MEDICAL_SELF', 'Medical Expenses (Serious Diseases)', 8000.00),
  ('DISABLED_SELF', 'Disabled Individual', 6000.00),
  ('DISABLED_EQUIPMENT', 'Disabled Person Supporting Equipment', 6000.00),
  ('BOOKS', 'Purchase of Books, Journals, Magazines', 1000.00),
  ('SPORT_EQUIPMENT', 'Purchase of Sports Equipment', 500.00),
  ('BROADBAND', 'Subscription of Broadband', 1000.00),
  ('SMARTPHONE', 'Purchase of Smartphone, Tablet, PC', 2500.00),
  ('CHILDCARE', 'Childcare Fees', 3000.00),
  ('PARENTS', 'Parents (aged 60 and above)', 1500.00),
  ('PARENTS_MEDICAL', 'Medical Expenses for Parents', 5000.00),
  ('EV_CHARGING', 'EV Charging Facilities', 2500.00),
  ('DOMESTIC_TOURISM', 'Domestic Tourism', 1000.00)
ON CONFLICT DO NOTHING;

-- =============================================
-- HELPER VIEWS
-- =============================================

-- Monthly transaction summary
CREATE OR REPLACE VIEW v_monthly_txn_summary AS
SELECT
  user_id,
  DATE_TRUNC('month', occurred_on)::DATE AS month_start,
  category_id,
  direction,
  COUNT(*) AS txn_count,
  SUM(amount) AS total_amount
FROM txn
GROUP BY user_id, DATE_TRUNC('month', occurred_on)::DATE, category_id, direction;

-- Budget utilization view
CREATE OR REPLACE VIEW v_budget_utilization AS
SELECT
  b.id AS budget_id,
  b.user_id,
  b.year,
  b.month,
  b.monthly_income,
  bc.id AS budget_cap_id,
  bc.category_id,
  c.name AS category_name,
  bc.planned_amount,
  bc.dynamic_amount,
  COALESCE(spent.total, 0) AS spent_amount,
  CASE
    WHEN bc.planned_amount > 0 THEN (COALESCE(spent.total, 0) / bc.planned_amount * 100)
    ELSE 0
  END AS utilization_percentage
FROM budget b
JOIN budget_cap bc ON bc.budget_id = b.id
LEFT JOIN category c ON c.id = bc.category_id
LEFT JOIN (
  SELECT
    t.category_id,
    DATE_PART('year', t.occurred_on) AS year,
    DATE_PART('month', t.occurred_on) AS month,
    t.user_id,
    SUM(t.amount) AS total
  FROM txn t
  WHERE t.direction = 'outflow'
  GROUP BY t.category_id, DATE_PART('year', t.occurred_on), DATE_PART('month', t.occurred_on), t.user_id
) spent ON spent.category_id = bc.category_id
  AND spent.year = b.year
  AND spent.month = b.month
  AND spent.user_id = b.user_id;

-- Goal progress view
CREATE OR REPLACE VIEW v_goal_progress AS
SELECT
  g.id,
  g.user_id,
  g.title,
  g.target_amount,
  g.deadline,
  g.status,
  COALESCE(SUM(gc.amount), 0) AS contributed_amount,
  g.target_amount - COALESCE(SUM(gc.amount), 0) AS remaining_amount,
  CASE
    WHEN g.target_amount > 0 THEN (COALESCE(SUM(gc.amount), 0) / g.target_amount * 100)
    ELSE 0
  END AS progress_percentage
FROM goal g
LEFT JOIN goal_contribution gc ON gc.goal_id = g.id
GROUP BY g.id, g.user_id, g.title, g.target_amount, g.deadline, g.status;

-- Grant view permissions
GRANT SELECT ON v_monthly_txn_summary TO authenticated;
GRANT SELECT ON v_budget_utilization TO authenticated;
GRANT SELECT ON v_goal_progress TO authenticated;

-- =============================================
-- COMMENTS
-- =============================================

COMMENT ON TABLE app_user IS 'User profiles for the application';
COMMENT ON TABLE category IS 'Transaction categories (income and expense)';
COMMENT ON TABLE txn IS 'Financial transactions (inflow and outflow)';
COMMENT ON TABLE budget IS 'Monthly budgets based on user income';
COMMENT ON TABLE budget_cap IS 'Category-wise spending caps within a budget';
COMMENT ON TABLE goal IS 'Financial goals with target amounts and deadlines';
COMMENT ON TABLE goal_contribution IS 'Contributions made towards goals';
COMMENT ON TABLE reward IS 'Rewards available in the lucky draw system';
COMMENT ON TABLE lucky_draw_entry IS 'Lucky draw entries earned from goal completion';
COMMENT ON TABLE debt IS 'Debt tracking with amortization parameters';
COMMENT ON TABLE debt_payment IS 'Payments made towards debts';
COMMENT ON TABLE reminder IS 'Reminders for debt due dates and other events';
COMMENT ON TABLE tax_profile IS 'Tax profiles per user per assessment year';
COMMENT ON TABLE tax_relief_category IS 'Malaysian tax relief categories with limits';
COMMENT ON TABLE tax_claim IS 'Tax relief claims made by users';
COMMENT ON TABLE suggestion_snapshot IS 'Monthly snapshots for spending suggestions and insights';
