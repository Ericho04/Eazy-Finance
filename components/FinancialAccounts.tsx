import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";
import { 
  ArrowLeft,
  Building,
  Wallet,
  Plus,
  TrendingUp,
  PieChart,
  DollarSign,
  ShieldCheck,
  Eye,
  EyeOff,
  CreditCard
} from "lucide-react";
import { motion } from "motion/react";

interface FinancialAccountsProps {
  onBack: () => void;
}

interface FinancialAccount {
  id: string;
  name: string;
  type: 'checking' | 'savings' | 'investment' | 'retirement' | 'other';
  balance: number;
  currency: string;
  interestRate?: number;
  lastTransaction?: string;
}

export function FinancialAccounts({ onBack }: FinancialAccountsProps) {
  const [showBalances, setShowBalances] = useState(true);
  const [accounts] = useState<FinancialAccount[]>([
    {
      id: '1',
      name: 'Maybank Current Account',
      type: 'checking',
      balance: 8500,
      currency: 'RM',
      interestRate: 0.25,
      lastTransaction: '2024-01-10'
    },
    {
      id: '2',
      name: 'Public Bank Savings',
      type: 'savings', 
      balance: 25000,
      currency: 'RM',
      interestRate: 2.8,
      lastTransaction: '2024-01-08'
    },
    {
      id: '3',
      name: 'EPF Account',
      type: 'retirement',
      balance: 85000,
      currency: 'RM',
      interestRate: 5.5,
      lastTransaction: '2024-01-01'
    },
    {
      id: '4',
      name: 'CIMB Investment Account',
      type: 'investment',
      balance: 15200,
      currency: 'RM',
      interestRate: 4.2,
      lastTransaction: '2024-01-09'
    }
  ]);

  const totalBalance = accounts.reduce((sum, acc) => sum + acc.balance, 0);
  const savingsAccounts = accounts.filter(acc => acc.type === 'savings' || acc.type === 'investment');
  const totalSavings = savingsAccounts.reduce((sum, acc) => sum + acc.balance, 0);

  const formatCurrency = (amount: number) => {
    return `RM ${amount.toLocaleString('en-MY', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`;
  };

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'checking': return <CreditCard className="w-4 h-4" />;
      case 'savings': return <PieChart className="w-4 h-4" />;
      case 'investment': return <TrendingUp className="w-4 h-4" />;
      case 'retirement': return <ShieldCheck className="w-4 h-4" />;
      default: return <Wallet className="w-4 h-4" />;
    }
  };

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'checking': return 'text-[color:var(--sfms-warning)]';
      case 'savings': return 'text-[color:var(--sfms-success)]';
      case 'investment': return 'text-[color:var(--sfms-ai)]';
      case 'retirement': return 'text-purple-600';
      default: return 'text-[color:var(--sfms-neutral-dark)]';
    }
  };

  const getTypeBadgeColor = (type: string) => {
    switch (type) {
      case 'checking': return 'bg-[color:var(--sfms-warning-light)] text-[color:var(--sfms-warning)]';
      case 'savings': return 'bg-[color:var(--sfms-success-light)] text-[color:var(--sfms-success)]';
      case 'investment': return 'bg-[color:var(--sfms-ai-light)] text-[color:var(--sfms-ai)]';
      case 'retirement': return 'bg-purple-50 text-purple-600';
      default: return 'bg-[color:var(--sfms-neutral-light)] text-[color:var(--sfms-neutral-dark)]';
    }
  };

  return (
    <div className="pb-6 px-4 space-y-6">
      {/* Header */}
      <div className="pt-6">
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
          className="flex items-center gap-4"
        >
          <Button
            variant="ghost"
            size="sm"
            onClick={onBack}
            className="p-2"
          >
            <ArrowLeft className="w-4 h-4" />
          </Button>
          <div className="flex-1 flex items-center justify-between">
            <div>
              <h1 className="text-2xl text-[color:var(--sfms-warning)]">Bank Accounts</h1>
              <p className="text-muted-foreground">Manage your financial accounts</p>
            </div>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setShowBalances(!showBalances)}
              className="text-[color:var(--sfms-neutral-dark)]"
            >
              {showBalances ? <Eye className="w-4 h-4" /> : <EyeOff className="w-4 h-4" />}
            </Button>
          </div>
        </motion.div>
      </div>

      {/* Summary Cards */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.1 }}
        className="grid grid-cols-2 gap-4"
      >
        <Card className="border-[color:var(--sfms-success)]/20">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <PieChart className="w-4 h-4 text-[color:var(--sfms-success)]" />
              <span className="text-sm font-medium">Total Balance</span>
            </div>
            <p className="text-2xl font-bold text-[color:var(--sfms-success)]">
              {showBalances ? formatCurrency(totalBalance) : '••••••'}
            </p>
          </CardContent>
        </Card>

        <Card className="border-[color:var(--sfms-ai)]/20">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <TrendingUp className="w-4 h-4 text-[color:var(--sfms-ai)]" />
              <span className="text-sm font-medium">Savings & Investments</span>
            </div>
            <p className="text-2xl font-bold text-[color:var(--sfms-ai)]">
              {showBalances ? formatCurrency(totalSavings) : '••••••'}
            </p>
          </CardContent>
        </Card>
      </motion.div>

      {/* Account List */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.2 }}
        className="space-y-4"
      >
        <div className="flex justify-between items-center">
          <h2 className="text-lg font-medium">Your Accounts</h2>
          <Button size="sm" className="gradient-success text-white">
            <Plus className="w-4 h-4 mr-1" />
            Add Account
          </Button>
        </div>

        {accounts.map((account, index) => (
          <motion.div
            key={account.id}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.3, delay: 0.3 + index * 0.1 }}
          >
            <Card className="shadow-lg hover:shadow-xl transition-shadow cursor-pointer">
              <CardContent className="p-4">
                <div className="space-y-4">
                  {/* Header */}
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className={`p-2 rounded-lg bg-[color:var(--sfms-neutral-light)] ${getTypeColor(account.type)}`}>
                        {getTypeIcon(account.type)}
                      </div>
                      <div>
                        <h3 className="font-medium">{account.name}</h3>
                        <p className="text-sm text-muted-foreground">
                          Last activity: {account.lastTransaction}
                        </p>
                      </div>
                    </div>
                    <Badge className={`text-xs ${getTypeBadgeColor(account.type)}`}>
                      {account.type.charAt(0).toUpperCase() + account.type.slice(1)}
                    </Badge>
                  </div>

                  {/* Balance and Interest */}
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <p className="text-sm text-muted-foreground">Balance</p>
                      <p className={`text-2xl font-bold ${getTypeColor(account.type)}`}>
                        {showBalances ? formatCurrency(account.balance) : '••••••'}
                      </p>
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground">Interest Rate</p>
                      <p className="text-2xl font-bold text-[color:var(--sfms-success)]">
                        {account.interestRate ? `${account.interestRate}%` : 'N/A'}
                      </p>
                    </div>
                  </div>

                  {/* Progress based on account type */}
                  {account.type === 'savings' && (
                    <div className="space-y-2">
                      <div className="flex justify-between text-sm">
                        <span>Savings Goal Progress</span>
                        <span>65%</span>
                      </div>
                      <div className="w-full bg-[color:var(--sfms-neutral-light)] rounded-full h-2">
                        <div 
                          className="bg-[color:var(--sfms-success)] h-2 rounded-full transition-all duration-300"
                          style={{ width: '65%' }}
                        ></div>
                      </div>
                    </div>
                  )}

                  {/* Action Buttons */}
                  <div className="flex gap-2">
                    <Button size="sm" variant="outline" className="flex-1">
                      Transfer
                    </Button>
                    <Button size="sm" variant="outline" className="flex-1">
                      Details
                    </Button>
                    {account.type === 'checking' && (
                      <Button size="sm" className="gradient-warning text-white flex-1">
                        Pay Bills
                      </Button>
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        ))}
      </motion.div>

      {/* Account Insights */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.5 }}
        className="space-y-4"
      >
        {/* Monthly Interest Earnings */}
        <Card className="border-[color:var(--sfms-success)]/20 bg-gradient-to-br from-[color:var(--sfms-success-light)] to-white">
          <CardHeader>
            <CardTitle className="text-[color:var(--sfms-success)] flex items-center gap-2">
              <DollarSign className="w-5 h-5" />
              Monthly Interest Earnings
            </CardTitle>
            <CardDescription>Projected earnings from all accounts</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-3 gap-4 text-center">
              <div>
                <p className="text-sm text-muted-foreground">This Month</p>
                <p className="text-xl font-bold text-[color:var(--sfms-success)]">RM 285</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Next Month</p>
                <p className="text-xl font-bold text-[color:var(--sfms-success)]">RM 292</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Annual</p>
                <p className="text-xl font-bold text-[color:var(--sfms-success)]">RM 3,450</p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Account Allocation */}
        <Card className="border-[color:var(--sfms-ai)]/20 bg-gradient-to-br from-[color:var(--sfms-ai-light)] to-white">
          <CardHeader>
            <CardTitle className="text-[color:var(--sfms-ai)] flex items-center gap-2">
              <PieChart className="w-5 h-5" />
              Account Allocation
            </CardTitle>
            <CardDescription>Distribution of your funds</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {accounts.map((account) => {
                const percentage = (account.balance / totalBalance) * 100;
                return (
                  <div key={account.id} className="space-y-2">
                    <div className="flex justify-between text-sm">
                      <span>{account.name}</span>
                      <span className="font-medium">{percentage.toFixed(1)}%</span>
                    </div>
                    <div className="w-full bg-[color:var(--sfms-neutral-light)] rounded-full h-2">
                      <div 
                        className={`h-2 rounded-full transition-all duration-300 ${
                          account.type === 'checking' ? 'bg-[color:var(--sfms-warning)]' :
                          account.type === 'savings' ? 'bg-[color:var(--sfms-success)]' :
                          account.type === 'investment' ? 'bg-[color:var(--sfms-ai)]' :
                          'bg-purple-500'
                        }`}
                        style={{ width: `${percentage}%` }}
                      ></div>
                    </div>
                  </div>
                );
              })}
            </div>
          </CardContent>
        </Card>
      </motion.div>

      {/* Action Buttons */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.6 }}
        className="grid grid-cols-2 gap-3"
      >
        <Button variant="outline" className="h-12">
          <Building className="w-4 h-4 mr-2" />
          Find Better Rates
        </Button>
        <Button className="gradient-success text-white h-12">
          <Plus className="w-4 h-4 mr-2" />
          Open Account
        </Button>
      </motion.div>
    </div>
  );
}