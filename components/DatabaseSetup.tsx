import { motion } from 'motion/react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Database, CheckCircle, ExternalLink, Copy, Play, RefreshCw, AlertCircle } from 'lucide-react';
import { useState } from 'react';
import { toast } from 'sonner';
import { supabase } from '../lib/supabase';

interface DatabaseSetupProps {
  onSetupComplete: () => void;
}

export function DatabaseSetup({ onSetupComplete }: DatabaseSetupProps) {
  const [currentStep, setCurrentStep] = useState(1);
  const [isTestingConnection, setIsTestingConnection] = useState(false);
  const [copiedSQL, setCopiedSQL] = useState(false);

  // Complete SQL migration script
  const migrationSQL = `-- =============================================
-- Smart Finance Management System (SFMS)
-- Initial Database Migration
-- =============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- 1. USER PROFILES TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    full_name TEXT,
    email TEXT UNIQUE,
    avatar_url TEXT,
    language VARCHAR(2) DEFAULT 'en',
    currency VARCHAR(3) DEFAULT 'MYR',
    timezone TEXT DEFAULT 'Asia/Kuala_Lumpur',
    reward_points INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- =============================================
-- 2. TRANSACTIONS TABLE
-- =============================================
CREATE TYPE IF NOT EXISTS transaction_type AS ENUM ('income', 'expense');
CREATE TYPE IF NOT EXISTS transaction_source AS ENUM ('manual', 'ocr', 'bank', 'api');

CREATE TABLE IF NOT EXISTS transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    category TEXT NOT NULL,
    description TEXT NOT NULL,
    transaction_date DATE NOT NULL,
    type transaction_type NOT NULL,
    source transaction_source DEFAULT 'manual',
    receipt_url TEXT,
    tags TEXT[],
    location TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- =============================================
-- 3. BUDGETS TABLE
-- =============================================
CREATE TYPE IF NOT EXISTS budget_period AS ENUM ('daily', 'weekly', 'monthly', 'quarterly', 'yearly', 'custom');
CREATE TYPE IF NOT EXISTS budget_status AS ENUM ('active', 'paused', 'completed', 'cancelled');

CREATE TABLE IF NOT EXISTS budgets (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    category TEXT NOT NULL,
    amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    spent DECIMAL(12,2) DEFAULT 0.00 CHECK (spent >= 0),
    period budget_period NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status budget_status DEFAULT 'active',
    is_active BOOLEAN DEFAULT TRUE,
    tags TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    
    CONSTRAINT valid_date_range CHECK (end_date >= start_date)
);

-- =============================================
-- 4. GOALS TABLE
-- =============================================
CREATE TYPE IF NOT EXISTS goal_priority AS ENUM ('low', 'medium', 'high');

CREATE TABLE IF NOT EXISTS goals (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    target_amount DECIMAL(12,2) NOT NULL CHECK (target_amount > 0),
    current_amount DECIMAL(12,2) DEFAULT 0.00 CHECK (current_amount >= 0),
    deadline DATE NOT NULL,
    category TEXT NOT NULL,
    priority goal_priority DEFAULT 'medium',
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    points_reward INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    
    CONSTRAINT valid_amounts CHECK (current_amount <= target_amount OR is_completed = TRUE)
);

-- =============================================
-- 5. FINANCIAL ACCOUNTS TABLE
-- =============================================
CREATE TYPE IF NOT EXISTS account_type AS ENUM ('savings', 'checking', 'fixed_deposit', 'investment', 'retirement', 'business', 'e_wallet', 'credit_card');

CREATE TABLE IF NOT EXISTS financial_accounts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    account_name TEXT NOT NULL,
    account_number TEXT,
    account_type account_type NOT NULL,
    bank_name TEXT NOT NULL,
    current_balance DECIMAL(12,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'MYR',
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- =============================================
-- 6. FINANCIAL DEBTS TABLE
-- =============================================
CREATE TYPE IF NOT EXISTS debt_type AS ENUM ('credit_card', 'personal_loan', 'car_loan', 'home_loan', 'student_loan', 'business_loan', 'other');

CREATE TABLE IF NOT EXISTS financial_debts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    debt_name TEXT NOT NULL,
    debt_type debt_type NOT NULL,
    original_amount DECIMAL(12,2) NOT NULL CHECK (original_amount > 0),
    current_balance DECIMAL(12,2) NOT NULL CHECK (current_balance >= 0),
    interest_rate DECIMAL(5,2) DEFAULT 0.00 CHECK (interest_rate >= 0),
    minimum_payment DECIMAL(12,2) DEFAULT 0.00 CHECK (minimum_payment >= 0),
    due_date DATE,
    creditor_name TEXT NOT NULL,
    last_payment_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    
    CONSTRAINT valid_debt_amounts CHECK (current_balance <= original_amount)
);

-- =============================================
-- 7. TAX PLANNING TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS tax_planning (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    tax_year VARCHAR(4) NOT NULL,
    annual_income DECIMAL(12,2) DEFAULT 0.00 CHECK (annual_income >= 0),
    estimated_tax DECIMAL(12,2) DEFAULT 0.00 CHECK (estimated_tax >= 0),
    total_deductions DECIMAL(12,2) DEFAULT 0.00 CHECK (total_deductions >= 0),
    taxable_income DECIMAL(12,2) DEFAULT 0.00 CHECK (taxable_income >= 0),
    effective_rate DECIMAL(5,2) DEFAULT 0.00 CHECK (effective_rate >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    
    UNIQUE(user_id, tax_year)
);

-- =============================================
-- 8. TAX DEDUCTIONS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS tax_deductions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    tax_planning_id UUID REFERENCES tax_planning(id) ON DELETE CASCADE,
    category TEXT NOT NULL,
    description TEXT,
    amount DECIMAL(12,2) DEFAULT 0.00 CHECK (amount >= 0),
    max_amount DECIMAL(12,2) DEFAULT 0.00 CHECK (max_amount >= 0),
    is_claimable BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    
    CONSTRAINT valid_deduction_amount CHECK (amount <= max_amount OR max_amount = 0)
);

-- =============================================
-- 9. INSIGHTS TABLE
-- =============================================
CREATE TYPE IF NOT EXISTS insight_type AS ENUM ('trend', 'prediction', 'comparison', 'alert', 'recommendation', 'achievement', 'summary');
CREATE TYPE IF NOT EXISTS insight_category AS ENUM ('spending', 'income', 'budget', 'goals', 'savings', 'debt', 'investment', 'tax', 'cashflow', 'general');

CREATE TABLE IF NOT EXISTS insights (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    type insight_type NOT NULL,
    category insight_category NOT NULL,
    data JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- =============================================
-- 10. GOAL CONTRIBUTIONS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS goal_contributions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    goal_id UUID REFERENCES goals(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    contribution_date DATE NOT NULL DEFAULT CURRENT_DATE,
    source TEXT DEFAULT 'manual',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- =============================================
-- 11. DEBT PAYMENTS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS debt_payments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    debt_id UUID REFERENCES financial_debts(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_method TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- =============================================
-- 12. ALERTS TABLE
-- =============================================
CREATE TYPE IF NOT EXISTS alert_type AS ENUM ('budget_exceeded', 'budget_warning', 'goal_reminder', 'debt_due', 'low_balance');
CREATE TYPE IF NOT EXISTS alert_status AS ENUM ('pending', 'read', 'dismissed');

CREATE TABLE IF NOT EXISTS alerts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type alert_type NOT NULL,
    status alert_status DEFAULT 'pending',
    related_id UUID,
    data JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    read_at TIMESTAMP WITH TIME ZONE
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- Transactions indexes
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(transaction_date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category);
CREATE INDEX IF NOT EXISTS idx_transactions_user_date ON transactions(user_id, transaction_date DESC);

-- Budgets indexes
CREATE INDEX IF NOT EXISTS idx_budgets_user_id ON budgets(user_id);
CREATE INDEX IF NOT EXISTS idx_budgets_period ON budgets(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_budgets_status ON budgets(status);
CREATE INDEX IF NOT EXISTS idx_budgets_active ON budgets(user_id, is_active);

-- Goals indexes
CREATE INDEX IF NOT EXISTS idx_goals_user_id ON goals(user_id);
CREATE INDEX IF NOT EXISTS idx_goals_deadline ON goals(deadline);
CREATE INDEX IF NOT EXISTS idx_goals_completed ON goals(is_completed);
CREATE INDEX IF NOT EXISTS idx_goals_user_active ON goals(user_id, is_completed);

-- Financial accounts indexes
CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON financial_accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_accounts_type ON financial_accounts(account_type);
CREATE INDEX IF NOT EXISTS idx_accounts_active ON financial_accounts(user_id, is_active);

-- Financial debts indexes
CREATE INDEX IF NOT EXISTS idx_debts_user_id ON financial_debts(user_id);
CREATE INDEX IF NOT EXISTS idx_debts_type ON financial_debts(debt_type);
CREATE INDEX IF NOT EXISTS idx_debts_due_date ON financial_debts(due_date);
CREATE INDEX IF NOT EXISTS idx_debts_active ON financial_debts(user_id, is_active);

-- Insights indexes
CREATE INDEX IF NOT EXISTS idx_insights_user_id ON insights(user_id);
CREATE INDEX IF NOT EXISTS idx_insights_type ON insights(type);
CREATE INDEX IF NOT EXISTS idx_insights_category ON insights(category);
CREATE INDEX IF NOT EXISTS idx_insights_active ON insights(user_id, is_active);

-- Alerts indexes
CREATE INDEX IF NOT EXISTS idx_alerts_user_id ON alerts(user_id);
CREATE INDEX IF NOT EXISTS idx_alerts_status ON alerts(status);
CREATE INDEX IF NOT EXISTS idx_alerts_type ON alerts(type);
CREATE INDEX IF NOT EXISTS idx_alerts_user_status ON alerts(user_id, status);

-- =============================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================

-- Enable RLS on all tables
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_debts ENABLE ROW LEVEL SECURITY;
ALTER TABLE tax_planning ENABLE ROW LEVEL SECURITY;
ALTER TABLE tax_deductions ENABLE ROW LEVEL SECURITY;
ALTER TABLE insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal_contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE debt_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;

-- User profiles policies
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;

CREATE POLICY "Users can view own profile" ON user_profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON user_profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON user_profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Transactions policies
DROP POLICY IF EXISTS "Users can manage own transactions" ON transactions;
CREATE POLICY "Users can manage own transactions" ON transactions FOR ALL USING (auth.uid() = user_id);

-- Budgets policies
DROP POLICY IF EXISTS "Users can manage own budgets" ON budgets;
CREATE POLICY "Users can manage own budgets" ON budgets FOR ALL USING (auth.uid() = user_id);

-- Goals policies
DROP POLICY IF EXISTS "Users can manage own goals" ON goals;
CREATE POLICY "Users can manage own goals" ON goals FOR ALL USING (auth.uid() = user_id);

-- Financial accounts policies
DROP POLICY IF EXISTS "Users can manage own accounts" ON financial_accounts;
CREATE POLICY "Users can manage own accounts" ON financial_accounts FOR ALL USING (auth.uid() = user_id);

-- Financial debts policies
DROP POLICY IF EXISTS "Users can manage own debts" ON financial_debts;
CREATE POLICY "Users can manage own debts" ON financial_debts FOR ALL USING (auth.uid() = user_id);

-- Tax planning policies
DROP POLICY IF EXISTS "Users can manage own tax planning" ON tax_planning;
CREATE POLICY "Users can manage own tax planning" ON tax_planning FOR ALL USING (auth.uid() = user_id);

-- Tax deductions policies
DROP POLICY IF EXISTS "Users can manage own deductions" ON tax_deductions;
CREATE POLICY "Users can manage own deductions" ON tax_deductions FOR ALL USING (
    auth.uid() = (SELECT user_id FROM tax_planning WHERE id = tax_planning_id)
);

-- Insights policies
DROP POLICY IF EXISTS "Users can manage own insights" ON insights;
CREATE POLICY "Users can manage own insights" ON insights FOR ALL USING (auth.uid() = user_id);

-- Goal contributions policies
DROP POLICY IF EXISTS "Users can manage own contributions" ON goal_contributions;
CREATE POLICY "Users can manage own contributions" ON goal_contributions FOR ALL USING (auth.uid() = user_id);

-- Debt payments policies
DROP POLICY IF EXISTS "Users can manage own payments" ON debt_payments;
CREATE POLICY "Users can manage own payments" ON debt_payments FOR ALL USING (auth.uid() = user_id);

-- Alerts policies
DROP POLICY IF EXISTS "Users can manage own alerts" ON alerts;
CREATE POLICY "Users can manage own alerts" ON alerts FOR ALL USING (auth.uid() = user_id);

-- =============================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- =============================================

-- Update updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all tables with updated_at
DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON user_profiles;
DROP TRIGGER IF EXISTS update_transactions_updated_at ON transactions;
DROP TRIGGER IF EXISTS update_budgets_updated_at ON budgets;
DROP TRIGGER IF EXISTS update_goals_updated_at ON goals;
DROP TRIGGER IF EXISTS update_accounts_updated_at ON financial_accounts;
DROP TRIGGER IF EXISTS update_debts_updated_at ON financial_debts;
DROP TRIGGER IF EXISTS update_tax_planning_updated_at ON tax_planning;
DROP TRIGGER IF EXISTS update_tax_deductions_updated_at ON tax_deductions;
DROP TRIGGER IF EXISTS update_insights_updated_at ON insights;

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_budgets_updated_at BEFORE UPDATE ON budgets FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_goals_updated_at BEFORE UPDATE ON goals FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_accounts_updated_at BEFORE UPDATE ON financial_accounts FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_debts_updated_at BEFORE UPDATE ON financial_debts FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_tax_planning_updated_at BEFORE UPDATE ON tax_planning FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_tax_deductions_updated_at BEFORE UPDATE ON tax_deductions FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_insights_updated_at BEFORE UPDATE ON insights FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- =============================================
-- HELPER FUNCTIONS
-- =============================================

-- Function to calculate budget utilization
CREATE OR REPLACE FUNCTION calculate_budget_utilization(budget_id UUID)
RETURNS DECIMAL(5,2) AS $$
DECLARE
    budget_amount DECIMAL(12,2);
    spent_amount DECIMAL(12,2);
BEGIN
    SELECT amount, spent INTO budget_amount, spent_amount
    FROM budgets WHERE id = budget_id;
    
    IF budget_amount = 0 THEN
        RETURN 0;
    END IF;
    
    RETURN (spent_amount / budget_amount) * 100;
END;
$$ LANGUAGE plpgsql;

-- Function to update goal completion status
CREATE OR REPLACE FUNCTION update_goal_completion()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.current_amount >= NEW.target_amount AND NEW.is_completed = FALSE THEN
        NEW.is_completed = TRUE;
        NEW.completed_at = TIMEZONE('utc', NOW());
        
        -- Award points to user
        UPDATE user_profiles 
        SET reward_points = reward_points + NEW.points_reward
        WHERE id = NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_goal_completion ON goals;
CREATE TRIGGER trigger_goal_completion 
    BEFORE UPDATE ON goals 
    FOR EACH ROW 
    EXECUTE PROCEDURE update_goal_completion();

-- Function to update budget spent amount
CREATE OR REPLACE FUNCTION update_budget_spent_on_transaction()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.type = 'expense' THEN
        UPDATE budgets 
        SET spent = spent + NEW.amount,
            updated_at = TIMEZONE('utc', NOW())
        WHERE user_id = NEW.user_id 
        AND category = NEW.category 
        AND start_date <= NEW.transaction_date 
        AND end_date >= NEW.transaction_date
        AND is_active = TRUE;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_budget_spent ON transactions;
CREATE TRIGGER trigger_update_budget_spent 
    AFTER INSERT ON transactions 
    FOR EACH ROW 
    EXECUTE PROCEDURE update_budget_spent_on_transaction();

-- Function to automatically create user profile after signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, full_name, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    NEW.email
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- Trigger to automatically create user profile
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- =============================================
-- VIEWS FOR COMMON QUERIES
-- =============================================

-- Monthly spending summary view
DROP VIEW IF EXISTS monthly_spending_summary;
CREATE VIEW monthly_spending_summary AS
SELECT 
    user_id,
    DATE_TRUNC('month', transaction_date) as month,
    category,
    SUM(amount) as total_amount,
    COUNT(*) as transaction_count
FROM transactions 
WHERE type = 'expense'
GROUP BY user_id, DATE_TRUNC('month', transaction_date), category;

-- Budget performance view
DROP VIEW IF EXISTS budget_performance;
CREATE VIEW budget_performance AS
SELECT 
    b.*,
    CASE 
        WHEN b.amount = 0 THEN 0
        ELSE (b.spent / b.amount) * 100
    END as utilization_percentage,
    b.amount - b.spent as remaining_amount,
    CASE 
        WHEN b.spent > b.amount THEN 'exceeded'
        WHEN (b.spent / b.amount) * 100 > 80 THEN 'warning'
        ELSE 'good'
    END as status_health
FROM budgets b;

-- Goal progress view
DROP VIEW IF EXISTS goal_progress;
CREATE VIEW goal_progress AS
SELECT 
    g.*,
    CASE 
        WHEN g.target_amount = 0 THEN 0
        ELSE (g.current_amount / g.target_amount) * 100
    END as progress_percentage,
    g.target_amount - g.current_amount as remaining_amount,
    EXTRACT(EPOCH FROM (g.deadline - CURRENT_DATE))/86400 as days_remaining
FROM goals g;

-- Financial health overview
DROP VIEW IF EXISTS financial_health_overview;
CREATE VIEW financial_health_overview AS
SELECT 
    u.id as user_id,
    u.full_name,
    COALESCE(income_summary.total_income, 0) as monthly_income,
    COALESCE(expense_summary.total_expenses, 0) as monthly_expenses,
    COALESCE(income_summary.total_income, 0) - COALESCE(expense_summary.total_expenses, 0) as net_cash_flow,
    CASE 
        WHEN COALESCE(income_summary.total_income, 0) = 0 THEN 0
        ELSE ((COALESCE(income_summary.total_income, 0) - COALESCE(expense_summary.total_expenses, 0)) / COALESCE(income_summary.total_income, 1)) * 100
    END as savings_rate,
    COALESCE(account_summary.total_assets, 0) as total_assets,
    COALESCE(debt_summary.total_debts, 0) as total_debts,
    COALESCE(account_summary.total_assets, 0) - COALESCE(debt_summary.total_debts, 0) as net_worth
FROM user_profiles u
LEFT JOIN (
    SELECT user_id, SUM(amount) as total_income
    FROM transactions 
    WHERE type = 'income' 
    AND transaction_date >= DATE_TRUNC('month', CURRENT_DATE)
    GROUP BY user_id
) income_summary ON u.id = income_summary.user_id
LEFT JOIN (
    SELECT user_id, SUM(amount) as total_expenses
    FROM transactions 
    WHERE type = 'expense' 
    AND transaction_date >= DATE_TRUNC('month', CURRENT_DATE)
    GROUP BY user_id
) expense_summary ON u.id = expense_summary.user_id
LEFT JOIN (
    SELECT user_id, SUM(current_balance) as total_assets
    FROM financial_accounts 
    WHERE is_active = TRUE
    GROUP BY user_id
) account_summary ON u.id = account_summary.user_id
LEFT JOIN (
    SELECT user_id, SUM(current_balance) as total_debts
    FROM financial_debts 
    WHERE is_active = TRUE
    GROUP BY user_id
) debt_summary ON u.id = debt_summary.user_id;

-- Grant necessary permissions for views
GRANT SELECT ON monthly_spending_summary TO authenticated;
GRANT SELECT ON budget_performance TO authenticated;
GRANT SELECT ON goal_progress TO authenticated;
GRANT SELECT ON financial_health_overview TO authenticated;

-- =============================================
-- COMPLETION MESSAGE
-- =============================================

SELECT 'SFMS Database migration completed successfully! 🎉' as message;`;

  const copySQL = async () => {
    try {
      await navigator.clipboard.writeText(migrationSQL);
      setCopiedSQL(true);
      toast.success('SQL script copied to clipboard!');
      setTimeout(() => setCopiedSQL(false), 3000);
    } catch (error) {
      toast.error('Failed to copy SQL script');
    }
  };

  const testConnection = async () => {
    setIsTestingConnection(true);
    try {
      // Test basic connection
      const { data, error } = await supabase.from('user_profiles').select('count').limit(1);
      
      if (!error) {
        toast.success('Database migration successful! 🎉');
        setCurrentStep(4);
        setTimeout(() => {
          onSetupComplete();
        }, 2000);
      } else {
        toast.warning('Tables not found. Please run the migration first.');
      }
    } catch (error) {
      console.error('Connection test error:', error);
      toast.error('Please run the migration script first');
    } finally {
      setIsTestingConnection(false);
    }
  };

  const openSQLEditor = () => {
    window.open('https://ugrcqjjovugagaknjwoa.supabase.co/editor', '_blank');
  };

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.3 }}
      className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
    >
      <Card className="w-full max-w-4xl cartoon-card bg-white/95 backdrop-blur-sm max-h-[90vh] overflow-y-auto">
        <CardHeader className="text-center">
          <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center">
            <Database className="w-8 h-8 text-white" />
          </div>
          <CardTitle className="text-xl">
            🚀 Setup Your SFMS Database
          </CardTitle>
          <CardDescription>
            Run the migration script to create all necessary tables and unlock full functionality
          </CardDescription>
        </CardHeader>

        <CardContent className="space-y-6">
          {/* Progress Steps */}
          <div className="flex items-center justify-center space-x-4 mb-6">
            {[1, 2, 3, 4].map((step) => (
              <div key={step} className="flex items-center">
                <div 
                  className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium transition-all
                    ${currentStep >= step 
                      ? 'bg-green-500 text-white' 
                      : currentStep === step 
                        ? 'bg-blue-500 text-white' 
                        : 'bg-gray-200 text-gray-600'
                    }`}
                >
                  {currentStep > step ? <CheckCircle className="w-4 h-4" /> : step}
                </div>
                {step < 4 && (
                  <div className={`w-8 h-1 mx-2 rounded transition-all ${currentStep > step ? 'bg-green-500' : 'bg-gray-200'}`} />
                )}
              </div>
            ))}
          </div>

          {/* Step 1: Copy SQL */}
          <div className="bg-muted/50 rounded-lg p-4 space-y-3">
            <div className="flex items-start space-x-3">
              <div className={`w-6 h-6 rounded-full flex items-center justify-center text-sm font-medium shrink-0 mt-0.5 ${currentStep >= 1 ? 'bg-blue-500 text-white' : 'bg-gray-200 text-gray-600'}`}>
                1
              </div>
              <div className="flex-1">
                <p className="font-medium text-sm">Copy Migration SQL</p>
                <p className="text-xs text-muted-foreground mb-3">
                  Copy the complete database migration script to your clipboard
                </p>
                
                <Button
                  onClick={copySQL}
                  className="cartoon-button bg-gradient-to-r from-blue-500 to-purple-600 text-white"
                  disabled={copiedSQL}
                >
                  {copiedSQL ? (
                    <>
                      <CheckCircle className="w-4 h-4 mr-2" />
                      Copied!
                    </>
                  ) : (
                    <>
                      <Copy className="w-4 h-4 mr-2" />
                      Copy SQL Script
                    </>
                  )}
                </Button>
              </div>
            </div>
          </div>

          {/* Step 2: Open SQL Editor */}
          <div className="bg-muted/50 rounded-lg p-4 space-y-3">
            <div className="flex items-start space-x-3">
              <div className={`w-6 h-6 rounded-full flex items-center justify-center text-sm font-medium shrink-0 mt-0.5 ${currentStep >= 2 ? 'bg-blue-500 text-white' : 'bg-gray-200 text-gray-600'}`}>
                2
              </div>
              <div className="flex-1">
                <p className="font-medium text-sm">Open Supabase SQL Editor</p>
                <p className="text-xs text-muted-foreground mb-3">
                  Open your Supabase SQL Editor to run the migration script
                </p>
                
                <Button
                  onClick={() => {
                    openSQLEditor();
                    setCurrentStep(2);
                  }}
                  variant="outline"
                  className="cartoon-button border-2"
                >
                  <Database className="w-4 h-4 mr-2" />
                  Open SQL Editor
                  <ExternalLink className="w-3 h-3 ml-1" />
                </Button>
              </div>
            </div>
          </div>

          {/* Step 3: Run Migration */}
          <div className="bg-muted/50 rounded-lg p-4 space-y-3">
            <div className="flex items-start space-x-3">
              <div className={`w-6 h-6 rounded-full flex items-center justify-center text-sm font-medium shrink-0 mt-0.5 ${currentStep >= 3 ? 'bg-blue-500 text-white' : 'bg-gray-200 text-gray-600'}`}>
                3
              </div>
              <div className="flex-1">
                <p className="font-medium text-sm">Paste & Run Migration</p>
                <p className="text-xs text-muted-foreground mb-3">
                  Paste the SQL script into the editor and click "Run" to create all tables
                </p>
                
                <div className="text-xs bg-yellow-50 text-yellow-800 p-2 rounded border border-yellow-200 mb-3">
                  <AlertCircle className="w-3 h-3 inline mr-1" />
                  <strong>Instructions:</strong> Paste the copied SQL into the editor, then click the "Run" button
                </div>

                <Button
                  onClick={() => setCurrentStep(3)}
                  variant="outline"
                  className="cartoon-button border-2"
                >
                  <Play className="w-4 h-4 mr-2" />
                  Mark as Complete
                </Button>
              </div>
            </div>
          </div>

          {/* Step 4: Test Connection */}
          <div className="bg-muted/50 rounded-lg p-4 space-y-3">
            <div className="flex items-start space-x-3">
              <div className={`w-6 h-6 rounded-full flex items-center justify-center text-sm font-medium shrink-0 mt-0.5 ${currentStep >= 4 ? 'bg-green-500 text-white' : 'bg-gray-200 text-gray-600'}`}>
                4
              </div>
              <div className="flex-1">
                <p className="font-medium text-sm">Verify Setup</p>
                <p className="text-xs text-muted-foreground mb-3">
                  Test the database connection to ensure migration was successful
                </p>
                
                <Button
                  onClick={testConnection}
                  disabled={isTestingConnection || currentStep < 3}
                  className="cartoon-button bg-gradient-to-r from-green-500 to-emerald-600 text-white"
                >
                  {isTestingConnection ? (
                    <>
                      <RefreshCw className="w-4 h-4 mr-2 animate-spin" />
                      Testing...
                    </>
                  ) : currentStep >= 4 ? (
                    <>
                      <CheckCircle className="w-4 h-4 mr-2" />
                      Setup Complete!
                    </>
                  ) : (
                    <>
                      <Database className="w-4 h-4 mr-2" />
                      Test Connection
                    </>
                  )}
                </Button>
              </div>
            </div>
          </div>

          {/* What You're Creating */}
          <div className="bg-gradient-to-r from-green-50 to-emerald-50 rounded-xl p-4 border border-green-200">
            <h4 className="font-medium text-green-600 mb-3">🎯 Database Features You're Enabling:</h4>
            <div className="grid grid-cols-2 gap-2 text-xs">
              <div className="flex items-center space-x-2">
                <CheckCircle className="w-3 h-3 text-green-500" />
                <span>12 Production Tables</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle className="w-3 h-3 text-green-500" />
                <span>Row Level Security</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle className="w-3 h-3 text-green-500" />
                <span>Automated Triggers</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle className="w-3 h-3 text-green-500" />
                <span>Performance Indexes</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle className="w-3 h-3 text-green-500" />
                <span>Real-time Updates</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle className="w-3 h-3 text-green-500" />
                <span>Data Validation</span>
              </div>
            </div>
          </div>

          {/* SQL Preview */}
          <div className="bg-slate-900 text-green-400 p-4 rounded-lg max-h-64 overflow-y-auto">
            <div className="text-xs font-mono">
              <div className="text-gray-400 mb-2">📋 Migration Script Preview:</div>
              <pre className="whitespace-pre-wrap text-xs">
{`-- Smart Finance Management System Database Migration
-- Creates 12 tables with full security and performance optimization

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User profiles, transactions, budgets, goals...
-- Financial accounts, debts, tax planning...
-- Insights, alerts, and tracking tables...

-- Row Level Security for data protection
-- Performance indexes for fast queries
-- Automated triggers for real-time updates

-- 🎉 Complete production-ready database!`}
              </pre>
            </div>
          </div>

          <div className="text-center text-xs text-muted-foreground">
            This migration creates a complete, production-ready database with security, performance optimization, and real-time features.
          </div>
        </CardContent>
      </Card>
    </motion.div>
  );
}