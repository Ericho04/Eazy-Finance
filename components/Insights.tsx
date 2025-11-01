import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { 
  TrendingUp, 
  PieChart, 
  BarChart3, 
  DollarSign,
  Calendar,
  Filter,
  Target,
  Award,
  Sparkles,
  ChevronRight,
  CreditCard,
  Landmark,
  Receipt,
  Calculator,
  Brain,
  ExternalLink,
  TrendingDown,
  AlertCircle,
  CheckCircle,
  Lightbulb,
  Shield,
  PiggyBank,
  BookOpen,
  Users
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { useApp } from '../utils/AppContext';

interface InsightsProps {
  onNavigate: (section: string) => void;
  user?: any;
}

export function Insights({ onNavigate, user }: InsightsProps) {
  const { state } = useApp();
  const [timeRange, setTimeRange] = useState('month');
  const [activeTab, setActiveTab] = useState('overview');
  
  // Sample insights data with enhanced metrics
  const monthlySpending = [
    { category: 'Food & Dining', amount: 450, percentage: 35, trend: '+12%', budget: 400, emoji: '🍽️' },
    { category: 'Transportation', amount: 280, percentage: 22, trend: '-5%', budget: 350, emoji: '🚗' },
    { category: 'Shopping', amount: 320, percentage: 25, trend: '+8%', budget: 250, emoji: '🛍️' },
    { category: 'Entertainment', amount: 150, percentage: 12, trend: '-2%', budget: 200, emoji: '🎬' },
    { category: 'Others', amount: 80, percentage: 6, trend: '+3%', budget: 100, emoji: '📦' }
  ];

  // AI Financial Tips based on spending patterns
  const generateAITips = () => {
    const tips = [];
    const totalSpending = monthlySpending.reduce((sum, item) => sum + item.amount, 0);
    const totalBudget = monthlySpending.reduce((sum, item) => sum + item.budget, 0);
    
    // Overspending analysis
    monthlySpending.forEach(category => {
      if (category.amount > category.budget) {
        const overspend = category.amount - category.budget;
        const overspendPercentage = ((overspend / category.budget) * 100).toFixed(0);
        tips.push({
          type: 'warning',
          category: 'Budget Alert',
          title: `${category.category} Over Budget`,
          message: `You've exceeded your ${category.category.toLowerCase()} budget by RM${overspend.toFixed(2)} (${overspendPercentage}%). Consider reviewing your spending habits in this category.`,
          action: 'Review Budget',
          emoji: category.emoji,
          priority: 'high',
          savings: overspend
        });
      }
    });

    // High percentage category tips
    const topCategory = monthlySpending[0];
    if (topCategory.percentage > 30) {
      let tipMessage = '';
      let savingsAmount = 0;
      
      if (topCategory.category === 'Food & Dining') {
        savingsAmount = topCategory.amount * 0.3;
        tipMessage = `${topCategory.percentage}% of your spending goes to dining. Try meal prepping 3 days a week to save approximately RM${savingsAmount.toFixed(0)}/month!`;
      } else if (topCategory.category === 'Shopping') {
        savingsAmount = topCategory.amount * 0.2;
        tipMessage = `Shopping takes up ${topCategory.percentage}% of your budget. Consider implementing a 24-hour rule before purchases to reduce impulse buying by RM${savingsAmount.toFixed(0)}/month.`;
      } else if (topCategory.category === 'Transportation') {
        savingsAmount = topCategory.amount * 0.15;
        tipMessage = `Transportation costs are high at ${topCategory.percentage}%. Consider carpooling or public transport to save RM${savingsAmount.toFixed(0)}/month.`;
      }
      
      tips.push({
        type: 'improvement',
        category: 'Spending Optimization',
        title: `${topCategory.category} Dominates Your Budget`,
        message: tipMessage,
        action: 'See Strategies',
        emoji: topCategory.emoji,
        priority: 'medium',
        savings: savingsAmount
      });
    }

    // Positive spending trends
    const improvingCategories = monthlySpending.filter(cat => cat.trend.startsWith('-'));
    if (improvingCategories.length > 0) {
      const bestImprovement = improvingCategories[0];
      tips.push({
        type: 'success',
        category: 'Great Progress',
        title: `Excellent Control in ${bestImprovement.category}!`,
        message: `Your ${bestImprovement.category.toLowerCase()} spending decreased by ${bestImprovement.trend}. Keep up the great work! This discipline could save you RM${(bestImprovement.amount * 0.1).toFixed(0)} more next month.`,
        action: 'Keep It Up',
        emoji: '🎉',
        priority: 'low',
        savings: bestImprovement.amount * 0.1
      });
    }

    // Financial wellness tips
    tips.push({
      type: 'education',
      category: 'Financial Wellness',
      title: 'Emergency Fund Check',
      message: 'A healthy emergency fund should cover 3-6 months of expenses. Based on your spending patterns, aim for RM3,840-7,680 in emergency savings.',
      action: 'Learn More',
      emoji: '🛡️',
      priority: 'medium',
      savings: 0,
      link: 'https://www.investopedia.com/articles/personal-finance/040915/how-much-should-you-have-your-emergency-fund.asp'
    });

    return tips.sort((a, b) => {
      const priorityOrder = { 'high': 3, 'medium': 2, 'low': 1 };
      return priorityOrder[b.priority] - priorityOrder[a.priority];
    });
  };

  const aiTips = generateAITips();

  // Financial education resources
  const educationalResources = [
    {
      category: 'Budgeting',
      title: '50/30/20 Budgeting Rule',
      description: 'Learn how to allocate your income effectively',
      emoji: '📊',
      color: 'from-blue-500 to-cyan-500',
      link: 'https://www.nerdwallet.com/article/finance/nerdwallet-budget-calculator'
    },
    {
      category: 'Saving',
      title: 'High-Yield Savings Accounts',
      description: 'Maximize your savings with better interest rates',
      emoji: '💰',
      color: 'from-green-500 to-emerald-500',
      link: 'https://www.bankrate.com/banking/savings/best-high-yield-interests-savings-accounts/'
    },
    {
      category: 'Investing',
      title: 'Investment Basics for Beginners',
      description: 'Start your investment journey with confidence',
      emoji: '📈',
      color: 'from-purple-500 to-indigo-500',
      link: 'https://www.investopedia.com/investing-4427685'
    },
    {
      category: 'Debt Management',
      title: 'Debt Snowball vs Avalanche',
      description: 'Choose the best strategy to pay off debts',
      emoji: '❄️',
      color: 'from-red-500 to-pink-500',
      link: 'https://www.ramseysolutions.com/debt/how-the-debt-snowball-method-works'
    },
    {
      category: 'Credit Score',
      title: 'Building Good Credit',
      description: 'Improve your credit score for better rates',
      emoji: '⭐',
      color: 'from-yellow-500 to-orange-500',
      link: 'https://www.myfico.com/credit-education/improve-your-credit-score'
    },
    {
      category: 'Insurance',
      title: 'Essential Insurance Coverage',
      description: 'Protect your financial future with proper coverage',
      emoji: '🛡️',
      color: 'from-teal-500 to-blue-500',
      link: 'https://www.investopedia.com/insurance-4427716'
    }
  ];

  // Financial wellness score calculation
  const calculateWellnessScore = () => {
    let score = 0;
    const maxScore = 100;
    
    // Budget adherence (40 points)
    const budgetAdherence = monthlySpending.reduce((acc, cat) => {
      return acc + (cat.amount <= cat.budget ? 1 : 0);
    }, 0);
    score += (budgetAdherence / monthlySpending.length) * 40;
    
    // Spending diversity (20 points) - no single category > 50%
    const maxCategoryPercentage = Math.max(...monthlySpending.map(cat => cat.percentage));
    score += maxCategoryPercentage < 50 ? 20 : (50 - maxCategoryPercentage) * 0.4;
    
    // Trend improvement (20 points)
    const improvingTrends = monthlySpending.filter(cat => cat.trend.startsWith('-')).length;
    score += (improvingTrends / monthlySpending.length) * 20;
    
    // Base financial activity (20 points)
    score += 20; // For having tracked expenses
    
    return Math.round(Math.min(score, maxScore));
  };

  const wellnessScore = calculateWellnessScore();

  const financialTools = [
    {
      id: 'debts',
      title: 'Debt Manager',
      description: 'Track and manage your debts',
      icon: CreditCard,
      emoji: '💳',
      color: 'from-red-400 to-pink-500',
      route: 'financial-debts'
    },
    {
      id: 'accounts',
      title: 'Accounts',
      description: 'Manage your bank accounts',
      icon: Landmark,
      emoji: '🏦',
      color: 'from-blue-400 to-cyan-500',
      route: 'financial-accounts'
    },
    {
      id: 'goals',
      title: 'Financial Goals',
      description: 'Set and track financial targets',
      icon: Target,
      emoji: '🎯',
      color: 'from-green-400 to-emerald-500',
      route: 'financial-goals'
    },
    {
      id: 'tax',
      title: 'Tax Planning',
      description: 'Plan your tax obligations',
      icon: Calculator,
      emoji: '📊',
      color: 'from-purple-400 to-indigo-500',
      route: 'financial-tax'
    }
  ];

  const totalSpending = monthlySpending.reduce((sum, item) => sum + item.amount, 0);
  const totalBudget = monthlySpending.reduce((sum, item) => sum + item.budget, 0);

  const formatCurrency = (amount: number) => {
    return `RM ${amount.toFixed(2)}`;
  };

  const getSpendingInsight = () => {
    const topCategory = monthlySpending[0];
    const budgetVariance = totalSpending - totalBudget;
    
    if (budgetVariance > 0) {
      return {
        type: 'warning',
        message: `Over budget by ${formatCurrency(budgetVariance)}`,
        emoji: '⚠️',
        detail: 'Consider reviewing your spending patterns'
      };
    } else if (topCategory.percentage > 40) {
      return {
        type: 'warning',
        message: `High concentration in ${topCategory.category}`,
        emoji: '📊',
        detail: `${topCategory.percentage}% of total spending`
      };
    } else if (budgetVariance < -100) {
      return {
        type: 'success',
        message: `Great job! Under budget by ${formatCurrency(Math.abs(budgetVariance))}`,
        emoji: '🎉',
        detail: 'Keep up the excellent spending discipline'
      };
    } else {
      return {
        type: 'info',
        message: 'Balanced spending pattern',
        emoji: '✅',
        detail: 'Your spending is well-distributed'
      };
    }
  };

  const spendingInsight = getSpendingInsight();

  const getWellnessLevel = (score: number) => {
    if (score >= 80) return { level: 'Excellent', color: 'text-green-600', bgColor: 'bg-green-100' };
    if (score >= 60) return { level: 'Good', color: 'text-blue-600', bgColor: 'bg-blue-100' };
    if (score >= 40) return { level: 'Fair', color: 'text-yellow-600', bgColor: 'bg-yellow-100' };
    return { level: 'Needs Improvement', color: 'text-red-600', bgColor: 'bg-red-100' };
  };

  const wellnessLevel = getWellnessLevel(wellnessScore);

  return (
    <div className="px-4 space-y-6 bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50">
      {/* Header */}
      <div className="pt-8">
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: "easeOut" }}
          className="text-center mb-6"
        >
          <motion.div
            animate={{ scale: [1, 1.1, 1] }}
            transition={{ duration: 2, repeat: Infinity, repeatDelay: 3 }}
            className="text-4xl mb-2"
          >
            🧠
          </motion.div>
          <h1 className="text-2xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
            AI Financial Insights
          </h1>
          <p className="text-gray-600 mt-1">Smart tips and spending analysis powered by AI</p>
        </motion.div>
      </div>

      {/* Tab Navigation */}
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5, delay: 0.1 }}
      >
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-3 cartoon-button bg-white/80 backdrop-blur-sm">
            <TabsTrigger value="overview" className="data-[state=active]:bg-gradient-to-r data-[state=active]:from-blue-500 data-[state=active]:to-purple-500 data-[state=active]:text-white">
              📊 Overview
            </TabsTrigger>
            <TabsTrigger value="ai-tips" className="data-[state=active]:bg-gradient-to-r data-[state=active]:from-purple-500 data-[state=active]:to-pink-500 data-[state=active]:text-white">
              🤖 AI Tips
            </TabsTrigger>
            <TabsTrigger value="resources" className="data-[state=active]:bg-gradient-to-r data-[state=active]:from-green-500 data-[state=active]:to-blue-500 data-[state=active]:text-white">
              📚 Learn
            </TabsTrigger>
          </TabsList>

          <TabsContent value="overview" className="space-y-6 mt-6">
            {/* Time Range Selector */}
            <div className="flex justify-center gap-2">
              {['week', 'month', 'year'].map((range) => (
                <Button
                  key={range}
                  onClick={() => setTimeRange(range)}
                  variant={timeRange === range ? "default" : "outline"}
                  className={`cartoon-button ${
                    timeRange === range 
                      ? 'bg-gradient-to-r from-blue-500 to-purple-500 text-white' 
                      : 'bg-white text-gray-700'
                  }`}
                >
                  {range.charAt(0).toUpperCase() + range.slice(1)}
                </Button>
              ))}
            </div>

            {/* Financial Wellness Score */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.5, delay: 0.2 }}
            >
              <Card className="cartoon-card bg-gradient-to-br from-green-50 to-emerald-50 border-0 overflow-hidden relative">
                <div className="absolute top-0 right-0 text-6xl opacity-10">🏆</div>
                <CardHeader className="pb-3">
                  <CardTitle className="flex items-center gap-3">
                    <motion.div
                      animate={{ scale: [1, 1.1, 1] }}
                      transition={{ duration: 2, repeat: Infinity }}
                      className="w-10 h-10 rounded-full bg-gradient-to-r from-green-400 to-emerald-400 flex items-center justify-center"
                    >
                      <Shield className="w-5 h-5 text-white" />
                    </motion.div>
                    <div>
                      <span className="text-lg font-bold text-gray-800">Financial Wellness Score</span>
                      <p className="text-sm text-gray-600 font-normal">Your overall financial health</p>
                    </div>
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-4">
                      <div className="text-4xl font-bold text-green-600">{wellnessScore}</div>
                      <div>
                        <Badge className={`${wellnessLevel.bgColor} ${wellnessLevel.color} border-0`}>
                          {wellnessLevel.level}
                        </Badge>
                        <p className="text-sm text-gray-600 mt-1">out of 100</p>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-2xl mb-1">
                        {wellnessScore >= 80 ? '🌟' : wellnessScore >= 60 ? '👍' : wellnessScore >= 40 ? '⚡' : '💪'}
                      </div>
                    </div>
                  </div>
                  <Progress 
                    value={wellnessScore} 
                    className="h-3 rounded-full [&>div]:bg-gradient-to-r [&>div]:from-green-400 [&>div]:to-emerald-400"
                  />
                </CardContent>
              </Card>
            </motion.div>

            {/* Spending Overview */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.5, delay: 0.3 }}
            >
              <Card className="cartoon-card bg-gradient-to-br from-white to-blue-50 border-0 overflow-hidden relative">
                <div className="absolute top-0 right-0 text-6xl opacity-10">📈</div>
                <CardHeader className="pb-3">
                  <CardTitle className="flex items-center gap-3">
                    <motion.div
                      animate={{ rotate: [0, 360] }}
                      transition={{ duration: 8, repeat: Infinity, ease: "linear" }}
                      className="w-10 h-10 rounded-full bg-gradient-to-r from-blue-400 to-purple-400 flex items-center justify-center"
                    >
                      <TrendingUp className="w-5 h-5 text-white" />
                    </motion.div>
                    <div>
                      <span className="text-lg font-bold text-gray-800">Monthly Overview</span>
                      <p className="text-sm text-gray-600 font-normal">Your spending vs budget</p>
                    </div>
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div className="text-center">
                      <p className="text-2xl font-bold text-gray-800">{formatCurrency(totalSpending)}</p>
                      <p className="text-sm text-gray-600">Total Spent</p>
                    </div>
                    <div className="text-center">
                      <p className="text-2xl font-bold text-purple-600">{formatCurrency(totalBudget)}</p>
                      <p className="text-sm text-gray-600">Total Budget</p>
                    </div>
                  </div>
                  <div className="bg-white/50 rounded-xl p-3 flex items-center gap-3">
                    <div className="text-2xl">{spendingInsight.emoji}</div>
                    <div>
                      <p className="font-medium text-gray-800">{spendingInsight.message}</p>
                      <p className="text-sm text-gray-600">{spendingInsight.detail}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            {/* Category Breakdown */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.4 }}
              className="space-y-4"
            >
              <div className="flex items-center gap-2">
                <PieChart className="w-5 h-5 text-purple-500" />
                <h2 className="text-lg font-bold text-gray-800">Spending by Category</h2>
              </div>
              
              <div className="space-y-3">
                {monthlySpending.map((category, index) => {
                  const isOverBudget = category.amount > category.budget;
                  const budgetUsage = (category.amount / category.budget) * 100;
                  
                  return (
                    <motion.div
                      key={category.category}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ duration: 0.3, delay: 0.5 + index * 0.1 }}
                    >
                      <Card className="cartoon-card bg-gradient-to-br from-white to-purple-50 border-0">
                        <CardContent className="p-4">
                          <div className="flex items-center justify-between mb-3">
                            <div className="flex items-center gap-2">
                              <span className="text-xl">{category.emoji}</span>
                              <div>
                                <h3 className="font-bold text-gray-800">{category.category}</h3>
                                <p className="text-sm text-gray-600">
                                  {formatCurrency(category.amount)} / {formatCurrency(category.budget)}
                                </p>
                              </div>
                            </div>
                            <div className="text-right">
                              <p className="font-bold text-gray-800">{category.percentage}%</p>
                              <div className="flex items-center gap-1">
                                <Badge 
                                  className={`text-xs ${
                                    category.trend.startsWith('+') 
                                      ? 'bg-red-100 text-red-800' 
                                      : 'bg-green-100 text-green-800'
                                  }`}
                                >
                                  {category.trend}
                                </Badge>
                                {isOverBudget && (
                                  <AlertCircle className="w-4 h-4 text-red-500" />
                                )}
                              </div>
                            </div>
                          </div>
                          
                          <div className="space-y-2">
                            <Progress 
                              value={category.percentage} 
                              className="h-2 rounded-full [&>div]:bg-gradient-to-r [&>div]:from-purple-400 [&>div]:to-pink-400"
                            />
                            <Progress 
                              value={budgetUsage} 
                              className={`h-1 rounded-full [&>div]:bg-gradient-to-r ${
                                isOverBudget 
                                  ? '[&>div]:from-red-400 [&>div]:to-red-600' 
                                  : '[&>div]:from-green-400 [&>div]:to-green-600'
                              }`}
                            />
                            <p className="text-xs text-gray-500">
                              {budgetUsage.toFixed(0)}% of budget used
                            </p>
                          </div>
                        </CardContent>
                      </Card>
                    </motion.div>
                  );
                })}
              </div>
            </motion.div>

            {/* Quick Actions */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.6 }}
              className="grid grid-cols-2 gap-4"
            >
              <motion.div whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.98 }}>
                <Button
                  onClick={() => onNavigate('reports')}
                  className="cartoon-button h-16 w-full bg-gradient-to-r from-blue-500 to-cyan-500 text-white border-0 flex items-center gap-3"
                >
                  <BarChart3 className="w-5 h-5" />
                  <div className="text-left">
                    <div className="font-bold">Reports</div>
                    <div className="text-xs opacity-90">Detailed analysis</div>
                  </div>
                </Button>
              </motion.div>
              
              <motion.div whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.98 }}>
                <Button
                  onClick={() => onNavigate('expense-history')}
                  className="cartoon-button h-16 w-full bg-gradient-to-r from-purple-500 to-pink-500 text-white border-0 flex items-center gap-3"
                >
                  <Calendar className="w-5 h-5" />
                  <div className="text-left">
                    <div className="font-bold">History</div>
                    <div className="text-xs opacity-90">View transactions</div>
                  </div>
                </Button>
              </motion.div>
            </motion.div>
          </TabsContent>

          <TabsContent value="ai-tips" className="space-y-6 mt-6">
            {/* AI Tips Header */}
            <motion.div
              initial={{ opacity: 0, y: -20 }}
              animate={{ opacity: 1, y: 0 }}
              className="text-center"
            >
              <motion.div
                animate={{ 
                  scale: [1, 1.1, 1],
                  rotate: [0, 5, -5, 0]
                }}
                transition={{ duration: 3, repeat: Infinity }}
                className="text-4xl mb-2"
              >
                🤖
              </motion.div>
              <h2 className="text-xl font-bold text-gray-800 mb-2">AI Financial Assistant</h2>
              <p className="text-gray-600 text-sm">Personalized tips based on your spending patterns</p>
            </motion.div>

            {/* AI Tips Grid */}
            <div className="space-y-4">
              <AnimatePresence>
                {aiTips.map((tip, index) => (
                  <motion.div
                    key={index}
                    initial={{ opacity: 0, x: -20, scale: 0.95 }}
                    animate={{ opacity: 1, x: 0, scale: 1 }}
                    exit={{ opacity: 0, x: 20, scale: 0.95 }}
                    transition={{ duration: 0.4, delay: index * 0.1 }}
                  >
                    <Card className={`cartoon-card border-0 overflow-hidden ${
                      tip.type === 'warning' ? 'bg-gradient-to-br from-red-50 to-pink-50' :
                      tip.type === 'success' ? 'bg-gradient-to-br from-green-50 to-emerald-50' :
                      tip.type === 'improvement' ? 'bg-gradient-to-br from-yellow-50 to-orange-50' :
                      'bg-gradient-to-br from-blue-50 to-indigo-50'
                    }`}>
                      <CardContent className="p-4">
                        <div className="flex items-start gap-3">
                          <motion.div
                            animate={{ bounce: [0, -10, 0] }}
                            transition={{ duration: 2, repeat: Infinity, delay: index * 0.5 }}
                            className="text-2xl mt-1"
                          >
                            {tip.emoji}
                          </motion.div>
                          <div className="flex-1">
                            <div className="flex items-center gap-2 mb-2">
                              <Badge className={`text-xs ${
                                tip.type === 'warning' ? 'bg-red-100 text-red-800' :
                                tip.type === 'success' ? 'bg-green-100 text-green-800' :
                                tip.type === 'improvement' ? 'bg-yellow-100 text-yellow-800' :
                                'bg-blue-100 text-blue-800'
                              }`}>
                                {tip.category}
                              </Badge>
                              {tip.priority === 'high' && (
                                <Badge className="bg-red-500 text-white text-xs">High Priority</Badge>
                              )}
                            </div>
                            <h3 className="font-bold text-gray-800 mb-2">{tip.title}</h3>
                            <p className="text-sm text-gray-700 mb-3">{tip.message}</p>
                            
                            <div className="flex items-center justify-between">
                              <div className="flex items-center gap-2">
                                {tip.savings > 0 && (
                                  <Badge className="bg-green-500 text-white text-xs">
                                    💰 Save {formatCurrency(tip.savings)}
                                  </Badge>
                                )}
                              </div>
                              <div className="flex items-center gap-2">
                                {tip.link && (
                                  <motion.button
                                    whileHover={{ scale: 1.05 }}
                                    whileTap={{ scale: 0.95 }}
                                    onClick={() => window.open(tip.link, '_blank')}
                                    className="flex items-center gap-1 text-blue-600 text-xs hover:text-blue-800"
                                  >
                                    Learn More <ExternalLink className="w-3 h-3" />
                                  </motion.button>
                                )}
                                <motion.div
                                  whileHover={{ scale: 1.1 }}
                                  className={`w-6 h-6 rounded-full flex items-center justify-center ${
                                    tip.type === 'warning' ? 'bg-red-500' :
                                    tip.type === 'success' ? 'bg-green-500' :
                                    tip.type === 'improvement' ? 'bg-yellow-500' :
                                    'bg-blue-500'
                                  }`}
                                >
                                  {tip.type === 'warning' ? <AlertCircle className="w-3 h-3 text-white" /> :
                                   tip.type === 'success' ? <CheckCircle className="w-3 h-3 text-white" /> :
                                   <Lightbulb className="w-3 h-3 text-white" />}
                                </motion.div>
                              </div>
                            </div>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  </motion.div>
                ))}
              </AnimatePresence>
            </div>

            {/* AI Assistant CTA */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.5 }}
            >
              <Card className="cartoon-card bg-gradient-to-r from-purple-500 to-pink-500 text-white border-0">
                <CardContent className="p-6 text-center">
                  <motion.div
                    animate={{ rotate: [0, 360] }}
                    transition={{ duration: 10, repeat: Infinity, ease: "linear" }}
                    className="text-4xl mb-3"
                  >
                    ⚡
                  </motion.div>
                  <h3 className="text-lg font-bold mb-2">Want More Personalized Tips?</h3>
                  <p className="text-sm opacity-90 mb-4">Connect your bank accounts for deeper insights and AI-powered recommendations</p>
                  <Button 
                    className="cartoon-button bg-white text-purple-600 hover:bg-gray-50"
                    onClick={() => onNavigate('financial-accounts')}
                  >
                    <Brain className="w-4 h-4 mr-2" />
                    Enhance AI Analysis
                  </Button>
                </CardContent>
              </Card>
            </motion.div>
          </TabsContent>

          <TabsContent value="resources" className="space-y-6 mt-6">
            {/* Resources Header */}
            <motion.div
              initial={{ opacity: 0, y: -20 }}
              animate={{ opacity: 1, y: 0 }}
              className="text-center"
            >
              <motion.div
                animate={{ scale: [1, 1.1, 1] }}
                transition={{ duration: 2, repeat: Infinity, repeatDelay: 3 }}
                className="text-4xl mb-2"
              >
                📚
              </motion.div>
              <h2 className="text-xl font-bold text-gray-800 mb-2">Financial Education</h2>
              <p className="text-gray-600 text-sm">Curated resources to improve your financial knowledge</p>
            </motion.div>

            {/* Educational Resources Grid */}
            <div className="grid grid-cols-1 gap-4">
              {educationalResources.map((resource, index) => (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.4, delay: index * 0.1 }}
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                >
                  <Card 
                    className="cartoon-card cursor-pointer border-0 overflow-hidden relative"
                    onClick={() => window.open(resource.link, '_blank')}
                  >
                    <div className="absolute top-0 right-0 text-4xl opacity-10">
                      {resource.emoji}
                    </div>
                    <CardContent className="p-4">
                      <div className="flex items-center gap-4">
                        <div className={`w-12 h-12 rounded-full bg-gradient-to-r ${resource.color} flex items-center justify-center text-2xl`}>
                          {resource.emoji}
                        </div>
                        <div className="flex-1">
                          <div className="flex items-center gap-2 mb-1">
                            <h3 className="font-bold text-gray-800">{resource.title}</h3>
                            <ExternalLink className="w-4 h-4 text-gray-400" />
                          </div>
                          <p className="text-sm text-gray-600 mb-2">{resource.description}</p>
                          <Badge className="bg-gray-100 text-gray-700 text-xs">
                            {resource.category}
                          </Badge>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                </motion.div>
              ))}
            </div>

            {/* Financial Tools Section */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.5 }}
              className="space-y-4"
            >
              <div className="flex items-center gap-2">
                <Sparkles className="w-5 h-5 text-blue-500" />
                <h3 className="text-lg font-bold text-gray-800">Built-in Financial Tools</h3>
              </div>
              
              <div className="grid grid-cols-2 gap-3">
                {financialTools.map((tool, index) => {
                  const IconComponent = tool.icon;
                  return (
                    <motion.div
                      key={tool.id}
                      initial={{ opacity: 0, scale: 0.8 }}
                      animate={{ opacity: 1, scale: 1 }}
                      transition={{ 
                        duration: 0.4, 
                        delay: 0.6 + index * 0.1,
                        type: "spring",
                        stiffness: 200 
                      }}
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                    >
                      <Card 
                        className="cartoon-card cursor-pointer overflow-hidden relative"
                        onClick={() => onNavigate(tool.route)}
                      >
                        {/* Background decoration */}
                        <div className="absolute top-0 right-0 text-4xl opacity-10">
                          {tool.emoji}
                        </div>
                        
                        <CardContent className="p-4">
                          <div className="flex flex-col items-center text-center space-y-3">
                            <div className={`w-12 h-12 rounded-full bg-gradient-to-r ${tool.color} flex items-center justify-center`}>
                              <IconComponent className="w-6 h-6 text-white" />
                            </div>
                            
                            <div>
                              <h4 className="font-bold text-gray-800 text-sm">{tool.title}</h4>
                              <p className="text-xs text-gray-600 mt-1">{tool.description}</p>
                            </div>
                            
                            <div className="flex items-center text-xs text-purple-600">
                              <span>Explore</span>
                              <ChevronRight className="w-3 h-3 ml-1" />
                            </div>
                          </div>
                        </CardContent>
                      </Card>
                    </motion.div>
                  );
                })}
              </div>
            </motion.div>

            {/* Community Section */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.7 }}
            >
              <Card className="cartoon-card bg-gradient-to-r from-indigo-500 to-purple-500 text-white border-0">
                <CardContent className="p-6 text-center">
                  <motion.div
                    animate={{ scale: [1, 1.2, 1] }}
                    transition={{ duration: 3, repeat: Infinity }}
                    className="text-4xl mb-3"
                  >
                    👥
                  </motion.div>
                  <h3 className="text-lg font-bold mb-2">Join Our Community</h3>
                  <p className="text-sm opacity-90 mb-4">Connect with like-minded individuals on their financial journey</p>
                  <div className="flex gap-2 justify-center">
                    <Button 
                      className="cartoon-button bg-white text-indigo-600 hover:bg-gray-50 text-xs"
                      onClick={() => window.open('https://reddit.com/r/personalfinance', '_blank')}
                    >
                      <Users className="w-3 h-3 mr-1" />
                      Reddit
                    </Button>
                    <Button 
                      className="cartoon-button bg-white text-indigo-600 hover:bg-gray-50 text-xs"
                      onClick={() => window.open('https://www.bogleheads.org/', '_blank')}
                    >
                      <BookOpen className="w-3 h-3 mr-1" />
                      Forums
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          </TabsContent>
        </Tabs>
      </motion.div>
    </div>
  );
}