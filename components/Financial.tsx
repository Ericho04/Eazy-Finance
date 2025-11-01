import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Progress } from "./ui/progress";
import { 
  TrendingUp, 
  Calculator,
  LineChart,
  CreditCard,
  Eye,
  EyeOff,
  Sparkles,
  ChevronRight,
  PieChart,
  Wallet,
  FileText,
  BarChart3,
  Target,
  DollarSign
} from "lucide-react";
import { motion } from "motion/react";
import { useApp } from "../utils/AppContext";

interface FinancialProps {
  onNavigate: (section: string) => void;
}

export function Financial({ onNavigate }: FinancialProps) {
  const { state, calculateTotals } = useApp();
  const [showBalances, setShowBalances] = useState(true);
  const [showStealthSavings, setShowStealthSavings] = useState(false);
  const [selectedTimeframe, setSelectedTimeframe] = useState('1M');
  
  // Demo Stealth Savings amount
  const stealthSavingsAmount = 12500;
  
  // Demo financial data totals
  const totalDebts = 328500; // Total from all debts
  const totalAccounts = 118500; // Total from all accounts
  const netWorth = totalAccounts + stealthSavingsAmount - totalDebts;
  const totalAssets = totalAccounts + stealthSavingsAmount;
  
  // Financial ratios
  const { totalIncome, totalExpenses } = calculateTotals();
  const debtToIncomeRatio = totalIncome > 0 ? (totalDebts / (totalIncome * 12)) * 100 : 0;
  const savingsRate = totalIncome > 0 ? ((totalIncome - totalExpenses) / totalIncome) * 100 : 0;
  const emergencyFundMonths = totalExpenses > 0 ? totalAccounts / totalExpenses : 0;
  const stealthSavingsRate = totalIncome > 0 ? (stealthSavingsAmount / (totalIncome * 12)) * 100 : 0;

  const formatCurrency = (amount: number) => {
    return `RM ${amount.toLocaleString('en-MY', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`;
  };

  const getHealthColor = (value: number, type: 'debt-ratio' | 'savings-rate' | 'emergency-fund' | 'stealth-savings') => {
    switch (type) {
      case 'debt-ratio':
        if (value <= 20) return 'text-cartoon-mint';
        if (value <= 35) return 'text-cartoon-yellow';
        return 'text-cartoon-pink';
      case 'savings-rate':
        if (value >= 20) return 'text-cartoon-mint';
        if (value >= 10) return 'text-cartoon-yellow';
        return 'text-cartoon-pink';
      case 'emergency-fund':
        if (value >= 6) return 'text-cartoon-mint';
        if (value >= 3) return 'text-cartoon-yellow';
        return 'text-cartoon-pink';
      case 'stealth-savings':
        if (value >= 15) return 'text-cartoon-mint';
        if (value >= 10) return 'text-cartoon-yellow';
        return 'text-cartoon-pink';
      default:
        return 'text-gray-600';
    }
  };

  const getHealthProgress = (value: number, type: 'debt-ratio' | 'savings-rate' | 'emergency-fund' | 'stealth-savings') => {
    switch (type) {
      case 'debt-ratio':
        return Math.min(value, 100);
      case 'savings-rate':
        return Math.min(value, 100);
      case 'emergency-fund':
        return Math.min(value / 6 * 100, 100);
      case 'stealth-savings':
        return Math.min(value, 100);
      default:
        return 0;
    }
  };

  return (
    <div className="min-h-screen pb-32">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="px-6 pt-8 pb-4"
      >
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold bg-gradient-to-r from-cartoon-purple to-cartoon-pink bg-clip-text text-transparent">
              Financial Hub
            </h1>
            <p className="text-gray-600 mt-1">Your complete wealth overview</p>
          </div>
          <motion.div
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
          >
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setShowBalances(!showBalances)}
              className="cartoon-button bg-white/80 backdrop-blur-sm"
            >
              {showBalances ? (
                <Eye className="w-5 h-5 text-cartoon-blue" />
              ) : (
                <EyeOff className="w-5 h-5 text-cartoon-blue" />
              )}
            </Button>
          </motion.div>
        </div>
      </motion.div>

      <div className="px-6 space-y-6">
        {/* Net Worth Summary */}
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.6, delay: 0.1 }}
        >
          <Card className="cartoon-card bg-gradient-to-br from-cartoon-blue/10 to-cartoon-cyan/10 border-cartoon-blue/20">
            <CardHeader className="pb-4">
              <CardTitle className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <motion.div
                    className="w-12 h-12 rounded-full cartoon-gradient-blue flex items-center justify-center"
                    whileHover={{ rotate: 360 }}
                    transition={{ duration: 0.8 }}
                  >
                    <Calculator className="w-6 h-6 text-white" />
                  </motion.div>
                  <div>
                    <span className="text-cartoon-blue font-bold text-lg">Net Worth</span>
                    <p className="text-sm text-gray-600">Total financial position</p>
                  </div>
                </div>
                <div className="flex gap-2">
                  {['1W', '1M', '3M', '1Y'].map((period) => (
                    <Button
                      key={period}
                      variant={selectedTimeframe === period ? "default" : "ghost"}
                      size="sm"
                      onClick={() => setSelectedTimeframe(period)}
                      className={`text-xs h-8 px-3 cartoon-button ${
                        selectedTimeframe === period 
                          ? 'cartoon-gradient-blue text-white' 
                          : 'bg-white/50 text-cartoon-blue hover:bg-white/80'
                      }`}
                    >
                      {period}
                    </Button>
                  ))}
                </div>
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-6">
                <div className="text-center">
                  <motion.h2
                    className="text-4xl font-bold text-cartoon-blue"
                    initial={{ scale: 0.8 }}
                    animate={{ scale: 1 }}
                    transition={{ duration: 0.5, delay: 0.3 }}
                  >
                    {showBalances ? formatCurrency(netWorth) : '••••••'}
                  </motion.h2>
                  <div className="flex items-center justify-center gap-2 mt-2">
                    <TrendingUp className="w-5 h-5 text-cartoon-mint" />
                    <span className="text-cartoon-mint font-semibold">+2.5%</span>
                    <span className="text-gray-500">({selectedTimeframe})</span>
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-4">
                  <motion.div
                    className="text-center p-4 rounded-2xl bg-white/50 backdrop-blur-sm"
                    whileHover={{ scale: 1.05 }}
                    transition={{ duration: 0.2 }}
                  >
                    <DollarSign className="w-6 h-6 text-cartoon-mint mx-auto mb-2" />
                    <p className="text-sm text-gray-600">Assets</p>
                    <p className="font-bold text-cartoon-mint">
                      {showBalances ? formatCurrency(totalAssets) : '••••'}
                    </p>
                  </motion.div>
                  <motion.div
                    className="text-center p-4 rounded-2xl bg-white/50 backdrop-blur-sm"
                    whileHover={{ scale: 1.05 }}
                    transition={{ duration: 0.2 }}
                  >
                    <CreditCard className="w-6 h-6 text-cartoon-pink mx-auto mb-2" />
                    <p className="text-sm text-gray-600">Debts</p>
                    <p className="font-bold text-cartoon-pink">
                      {showBalances ? formatCurrency(totalDebts) : '••••'}
                    </p>
                  </motion.div>
                  <motion.div
                    className="text-center p-4 rounded-2xl bg-white/50 backdrop-blur-sm"
                    whileHover={{ scale: 1.05 }}
                    transition={{ duration: 0.2 }}
                  >
                    <Wallet className="w-6 h-6 text-cartoon-yellow mx-auto mb-2" />
                    <p className="text-sm text-gray-600">Liquidity</p>
                    <p className="font-bold text-cartoon-yellow">
                      {showBalances ? formatCurrency(totalAccounts) : '••••'}
                    </p>
                  </motion.div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* Financial Health Metrics */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
        >
          <Card className="cartoon-card bg-white/80 backdrop-blur-sm">
            <CardHeader>
              <CardTitle className="flex items-center gap-3">
                <motion.div
                  className="w-10 h-10 rounded-full cartoon-gradient-purple flex items-center justify-center"
                  whileHover={{ rotate: 180 }}
                  transition={{ duration: 0.5 }}
                >
                  <LineChart className="w-5 h-5 text-white" />
                </motion.div>
                <div>
                  <span className="text-cartoon-purple font-bold">Financial Health Score</span>
                  <p className="text-sm text-gray-600 font-normal">Key financial indicators</p>
                </div>
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {/* Debt-to-Income Ratio */}
              <motion.div
                className="p-4 rounded-2xl bg-gradient-to-r from-gray-50 to-white border border-gray-100"
                whileHover={{ scale: 1.02 }}
                transition={{ duration: 0.2 }}
              >
                <div className="flex justify-between items-center mb-3">
                  <span className="font-semibold text-gray-800">Debt-to-Income Ratio</span>
                  <span className={`font-bold text-lg ${getHealthColor(debtToIncomeRatio, 'debt-ratio')}`}>
                    {debtToIncomeRatio.toFixed(1)}%
                  </span>
                </div>
                <div className="relative">
                  <Progress 
                    value={getHealthProgress(debtToIncomeRatio, 'debt-ratio')} 
                    className="h-3 bg-gray-200"
                  />
                  <div className="absolute inset-0 rounded-full bg-gradient-to-r from-cartoon-mint/20 to-cartoon-pink/20" />
                </div>
                <p className="text-sm text-gray-600 mt-2">
                  {debtToIncomeRatio <= 20 ? '✨ Excellent' : debtToIncomeRatio <= 35 ? '👍 Good' : '⚠️ Needs Attention'}
                </p>
              </motion.div>

              {/* Savings Rate */}
              <motion.div
                className="p-4 rounded-2xl bg-gradient-to-r from-gray-50 to-white border border-gray-100"
                whileHover={{ scale: 1.02 }}
                transition={{ duration: 0.2 }}
              >
                <div className="flex justify-between items-center mb-3">
                  <span className="font-semibold text-gray-800">Savings Rate</span>
                  <span className={`font-bold text-lg ${getHealthColor(savingsRate, 'savings-rate')}`}>
                    {savingsRate.toFixed(1)}%
                  </span>
                </div>
                <div className="relative">
                  <Progress 
                    value={getHealthProgress(savingsRate, 'savings-rate')} 
                    className="h-3 bg-gray-200"
                  />
                  <div className="absolute inset-0 rounded-full bg-gradient-to-r from-cartoon-mint/20 to-cartoon-yellow/20" />
                </div>
                <p className="text-sm text-gray-600 mt-2">
                  {savingsRate >= 20 ? '🎯 Excellent' : savingsRate >= 10 ? '📈 Good' : '💪 Improve Needed'}
                </p>
              </motion.div>

              {/* Emergency Fund */}
              <motion.div
                className="p-4 rounded-2xl bg-gradient-to-r from-gray-50 to-white border border-gray-100"
                whileHover={{ scale: 1.02 }}
                transition={{ duration: 0.2 }}
              >
                <div className="flex justify-between items-center mb-3">
                  <span className="font-semibold text-gray-800">Emergency Fund</span>
                  <span className={`font-bold text-lg ${getHealthColor(emergencyFundMonths, 'emergency-fund')}`}>
                    {emergencyFundMonths.toFixed(1)} months
                  </span>
                </div>
                <div className="relative">
                  <Progress 
                    value={getHealthProgress(emergencyFundMonths, 'emergency-fund')} 
                    className="h-3 bg-gray-200"
                  />
                  <div className="absolute inset-0 rounded-full bg-gradient-to-r from-cartoon-mint/20 to-cartoon-cyan/20" />
                </div>
                <p className="text-sm text-gray-600 mt-2">
                  {emergencyFundMonths >= 6 ? '🛡️ Excellent' : emergencyFundMonths >= 3 ? '🔒 Good' : '🏗️ Build Up Needed'}
                </p>
              </motion.div>

              {/* Stealth Savings */}
              <motion.div
                className="p-4 rounded-2xl bg-gradient-to-r from-cartoon-purple/10 to-cartoon-pink/10 border border-cartoon-purple/20"
                whileHover={{ scale: 1.02 }}
                transition={{ duration: 0.2 }}
              >
                <div className="flex justify-between items-center mb-3">
                  <div className="flex items-center gap-2">
                    <Sparkles className="w-5 h-5 text-cartoon-purple" />
                    <span className="font-semibold text-cartoon-purple">Stealth Savings</span>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className={`font-bold text-lg ${getHealthColor(stealthSavingsRate, 'stealth-savings')}`}>
                      {showStealthSavings ? `${stealthSavingsRate.toFixed(1)}%` : '••••'}
                    </span>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setShowStealthSavings(!showStealthSavings)}
                      className="h-8 w-8 p-0 text-cartoon-purple hover:bg-cartoon-purple/10"
                    >
                      {showStealthSavings ? <Eye className="w-4 h-4" /> : <EyeOff className="w-4 h-4" />}
                    </Button>
                  </div>
                </div>
                <div className="relative">
                  <Progress 
                    value={getHealthProgress(stealthSavingsRate, 'stealth-savings')} 
                    className="h-3 bg-cartoon-purple/20"
                  />
                  <div className="absolute inset-0 rounded-full bg-gradient-to-r from-cartoon-purple/20 to-cartoon-pink/20" />
                </div>
                <div className="flex justify-between items-center mt-3">
                  <p className="text-sm text-cartoon-purple font-medium">
                    Hidden fund: {showStealthSavings ? formatCurrency(stealthSavingsAmount) : '••••••'}
                  </p>
                  <p className="text-sm text-gray-600">
                    {stealthSavingsRate >= 15 ? '🚀 Excellent' : stealthSavingsRate >= 10 ? '📊 Good' : '💎 Build More'}
                  </p>
                </div>
              </motion.div>
            </CardContent>
          </Card>
        </motion.div>

        {/* Financial Management Cards - Only Debts and Tax Planning */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.3 }}
          className="grid grid-cols-1 gap-4"
        >
          {/* Debts Card */}
          <motion.div
            whileHover={{ scale: 1.02, y: -4 }}
            whileTap={{ scale: 0.98 }}
            transition={{ duration: 0.2 }}
          >
            <Card 
              className="cartoon-card bg-gradient-to-br from-cartoon-pink/10 to-cartoon-pink/5 border-cartoon-pink/20 cursor-pointer"
              onClick={() => onNavigate('financial-debts')}
            >
              <CardContent className="p-6">
                <div className="flex items-center justify-between mb-4">
                  <div className="flex items-center gap-4">
                    <motion.div
                      className="w-14 h-14 rounded-full cartoon-gradient-pink flex items-center justify-center"
                      whileHover={{ rotate: 360 }}
                      transition={{ duration: 0.8 }}
                    >
                      <CreditCard className="w-7 h-7 text-white" />
                    </motion.div>
                    <div>
                      <h3 className="text-lg font-bold text-cartoon-pink">Debt Management</h3>
                      <p className="text-sm text-gray-600">Track and pay off debts</p>
                    </div>
                  </div>
                  <ChevronRight className="w-6 h-6 text-gray-400" />
                </div>
                <div className="space-y-3">
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-600">Total Debt</span>
                    <span className="text-2xl font-bold text-cartoon-pink">
                      {showBalances ? formatCurrency(totalDebts) : '••••••'}
                    </span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-600">Active Accounts</span>
                    <span className="text-lg font-semibold text-gray-800">3 accounts</span>
                  </div>
                  <div className="flex items-center gap-2 mt-3">
                    <div className="w-3 h-3 rounded-full bg-cartoon-pink"></div>
                    <span className="text-sm text-cartoon-pink font-medium">Needs attention</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* Tax Planning Card */}
          <motion.div
            whileHover={{ scale: 1.02, y: -4 }}
            whileTap={{ scale: 0.98 }}
            transition={{ duration: 0.2 }}
          >
            <Card 
              className="cartoon-card bg-gradient-to-br from-cartoon-purple/10 to-cartoon-purple/5 border-cartoon-purple/20 cursor-pointer"
              onClick={() => onNavigate('financial-tax')}
            >
              <CardContent className="p-6">
                <div className="flex items-center justify-between mb-4">
                  <div className="flex items-center gap-4">
                    <motion.div
                      className="w-14 h-14 rounded-full cartoon-gradient-purple flex items-center justify-center"
                      whileHover={{ rotate: 360 }}
                      transition={{ duration: 0.8 }}
                    >
                      <FileText className="w-7 h-7 text-white" />
                    </motion.div>
                    <div>
                      <h3 className="text-lg font-bold text-cartoon-purple">Tax Planning</h3>
                      <p className="text-sm text-gray-600">Optimize your tax savings</p>
                    </div>
                  </div>
                  <ChevronRight className="w-6 h-6 text-gray-400" />
                </div>
                <div className="space-y-3">
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-600">Est. Tax Savings</span>
                    <span className="text-2xl font-bold text-cartoon-purple">RM 2,400</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-600">Tax Year</span>
                    <span className="text-lg font-semibold text-gray-800">2024</span>
                  </div>
                  <div className="flex items-center gap-2 mt-3">
                    <div className="w-3 h-3 rounded-full bg-cartoon-mint"></div>
                    <span className="text-sm text-cartoon-mint font-medium">Optimized</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </motion.div>

        {/* Quick Action Buttons */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="grid grid-cols-2 gap-4"
        >
          <motion.div
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            <Button 
              onClick={() => onNavigate('reports')}
              className="w-full h-14 cartoon-button bg-white/80 backdrop-blur-sm text-cartoon-blue border border-cartoon-blue/20 hover:bg-cartoon-blue/10"
              variant="outline"
            >
              <PieChart className="w-5 h-5 mr-3" />
              Financial Reports
            </Button>
          </motion.div>
          
          <motion.div
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            <Button 
              onClick={() => onNavigate('dashboard')}
              className="w-full h-14 cartoon-button cartoon-gradient-blue text-white hover:shadow-xl"
            >
              <Target className="w-5 h-5 mr-3" />
              Back to Dashboard
            </Button>
          </motion.div>
        </motion.div>
      </div>
    </div>
  );
}