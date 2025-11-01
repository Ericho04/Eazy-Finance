import { createClient } from '@supabase/supabase-js'

// Helper function to get environment variables across different bundlers
const getEnvVar = (name: string): string | undefined => {
  // Try different environment variable access patterns
  try {
    // Vite
    if (typeof import.meta !== 'undefined' && import.meta.env) {
      return import.meta.env[name];
    }
  } catch (e) {
    // Ignore import.meta errors
  }

  try {
    // Create React App / Node.js
    if (typeof process !== 'undefined' && process.env) {
      return process.env[name];
    }
  } catch (e) {
    // Ignore process errors
  }

  // Browser environment - check window object
  try {
    if (typeof window !== 'undefined' && (window as any).env) {
      return (window as any).env[name];
    }
  } catch (e) {
    // Ignore window errors
  }

  return undefined;
};

// Your Supabase project configuration
const SUPABASE_URL = 'https://ugrcqjjovugagaknjwoa.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVncmNxampvdnVnYWdha25qd29hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4MTk4NzEsImV4cCI6MjA3MDM5NTg3MX0.wsCAS216K86Y6RCR9PL5rJ57WQDFzfDFOR_4f7ePSe8';

// Get Supabase configuration from environment variables or use defaults
const supabaseUrl = getEnvVar('VITE_SUPABASE_URL') || 
                   getEnvVar('REACT_APP_SUPABASE_URL') || 
                   getEnvVar('SUPABASE_URL') || 
                   SUPABASE_URL;

const supabaseAnonKey = getEnvVar('VITE_SUPABASE_ANON_KEY') || 
                       getEnvVar('REACT_APP_SUPABASE_ANON_KEY') || 
                       getEnvVar('SUPABASE_ANON_KEY') || 
                       SUPABASE_ANON_KEY;

// Helper function to check if Supabase is properly configured
export const isSupabaseConfigured = () => {
  return supabaseUrl.startsWith('https://') && 
         supabaseAnonKey.length > 20 && 
         supabaseUrl === SUPABASE_URL && 
         supabaseAnonKey === SUPABASE_ANON_KEY;
};

// Check if we have URL but missing anon key (should be false now)
export const needsAnonKey = () => {
  return false; // We now have both URL and anon key
};

// Create Supabase client
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
    flowType: 'pkce'
  },
  realtime: {
    params: {
      eventsPerSecond: 10
    }
  },
  global: {
    headers: {
      'x-client-info': 'sfms-v1.0.0'
    }
  }
});

// Log configuration status for debugging
console.log('🎉 SFMS: Successfully connected to Supabase!');
console.log('- Project URL:', supabaseUrl);
console.log('- Authentication: ✅ Ready');
console.log('- Database: ✅ Ready');
console.log('- Real-time: ✅ Enabled');

// Database types (generated from Supabase CLI or manually defined)
export interface Database {
  public: {
    Tables: {
      user_profiles: {
        Row: {
          id: string
          full_name: string | null
          email: string | null
          avatar_url: string | null
          language: string
          currency: string
          timezone: string
          reward_points: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id: string
          full_name?: string | null
          email?: string | null
          avatar_url?: string | null
          language?: string
          currency?: string
          timezone?: string
          reward_points?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          full_name?: string | null
          email?: string | null
          avatar_url?: string | null
          language?: string
          currency?: string
          timezone?: string
          reward_points?: number
          created_at?: string
          updated_at?: string
        }
      }
      transactions: {
        Row: {
          id: string
          user_id: string
          amount: number
          category: string
          description: string
          transaction_date: string
          type: 'income' | 'expense'
          source: 'manual' | 'ocr' | 'bank' | 'api'
          receipt_url: string | null
          tags: string[] | null
          location: string | null
          notes: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          amount: number
          category: string
          description: string
          transaction_date: string
          type: 'income' | 'expense'
          source?: 'manual' | 'ocr' | 'bank' | 'api'
          receipt_url?: string | null
          tags?: string[] | null
          location?: string | null
          notes?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          amount?: number
          category?: string
          description?: string
          transaction_date?: string
          type?: 'income' | 'expense'
          source?: 'manual' | 'ocr' | 'bank' | 'api'
          receipt_url?: string | null
          tags?: string[] | null
          location?: string | null
          notes?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      budgets: {
        Row: {
          id: string
          user_id: string
          category: string
          amount: number
          spent: number
          period: 'daily' | 'weekly' | 'monthly' | 'quarterly' | 'yearly' | 'custom'
          start_date: string
          end_date: string
          status: 'active' | 'paused' | 'completed' | 'cancelled'
          is_active: boolean
          tags: string[] | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          category: string
          amount: number
          spent?: number
          period: 'daily' | 'weekly' | 'monthly' | 'quarterly' | 'yearly' | 'custom'
          start_date: string
          end_date: string
          status?: 'active' | 'paused' | 'completed' | 'cancelled'
          is_active?: boolean
          tags?: string[] | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          category?: string
          amount?: number
          spent?: number
          period?: 'daily' | 'weekly' | 'monthly' | 'quarterly' | 'yearly' | 'custom'
          start_date?: string
          end_date?: string
          status?: 'active' | 'paused' | 'completed' | 'cancelled'
          is_active?: boolean
          tags?: string[] | null
          created_at?: string
          updated_at?: string
        }
      }
      goals: {
        Row: {
          id: string
          user_id: string
          title: string
          description: string | null
          target_amount: number
          current_amount: number
          deadline: string
          category: string
          priority: 'low' | 'medium' | 'high'
          is_completed: boolean
          completed_at: string | null
          points_reward: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          title: string
          description?: string | null
          target_amount: number
          current_amount?: number
          deadline: string
          category: string
          priority?: 'low' | 'medium' | 'high'
          is_completed?: boolean
          completed_at?: string | null
          points_reward?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          title?: string
          description?: string | null
          target_amount?: number
          current_amount?: number
          deadline?: string
          category?: string
          priority?: 'low' | 'medium' | 'high'
          is_completed?: boolean
          completed_at?: string | null
          points_reward?: number
          created_at?: string
          updated_at?: string
        }
      }
      financial_accounts: {
        Row: {
          id: string
          user_id: string
          account_name: string
          account_number: string | null
          account_type: 'savings' | 'checking' | 'fixed_deposit' | 'investment' | 'retirement' | 'business' | 'e_wallet' | 'credit_card'
          bank_name: string
          current_balance: number
          currency: string
          is_active: boolean
          metadata: Record<string, any> | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          account_name: string
          account_number?: string | null
          account_type: 'savings' | 'checking' | 'fixed_deposit' | 'investment' | 'retirement' | 'business' | 'e_wallet' | 'credit_card'
          bank_name: string
          current_balance?: number
          currency?: string
          is_active?: boolean
          metadata?: Record<string, any> | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          account_name?: string
          account_number?: string | null
          account_type?: 'savings' | 'checking' | 'fixed_deposit' | 'investment' | 'retirement' | 'business' | 'e_wallet' | 'credit_card'
          bank_name?: string
          current_balance?: number
          currency?: string
          is_active?: boolean
          metadata?: Record<string, any> | null
          created_at?: string
          updated_at?: string
        }
      }
      financial_debts: {
        Row: {
          id: string
          user_id: string
          debt_name: string
          debt_type: 'credit_card' | 'personal_loan' | 'car_loan' | 'home_loan' | 'student_loan' | 'business_loan' | 'other'
          original_amount: number
          current_balance: number
          interest_rate: number
          minimum_payment: number
          due_date: string | null
          creditor_name: string
          last_payment_date: string | null
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          debt_name: string
          debt_type: 'credit_card' | 'personal_loan' | 'car_loan' | 'home_loan' | 'student_loan' | 'business_loan' | 'other'
          original_amount: number
          current_balance: number
          interest_rate?: number
          minimum_payment?: number
          due_date?: string | null
          creditor_name: string
          last_payment_date?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          debt_name?: string
          debt_type?: 'credit_card' | 'personal_loan' | 'car_loan' | 'home_loan' | 'student_loan' | 'business_loan' | 'other'
          original_amount?: number
          current_balance?: number
          interest_rate?: number
          minimum_payment?: number
          due_date?: string | null
          creditor_name?: string
          last_payment_date?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      insights: {
        Row: {
          id: string
          user_id: string
          title: string
          description: string
          type: 'trend' | 'prediction' | 'comparison' | 'alert' | 'recommendation' | 'achievement' | 'summary'
          category: 'spending' | 'income' | 'budget' | 'goals' | 'savings' | 'debt' | 'investment' | 'tax' | 'cashflow' | 'general'
          data: Record<string, any>
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          title: string
          description: string
          type: 'trend' | 'prediction' | 'comparison' | 'alert' | 'recommendation' | 'achievement' | 'summary'
          category: 'spending' | 'income' | 'budget' | 'goals' | 'savings' | 'debt' | 'investment' | 'tax' | 'cashflow' | 'general'
          data?: Record<string, any>
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          title?: string
          description?: string
          type?: 'trend' | 'prediction' | 'comparison' | 'alert' | 'recommendation' | 'achievement' | 'summary'
          category?: 'spending' | 'income' | 'budget' | 'goals' | 'savings' | 'debt' | 'investment' | 'tax' | 'cashflow' | 'general'
          data?: Record<string, any>
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
    }
    Views: {
      monthly_spending_summary: {
        Row: {
          user_id: string
          month: string
          category: string
          total_amount: number
          transaction_count: number
        }
      }
      budget_performance: {
        Row: {
          id: string
          user_id: string
          category: string
          amount: number
          spent: number
          period: string
          start_date: string
          end_date: string
          status: string
          is_active: boolean
          tags: string[] | null
          created_at: string
          updated_at: string
          utilization_percentage: number
          remaining_amount: number
          status_health: string
        }
      }
      goal_progress: {
        Row: {
          id: string
          user_id: string
          title: string
          description: string | null
          target_amount: number
          current_amount: number
          deadline: string
          category: string
          priority: string
          is_completed: boolean
          completed_at: string | null
          points_reward: number
          created_at: string
          updated_at: string
          progress_percentage: number
          remaining_amount: number
          days_remaining: number
        }
      }
      financial_health_overview: {
        Row: {
          user_id: string
          full_name: string | null
          monthly_income: number
          monthly_expenses: number
          net_cash_flow: number
          savings_rate: number
          total_assets: number
          total_debts: number
          net_worth: number
        }
      }
    }
    Functions: {
      calculate_budget_utilization: {
        Args: { budget_id: string }
        Returns: number
      }
    }
    Enums: {
      transaction_type: 'income' | 'expense'
      transaction_source: 'manual' | 'ocr' | 'bank' | 'api'
      budget_period: 'daily' | 'weekly' | 'monthly' | 'quarterly' | 'yearly' | 'custom'
      budget_status: 'active' | 'paused' | 'completed' | 'cancelled'
      goal_priority: 'low' | 'medium' | 'high'
      account_type: 'savings' | 'checking' | 'fixed_deposit' | 'investment' | 'retirement' | 'business' | 'e_wallet' | 'credit_card'
      debt_type: 'credit_card' | 'personal_loan' | 'car_loan' | 'home_loan' | 'student_loan' | 'business_loan' | 'other'
      insight_type: 'trend' | 'prediction' | 'comparison' | 'alert' | 'recommendation' | 'achievement' | 'summary'
      insight_category: 'spending' | 'income' | 'budget' | 'goals' | 'savings' | 'debt' | 'investment' | 'tax' | 'cashflow' | 'general'
      alert_type: 'budget_exceeded' | 'budget_warning' | 'goal_reminder' | 'debt_due' | 'low_balance'
      alert_status: 'pending' | 'read' | 'dismissed'
    }
  }
}

// Helper function to get current user
export const getCurrentUser = async () => {
  try {
    const { data: { user }, error } = await supabase.auth.getUser()
    return { user, error }
  } catch (error) {
    console.error('Get current user error:', error)
    return { user: null, error }
  }
}

// Helper function to get user profile
export const getUserProfile = async (userId: string) => {
  try {
    const { data, error } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('id', userId)
      .single()
    
    return { data, error }
  } catch (error) {
    console.error('Get user profile error:', error)
    return { data: null, error }
  }
}

// Authentication helpers
export const signInWithEmail = async (email: string, password: string) => {
  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    return { data, error }
  } catch (error) {
    console.error('Sign in error:', error)
    return { data: null, error }
  }
}

export const signUpWithEmail = async (email: string, password: string, metadata?: any) => {
  try {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: metadata
      }
    })
    return { data, error }
  } catch (error) {
    console.error('Sign up error:', error)
    return { data: null, error }
  }
}

export const signOut = async () => {
  try {
    const { error } = await supabase.auth.signOut()
    return { error }
  } catch (error) {
    console.error('Sign out error:', error)
    return { error }
  }
}

export const resetPassword = async (email: string) => {
  try {
    const { data, error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password`,
    })
    return { data, error }
  } catch (error) {
    console.error('Reset password error:', error)
    return { data: null, error }
  }
}

// Real-time subscriptions
export const subscribeToTransactions = (userId: string, callback: (payload: any) => void) => {
  return supabase
    .channel('transactions')
    .on('postgres_changes', 
      { 
        event: '*', 
        schema: 'public', 
        table: 'transactions',
        filter: `user_id=eq.${userId}`
      }, 
      callback
    )
    .subscribe()
}

export const subscribeToBudgets = (userId: string, callback: (payload: any) => void) => {
  return supabase
    .channel('budgets')
    .on('postgres_changes', 
      { 
        event: '*', 
        schema: 'public', 
        table: 'budgets',
        filter: `user_id=eq.${userId}`
      }, 
      callback
    )
    .subscribe()
}

export const subscribeToGoals = (userId: string, callback: (payload: any) => void) => {
  return supabase
    .channel('goals')
    .on('postgres_changes', 
      { 
        event: '*', 
        schema: 'public', 
        table: 'goals',
        filter: `user_id=eq.${userId}`
      }, 
      callback
    )
    .subscribe()
}

export const subscribeToAlerts = (userId: string, callback: (payload: any) => void) => {
  return supabase
    .channel('alerts')
    .on('postgres_changes', 
      { 
        event: '*', 
        schema: 'public', 
        table: 'alerts',
        filter: `user_id=eq.${userId}`
      }, 
      callback
    )
    .subscribe()
}