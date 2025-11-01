import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "./ui/tabs";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Badge } from "./ui/badge";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, ResponsiveContainer, LineChart, Line, PieChart, Pie, Cell, Area, AreaChart } from "recharts";
import { ArrowLeft, Download, Share, TrendingUp, TrendingDown, DollarSign, Calendar } from "lucide-react";
import { motion } from "motion/react";

interface ReportsProps {
  onBack: () => void;
}

export function Reports({ onBack }: ReportsProps) {
  const [selectedPeriod, setSelectedPeriod] = useState('monthly');
  const [selectedYear, setSelectedYear] = useState('2024');
  const [activeTab, setActiveTab] = useState('overview');

  // Mock data for different periods
  const weeklyData = [
    { period: 'Week 1', income: 1300, expenses: 950, savings: 350 },
    { period: 'Week 2', income: 1300, expenses: 1100, savings: 200 },
    { period: 'Week 3', income: 1300, expenses: 890, savings: 410 },
    { period: 'Week 4', income: 1300, expenses: 1200, savings: 100 },
  ];

  const monthlyData = [
    { period: 'Jan', income: 5200, expenses: 3800, savings: 1400 },
    { period: 'Feb', income: 5200, expenses: 4100, savings: 1100 },
    { period: 'Mar', income: 5500, expenses: 3900, savings: 1600 },
    { period: 'Apr', income: 5200, expenses: 4200, savings: 1000 },
    { period: 'May', income: 5200, expenses: 3600, savings: 1600 },
    { period: 'Jun', income: 5400, expenses: 3800, savings: 1600 },
  ];

  const yearlyData = [
    { period: '2022', income: 58000, expenses: 42000, savings: 16000 },
    { period: '2023', income: 62000, expenses: 45000, savings: 17000 },
    { period: '2024', income: 64000, expenses: 46000, savings: 18000 },
  ];

  const categoryData = [
    { name: 'Food & Dining', value: 1200, percentage: 32, color: '#2E7D32' },
    { name: 'Transportation', value: 800, percentage: 21, color: '#FFB300' },
    { name: 'Bills & Utilities', value: 900, percentage: 24, color: '#1976D2' },
    { name: 'Shopping', value: 600, percentage: 16, color: '#D32F2F' },
    { name: 'Entertainment', value: 300, percentage: 8, color: '#7B1FA2' },
  ];

  const getCurrentData = () => {
    switch (selectedPeriod) {
      case 'weekly':
        return weeklyData;
      case 'monthly':
        return monthlyData;
      case 'yearly':
        return yearlyData;
      default:
        return monthlyData;
    }
  };

  const getSummaryStats = () => {
    const data = getCurrentData();
    const totalIncome = data.reduce((sum, item) => sum + item.income, 0);
    const totalExpenses = data.reduce((sum, item) => sum + item.expenses, 0);
    const totalSavings = data.reduce((sum, item) => sum + item.savings, 0);
    const savingsRate = ((totalSavings / totalIncome) * 100).toFixed(1);
    
    return { totalIncome, totalExpenses, totalSavings, savingsRate };
  };

  const stats = getSummaryStats();

  const handleExport = (format: 'pdf' | 'csv') => {
    console.log(`Exporting report as ${format.toUpperCase()}`);
    // Implement export functionality
  };

  return (
    <div className="pb-20 px-4 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between pt-6">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="sm" onClick={onBack}>
            <ArrowLeft className="w-4 h-4" />
          </Button>
          <div>
            <h1 className="text-xl font-semibold">Financial Reports</h1>
            <p className="text-sm text-muted-foreground">Comprehensive financial analysis</p>
          </div>
        </div>
        
        <div className="flex gap-2">
          <Button variant="outline" size="sm" onClick={() => handleExport('pdf')}>
            <Download className="w-4 h-4 mr-2" />
            PDF
          </Button>
          <Button variant="outline" size="sm">
            <Share className="w-4 h-4" />
          </Button>
        </div>
      </div>

      {/* Filters */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3 }}
      >
        <Card className="bg-gradient-to-r from-[color:var(--sfms-success)] to-[color:var(--sfms-success)]/80 text-white">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Calendar className="w-5 h-5" />
                <span className="font-medium">Report Period</span>
              </div>
              <div className="flex gap-3">
                <Select value={selectedPeriod} onValueChange={setSelectedPeriod}>
                  <SelectTrigger className="w-32 bg-white/20 border-white/30 text-white">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="weekly">Weekly</SelectItem>
                    <SelectItem value="monthly">Monthly</SelectItem>
                    <SelectItem value="yearly">Yearly</SelectItem>
                  </SelectContent>
                </Select>
                
                {selectedPeriod !== 'weekly' && (
                  <Select value={selectedYear} onValueChange={setSelectedYear}>
                    <SelectTrigger className="w-20 bg-white/20 border-white/30 text-white">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="2022">2022</SelectItem>
                      <SelectItem value="2023">2023</SelectItem>
                      <SelectItem value="2024">2024</SelectItem>
                    </SelectContent>
                  </Select>
                )}
              </div>
            </div>
          </CardContent>
        </Card>
      </motion.div>

      {/* Summary Stats */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.1 }}
        className="grid grid-cols-2 gap-4"
      >
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-[color:var(--sfms-success-light)] flex items-center justify-center">
                <TrendingUp className="w-5 h-5 text-[color:var(--sfms-success)]" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Total Income</p>
                <p className="text-lg font-semibold text-[color:var(--sfms-success)]">
                  RM {stats.totalIncome.toLocaleString()}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-[color:var(--sfms-danger-light)] flex items-center justify-center">
                <TrendingDown className="w-5 h-5 text-[color:var(--sfms-danger)]" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Total Expenses</p>
                <p className="text-lg font-semibold">
                  RM {stats.totalExpenses.toLocaleString()}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-[color:var(--sfms-warning-light)] flex items-center justify-center">
                <DollarSign className="w-5 h-5 text-[color:var(--sfms-warning)]" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Total Savings</p>
                <p className="text-lg font-semibold text-[color:var(--sfms-warning)]">
                  RM {stats.totalSavings.toLocaleString()}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-[color:var(--sfms-success-light)] flex items-center justify-center">
                <span className="text-sm font-semibold text-[color:var(--sfms-success)]">%</span>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Savings Rate</p>
                <p className="text-lg font-semibold text-[color:var(--sfms-success)]">
                  {stats.savingsRate}%
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      </motion.div>

      {/* Charts */}
      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="trends">Trends</TabsTrigger>
          <TabsTrigger value="categories">Categories</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-4">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3 }}
          >
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <TrendingUp className="w-5 h-5" />
                  Income vs Expenses ({selectedPeriod.charAt(0).toUpperCase() + selectedPeriod.slice(1)})
                </CardTitle>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={getCurrentData()}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="period" />
                    <YAxis />
                    <Bar dataKey="income" fill="var(--color-sfms-success)" name="Income" />
                    <Bar dataKey="expenses" fill="var(--color-sfms-danger)" name="Expenses" />
                  </BarChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3, delay: 0.1 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Savings Progress</CardTitle>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={200}>
                  <AreaChart data={getCurrentData()}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="period" />
                    <YAxis />
                    <Area 
                      type="monotone" 
                      dataKey="savings" 
                      stroke="var(--color-sfms-warning)" 
                      fill="var(--color-sfms-warning-light)"
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          </motion.div>
        </TabsContent>

        <TabsContent value="trends" className="space-y-4">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Financial Trends</CardTitle>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={300}>
                  <LineChart data={getCurrentData()}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="period" />
                    <YAxis />
                    <Line 
                      type="monotone" 
                      dataKey="income" 
                      stroke="var(--color-sfms-success)" 
                      strokeWidth={3}
                      name="Income"
                    />
                    <Line 
                      type="monotone" 
                      dataKey="expenses" 
                      stroke="var(--color-sfms-danger)" 
                      strokeWidth={3}
                      name="Expenses"
                    />
                    <Line 
                      type="monotone" 
                      dataKey="savings" 
                      stroke="var(--color-sfms-warning)" 
                      strokeWidth={3}
                      name="Savings"
                    />
                  </LineChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          </motion.div>
        </TabsContent>

        <TabsContent value="categories" className="space-y-4">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Expense Categories</CardTitle>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={250}>
                  <PieChart>
                    <Pie
                      data={categoryData}
                      cx="50%"
                      cy="50%"
                      outerRadius={80}
                      dataKey="value"
                      label={({ name, percentage }) => `${name} ${percentage}%`}
                    >
                      {categoryData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                  </PieChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3, delay: 0.1 }}
            className="space-y-3"
          >
            {categoryData.map((category, index) => (
              <Card key={category.name}>
                <CardContent className="p-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div 
                        className="w-4 h-4 rounded-full" 
                        style={{ backgroundColor: category.color }}
                      ></div>
                      <span className="font-medium">{category.name}</span>
                    </div>
                    <div className="text-right">
                      <p className="font-semibold">RM {category.value}</p>
                      <Badge variant="secondary" className="text-xs">
                        {category.percentage}%
                      </Badge>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </motion.div>
        </TabsContent>
      </Tabs>
    </div>
  );
}