import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";
import { Alert, AlertDescription } from "./ui/alert";
import { 
  ArrowLeft,
  CreditCard,
  Building,
  Wallet,
  Plus,
  AlertTriangle,
  TrendingDown,
  Calculator,
  Calendar
} from "lucide-react";
import { motion } from "motion/react";

interface FinancialDebtsProps {
  onBack: () => void;
}

interface Debt {
  id: string;
  name: string;
  type: 'credit_card' | 'personal_loan' | 'home_loan' | 'car_loan' | 'education_loan' | 'other';
  balance: number;
  interestRate: number;
  minimumPayment: number;
  dueDate: string;
}

export function FinancialDebts({ onBack }: FinancialDebtsProps) {
  const [debts] = useState<Debt[]>([
    {
      id: '1',
      name: 'Credit Card - Maybank',
      type: 'credit_card',
      balance: 3500,
      interestRate: 18.0,
      minimumPayment: 175,
      dueDate: '2024-01-15'
    },
    {
      id: '2',
      name: 'Car Loan - Honda',
      type: 'car_loan', 
      balance: 45000,
      interestRate: 2.8,
      minimumPayment: 890,
      dueDate: '2024-01-28'
    },
    {
      id: '3',
      name: 'Home Loan - CIMB',
      type: 'home_loan',
      balance: 280000,
      interestRate: 4.2,
      minimumPayment: 1450,
      dueDate: '2024-01-01'
    }
  ]);

  const totalDebts = debts.reduce((sum, debt) => sum + debt.balance, 0);
  const totalMonthlyPayments = debts.reduce((sum, debt) => sum + debt.minimumPayment, 0);
  const highestInterestRate = Math.max(...debts.map(debt => debt.interestRate));

  const formatCurrency = (amount: number) => {
    return `RM ${amount.toLocaleString('en-MY', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`;
  };

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'credit_card': return <CreditCard className="w-4 h-4" />;
      case 'home_loan': return <Building className="w-4 h-4" />;
      case 'car_loan': return <Wallet className="w-4 h-4" />;
      default: return <CreditCard className="w-4 h-4" />;
    }
  };

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'credit_card': return 'text-[color:var(--sfms-danger)]';
      case 'home_loan': return 'text-[color:var(--sfms-warning)]';
      case 'car_loan': return 'text-[color:var(--sfms-neutral-dark)]';
      default: return 'text-[color:var(--sfms-danger)]';
    }
  };

  const getDaysUntilDue = (dueDate: string) => {
    const due = new Date(dueDate);
    const today = new Date();
    const diffTime = due.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
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
          <div className="flex-1">
            <h1 className="text-2xl text-[color:var(--sfms-danger)]">Outstanding Debts</h1>
            <p className="text-muted-foreground">Manage and track your debt payments</p>
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
        <Card className="border-[color:var(--sfms-danger)]/20">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <TrendingDown className="w-4 h-4 text-[color:var(--sfms-danger)]" />
              <span className="text-sm font-medium">Total Debt</span>
            </div>
            <p className="text-2xl font-bold text-[color:var(--sfms-danger)]">
              {formatCurrency(totalDebts)}
            </p>
          </CardContent>
        </Card>

        <Card className="border-[color:var(--sfms-warning)]/20">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <Calculator className="w-4 h-4 text-[color:var(--sfms-warning)]" />
              <span className="text-sm font-medium">Monthly Payments</span>
            </div>
            <p className="text-2xl font-bold text-[color:var(--sfms-warning)]">
              {formatCurrency(totalMonthlyPayments)}
            </p>
          </CardContent>
        </Card>
      </motion.div>

      {/* Debt List */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.2 }}
        className="space-y-4"
      >
        <div className="flex justify-between items-center">
          <h2 className="text-lg font-medium">Your Debts</h2>
          <Button size="sm" className="gradient-danger text-white">
            <Plus className="w-4 h-4 mr-1" />
            Add Debt
          </Button>
        </div>

        {debts.map((debt, index) => {
          const daysUntilDue = getDaysUntilDue(debt.dueDate);
          const isOverdue = daysUntilDue < 0;
          const isUrgent = daysUntilDue <= 7 && daysUntilDue >= 0;

          return (
            <motion.div
              key={debt.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.3, delay: 0.3 + index * 0.1 }}
            >
              <Card className="shadow-lg border-l-4 border-l-[color:var(--sfms-danger)]">
                <CardContent className="p-4">
                  <div className="space-y-4">
                    {/* Header */}
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div className={`p-2 rounded-lg bg-[color:var(--sfms-neutral-light)] ${getTypeColor(debt.type)}`}>
                          {getTypeIcon(debt.type)}
                        </div>
                        <div>
                          <h3 className="font-medium">{debt.name}</h3>
                          <p className="text-sm text-muted-foreground capitalize">
                            {debt.type.replace('_', ' ')}
                          </p>
                        </div>
                      </div>
                      <Badge 
                        variant={debt.interestRate > 10 ? "destructive" : "secondary"}
                        className="text-xs"
                      >
                        {debt.interestRate}% APR
                      </Badge>
                    </div>

                    {/* Balance and Payment Info */}
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <p className="text-sm text-muted-foreground">Outstanding Balance</p>
                        <p className="text-xl font-bold text-[color:var(--sfms-danger)]">
                          {formatCurrency(debt.balance)}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-muted-foreground">Minimum Payment</p>
                        <p className="text-xl font-bold">
                          {formatCurrency(debt.minimumPayment)}
                        </p>
                      </div>
                    </div>

                    {/* Due Date and Actions */}
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <Calendar className="w-4 h-4 text-muted-foreground" />
                        <span className="text-sm">Due: {debt.dueDate}</span>
                        <Badge 
                          variant={isOverdue ? "destructive" : isUrgent ? "default" : "secondary"}
                          className="text-xs"
                        >
                          {isOverdue ? `${Math.abs(daysUntilDue)} days overdue` : 
                           isUrgent ? `${daysUntilDue} days left` : 
                           `${daysUntilDue} days left`}
                        </Badge>
                      </div>
                      <div className="flex gap-2">
                        <Button size="sm" variant="outline">
                          Pay
                        </Button>
                        <Button size="sm" variant="ghost">
                          Details
                        </Button>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          );
        })}
      </motion.div>

      {/* Debt Management Tips */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.5 }}
        className="space-y-4"
      >
        <Alert className="border-[color:var(--sfms-warning)]/30 bg-[color:var(--sfms-warning-light)]">
          <AlertTriangle className="h-4 w-4 text-[color:var(--sfms-warning)]" />
          <AlertDescription className="text-[color:var(--sfms-warning)]">
            <span className="font-medium">Debt Strategy:</span> Focus on paying off your credit card first 
            (highest interest rate at {highestInterestRate}%). Consider debt consolidation for better rates.
          </AlertDescription>
        </Alert>

        {/* Debt Payoff Calculator */}
        <Card className="border-[color:var(--sfms-ai)]/20 bg-gradient-to-br from-[color:var(--sfms-ai-light)] to-white">
          <CardHeader>
            <CardTitle className="text-[color:var(--sfms-ai)] flex items-center gap-2">
              <Calculator className="w-5 h-5" />
              Debt Payoff Calculator
            </CardTitle>
            <CardDescription>See how extra payments can save you money</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 gap-4 text-center">
              <div>
                <p className="text-sm text-muted-foreground">Current Timeline</p>
                <p className="text-xl font-bold text-[color:var(--sfms-ai)]">8.5 years</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Total Interest</p>
                <p className="text-xl font-bold text-[color:var(--sfms-danger)]">RM 45,200</p>
              </div>
            </div>
            <Button className="w-full mt-4 gradient-ai text-white">
              Calculate Payoff Strategy
            </Button>
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
          <AlertTriangle className="w-4 h-4 mr-2" />
          Debt Consolidation
        </Button>
        <Button className="gradient-success text-white h-12">
          <Plus className="w-4 h-4 mr-2" />
          Payment Plan
        </Button>
      </motion.div>
    </div>
  );
}