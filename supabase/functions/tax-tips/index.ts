// Easy Finance - Tax Tips & Affordability Edge Function
// Provides tax planning insights and debt affordability analysis

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface TaxTipsRequest {
  type: 'tax_tips' | 'debt_affordability';
  userId: string;
  assessmentYear?: number;
  monthlyIncome?: number;
}

interface TaxReliefSuggestion {
  categoryCode: string;
  categoryLabel: string;
  annualLimit: number;
  currentClaimed: number;
  remainingQuota: number;
  estimatedSavings: number;
  suggestion: string;
}

interface DTIAnalysis {
  monthlyIncome: number;
  totalMonthlyDebtPayments: number;
  dtiRatio: number;
  label: 'safe' | 'borderline' | 'risky';
  recommendation: string;
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    );

    const requestData: TaxTipsRequest = await req.json();
    const { type, userId, assessmentYear, monthlyIncome } = requestData;

    if (type === 'tax_tips') {
      // Get tax relief suggestions
      const year = assessmentYear ?? new Date().getFullYear();

      // Fetch tax profile and claims
      const { data: taxProfile, error: profileError } = await supabaseClient
        .from('tax_profile')
        .select('*, tax_claim(*)')
        .eq('user_id', userId)
        .eq('assessment_year', year)
        .single();

      if (profileError && profileError.code !== 'PGRST116') {
        throw profileError;
      }

      // Fetch all tax relief categories
      const { data: reliefCategories, error: categoriesError } = await supabaseClient
        .from('tax_relief_category')
        .select('*')
        .order('code');

      if (categoriesError) throw categoriesError;

      // Calculate suggestions
      const suggestions: TaxReliefSuggestion[] = reliefCategories.map((category) => {
        const claims = taxProfile?.tax_claim?.filter(
          (claim: any) => claim.category_id === category.id
        ) ?? [];

        const currentClaimed = claims.reduce(
          (sum: number, claim: any) => sum + parseFloat(claim.amount),
          0
        );

        const remainingQuota = Math.max(0, category.annual_limit - currentClaimed);

        // Estimate tax savings (assuming average tax rate of 8-14% for middle income)
        const estimatedSavings = remainingQuota * 0.10;

        let suggestion = '';
        if (remainingQuota > 0) {
          suggestion = `You can still claim RM ${remainingQuota.toFixed(2)} under ${category.label}. Estimated tax savings: RM ${estimatedSavings.toFixed(2)}.`;
        } else if (currentClaimed >= category.annual_limit) {
          suggestion = `You've maximized this relief category.`;
        } else {
          suggestion = `Consider utilizing this relief to reduce your tax liability.`;
        }

        return {
          categoryCode: category.code,
          categoryLabel: category.label,
          annualLimit: category.annual_limit,
          currentClaimed,
          remainingQuota,
          estimatedSavings,
          suggestion,
        };
      });

      // Sort by remaining quota (highest first)
      suggestions.sort((a, b) => b.remainingQuota - a.remainingQuota);

      return new Response(
        JSON.stringify({
          success: true,
          data: {
            assessmentYear: year,
            suggestions: suggestions.filter((s) => s.remainingQuota > 0).slice(0, 5),
            totalRemainingQuota: suggestions.reduce((sum, s) => sum + s.remainingQuota, 0),
            totalEstimatedSavings: suggestions.reduce((sum, s) => sum + s.estimatedSavings, 0),
          },
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    } else if (type === 'debt_affordability') {
      // Calculate DTI and provide affordability analysis
      if (!monthlyIncome) {
        throw new Error('monthlyIncome is required for debt affordability analysis');
      }

      // Fetch all active debts for the user
      const { data: debts, error: debtsError } = await supabaseClient
        .from('debt')
        .select('*')
        .eq('user_id', userId);

      if (debtsError) throw debtsError;

      // Calculate total monthly debt payments
      const totalMonthlyDebtPayments = debts.reduce((sum: number, debt: any) => {
        const principal = parseFloat(debt.principal);
        const apr = parseFloat(debt.apr);
        const termMonths = debt.term_months;
        const extraPayment = parseFloat(debt.extra_monthly_payment) || 0;

        // Calculate monthly payment using amortization formula
        let monthlyPayment = 0;
        if (apr === 0) {
          monthlyPayment = principal / termMonths;
        } else {
          const monthlyRate = apr / 12 / 100;
          monthlyPayment =
            (principal * (monthlyRate * Math.pow(1 + monthlyRate, termMonths))) /
            (Math.pow(1 + monthlyRate, termMonths) - 1);
        }

        return sum + monthlyPayment + extraPayment;
      }, 0);

      // Calculate DTI ratio
      const dtiRatio = monthlyIncome > 0 ? totalMonthlyDebtPayments / monthlyIncome : 0;

      // Determine label and recommendation
      let label: 'safe' | 'borderline' | 'risky';
      let recommendation: string;

      if (dtiRatio < 0.36) {
        label = 'safe';
        recommendation =
          'Your debt-to-income ratio is healthy. You have good financial flexibility for savings and investments.';
      } else if (dtiRatio < 0.43) {
        label = 'borderline';
        recommendation =
          'Your debt-to-income ratio is borderline. Consider paying down debts or increasing income before taking on additional debt.';
      } else {
        label = 'risky';
        recommendation =
          'Your debt-to-income ratio is high. Focus on debt reduction and avoid new debt. Consider debt consolidation or financial counseling.';
      }

      const analysis: DTIAnalysis = {
        monthlyIncome,
        totalMonthlyDebtPayments,
        dtiRatio,
        label,
        recommendation,
      };

      return new Response(
        JSON.stringify({
          success: true,
          data: analysis,
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    } else {
      throw new Error(`Unknown request type: ${type}`);
    }
  } catch (error) {
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});
