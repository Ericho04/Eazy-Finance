import { motion } from 'motion/react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Database, CheckCircle, ExternalLink, Copy, AlertTriangle, ArrowRight } from 'lucide-react';
import { useState } from 'react';
import { toast } from 'sonner';
import { supabase } from '../lib/supabase';

interface DatabaseMigrationNoticeProps {
  onSetupComplete: () => void;
  onContinueWithoutSetup?: () => void;
}

export function DatabaseMigrationNotice({ onSetupComplete, onContinueWithoutSetup }: DatabaseMigrationNoticeProps) {
  const [isTestingConnection, setIsTestingConnection] = useState(false);
  const [copiedSQL, setCopiedSQL] = useState(false);
  const [setupStep, setSetupStep] = useState(1);

  // Simplified migration SQL - just the essential tables
  const migrationSQL = `-- SFMS Database Setup
-- Run this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User Profiles Table
CREATE TABLE IF NOT EXISTS public.user_profiles (
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

-- Transactions Table
CREATE TYPE IF NOT EXISTS transaction_type AS ENUM ('income', 'expense');
CREATE TYPE IF NOT EXISTS transaction_source AS ENUM ('manual', 'ocr', 'bank', 'api');

CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    category TEXT NOT NULL,
    description TEXT NOT NULL,
    transaction_date DATE NOT NULL,
    type transaction_type NOT NULL,
    source transaction_source DEFAULT 'manual',
    tags TEXT[],
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Budgets Table
CREATE TYPE IF NOT EXISTS budget_period AS ENUM ('daily', 'weekly', 'monthly', 'quarterly', 'yearly');
CREATE TYPE IF NOT EXISTS budget_status AS ENUM ('active', 'paused', 'completed', 'cancelled');

CREATE TABLE IF NOT EXISTS public.budgets (
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Goals Table
CREATE TYPE IF NOT EXISTS goal_priority AS ENUM ('low', 'medium', 'high');

CREATE TABLE IF NOT EXISTS public.goals (
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Enable Row Level Security
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;

-- Create Policies
CREATE POLICY "Users can manage own profile" ON public.user_profiles 
    FOR ALL USING (auth.uid() = id);

CREATE POLICY "Users can manage own transactions" ON public.transactions 
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own budgets" ON public.budgets 
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own goals" ON public.goals 
    FOR ALL USING (auth.uid() = user_id);

-- Auto-create user profile on signup
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

-- Trigger to auto-create profile
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Success message
SELECT 'SFMS Database setup completed successfully! 🎉' as message;`;

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
      // Test if user_profiles table exists
      const { error } = await supabase.from('user_profiles').select('count').limit(1);
      
      if (!error) {
        toast.success('Database setup verified! 🎉');
        setSetupStep(3);
        setTimeout(() => {
          onSetupComplete();
        }, 1500);
      } else if (error.code === 'PGRST205') {
        toast.error('Tables not found. Please run the migration script first.');
      } else {
        toast.error('Database connection issue: ' + error.message);
      }
    } catch (error) {
      console.error('Connection test error:', error);
      toast.error('Please run the migration script first');
    } finally {
      setIsTestingConnection(false);
    }
  };

  const openSQLEditor = () => {
    window.open('https://ugrcqjjovugagaknjwoa.supabase.co/project/_/sql', '_blank');
  };

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.3 }}
      className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
    >
      <Card className="w-full max-w-3xl cartoon-card bg-white/95 backdrop-blur-sm max-h-[90vh] overflow-y-auto">
        <CardHeader className="text-center">
          <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center">
            <Database className="w-8 h-8 text-white" />
          </div>
          <CardTitle className="text-xl">
            🚀 Database Setup Required
          </CardTitle>
          <CardDescription>
            Your SFMS app needs a few database tables to store your financial data securely
          </CardDescription>
        </CardHeader>

        <CardContent className="space-y-6">
          {/* Progress Steps */}
          <div className="flex items-center justify-center space-x-4 mb-8">
            {[1, 2, 3].map((step) => (
              <div key={step} className="flex items-center">
                <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium ${
                  setupStep >= step 
                    ? 'bg-green-500 text-white' 
                    : 'bg-gray-200 text-gray-600'
                }`}>
                  {setupStep > step ? (
                    <CheckCircle className="w-4 h-4" />
                  ) : (
                    step
                  )}
                </div>
                {step < 3 && (
                  <div className={`w-8 h-1 mx-2 ${
                    setupStep > step ? 'bg-green-500' : 'bg-gray-200'
                  }`} />
                )}
              </div>
            ))}
          </div>

          {/* Current Step */}
          {setupStep === 1 && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="space-y-6"
            >
              <div className="bg-gradient-to-r from-blue-50 to-purple-50 p-6 rounded-2xl border border-blue-100">
                <h3 className="text-lg font-semibold mb-3 flex items-center">
                  <Database className="w-5 h-5 mr-2 text-blue-600" />
                  Step 1: Copy Migration Script
                </h3>
                <p className="text-gray-600 mb-4">
                  This script creates the necessary tables for your SFMS app with proper security policies.
                </p>
                
                <div className="bg-gray-900 rounded-lg p-4 text-green-400 font-mono text-sm max-h-64 overflow-y-auto">
                  <pre className="whitespace-pre-wrap">{migrationSQL}</pre>
                </div>
                
                <div className="flex gap-3 mt-4">
                  <Button
                    onClick={copySQL}
                    variant="outline"
                    className="flex-1"
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
                  
                  <Button
                    onClick={() => setSetupStep(2)}
                    className="flex-1"
                  >
                    Next Step
                    <ArrowRight className="w-4 h-4 ml-2" />
                  </Button>
                </div>
              </div>
            </motion.div>
          )}

          {setupStep === 2 && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="space-y-6"
            >
              <div className="bg-gradient-to-r from-purple-50 to-pink-50 p-6 rounded-2xl border border-purple-100">
                <h3 className="text-lg font-semibold mb-3 flex items-center">
                  <ExternalLink className="w-5 h-5 mr-2 text-purple-600" />
                  Step 2: Run in Supabase SQL Editor
                </h3>
                <div className="space-y-4">
                  <p className="text-gray-600">
                    1. Open your Supabase SQL Editor
                  </p>
                  <p className="text-gray-600">
                    2. Paste the copied script
                  </p>
                  <p className="text-gray-600">
                    3. Click "Run" to execute
                  </p>
                  
                  <div className="flex gap-3">
                    <Button
                      onClick={openSQLEditor}
                      variant="outline"
                      className="flex-1"
                    >
                      <ExternalLink className="w-4 h-4 mr-2" />
                      Open SQL Editor
                    </Button>
                    
                    <Button
                      onClick={testConnection}
                      disabled={isTestingConnection}
                      className="flex-1"
                    >
                      {isTestingConnection ? (
                        <>
                          <motion.div
                            animate={{ rotate: 360 }}
                            transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                            className="w-4 h-4 mr-2"
                          >
                            <Database className="w-4 h-4" />
                          </motion.div>
                          Testing...
                        </>
                      ) : (
                        <>
                          <CheckCircle className="w-4 h-4 mr-2" />
                          Test Setup
                        </>
                      )}
                    </Button>
                  </div>
                </div>
              </div>
            </motion.div>
          )}

          {setupStep === 3 && (
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="text-center space-y-6"
            >
              <div className="w-20 h-20 mx-auto bg-gradient-to-br from-green-400 to-green-600 rounded-full flex items-center justify-center">
                <CheckCircle className="w-10 h-10 text-white" />
              </div>
              <div>
                <h3 className="text-xl font-semibold text-green-600 mb-2">
                  Setup Complete! 🎉
                </h3>
                <p className="text-gray-600">
                  Your SFMS database is ready. Redirecting to the app...
                </p>
              </div>
            </motion.div>
          )}

          {/* Footer Actions */}
          {setupStep < 3 && (
            <div className="border-t pt-6 mt-8">
              <div className="bg-amber-50 border border-amber-200 rounded-xl p-4 mb-4">
                <div className="flex items-start">
                  <AlertTriangle className="w-5 h-5 text-amber-600 mr-3 mt-0.5 flex-shrink-0" />
                  <div>
                    <p className="text-sm text-amber-800 font-medium mb-1">
                      Need Help?
                    </p>
                    <p className="text-xs text-amber-700">
                      If you encounter issues, check the Supabase logs or contact support. 
                      You can also continue with limited functionality using demo mode.
                    </p>
                  </div>
                </div>
              </div>
              
              {onContinueWithoutSetup && (
                <div className="flex justify-center">
                  <Button
                    onClick={onContinueWithoutSetup}
                    variant="ghost"
                    size="sm"
                    className="text-gray-500 hover:text-gray-700"
                  >
                    Continue with Demo Mode (Limited Features)
                  </Button>
                </div>
              )}
            </div>
          )}
        </CardContent>
      </Card>
    </motion.div>
  );
}