import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Slider } from "./ui/slider";
import { Progress } from "./ui/progress";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "./ui/tabs";
import { Alert, AlertDescription } from "./ui/alert";
import { PieChart, AlertTriangle, TrendingUp, Save } from "lucide-react";
import { motion } from "motion/react";

export function Budget() {
  const [monthlyIncome, setMonthlyIncome] = useState(5200);
  const [activeTab, setActiveTab] = useState('overview');
  
  const [budgetCategories, setBudgetCategories] = useState([
    { name: 'Food & Dining', percentage: 25, amount: 1300, spent: 1200, color: '#2E7D32' },
    { name: 'Transportation', percentage: 15, amount: 780, spent: 850, color: '#FFB300' },
    { name: 'Housing', percentage: 30, amount: 1560, spent: 1560, color: '#1976D2' },
    { name: 'Utilities', percentage: 8, amount: 416, spent: 390, color: '#7B1FA2' },
    { name: 'Entertainment', percentage: 10, amount: 520, spent: 380, color: '#D32F2F' },
    { name: 'Savings', percentage: 12, amount: 624, spent: 500, color: '#388E3C' },
  ]);

  const handleIncomeChange = (value: string) => {
    const income = parseFloat(value) || 0;
    setMonthlyIncome(income);
    updateBudgetAmounts(income);
  };

  const handlePercentageChange = (index: number, percentage: number) => {
    const newCategories = [...budgetCategories];
    newCategories[index].percentage = percentage;
    setBudgetCategories(newCategories);
    updateBudgetAmounts(monthlyIncome);
  };

  const updateBudgetAmounts = (income: number) => {
    setBudgetCategories(categories => 
      categories.map(category => ({
        ...category,
        amount: (income * category.percentage) / 100
      }))
    );
  };

  const totalPercentage = budgetCategories.reduce((sum, cat) => sum + cat.percentage, 0);
  const totalBudget = budgetCategories.reduce((sum, cat) => sum + cat.amount, 0);
  const totalSpent = budgetCategories.reduce((sum, cat) => sum + cat.spent, 0);

  const getStatusColor = (spent: number, budget: number) => {
    const ratio = spent / budget;
    if (ratio > 1) return 'text-[color:var(--sfms-danger)]';
    if (ratio > 0.8) return 'text-[color:var(--sfms-warning)]';
    return 'text-[color:var(--sfms-success)]';
  };

  const getProgressColor = (spent: number, budget: number) => {
    const ratio = spent / budget;
    if (ratio > 1) return '[&>div]:bg-[color:var(--sfms-danger)]';
    if (ratio > 0.8) return '[&>div]:bg-[color:var(--sfms-warning)]';
    return '[&>div]:bg-[color:var(--sfms-success)]';
  };

  return (
    <div className="pb-20 px-4 space-y-6">
      {/* Header */}
      <div className="pt-6">
        <h1 className="text-xl font-semibold">Budget Management</h1>
        <p className="text-muted-foreground">Plan and track your monthly spending</p>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="create">Edit Budget</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-4">
          {/* Budget Summary */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3 }}
          >
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <PieChart className="w-5 h-5" />
                  Monthly Budget Overview
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-3 gap-4 text-center">
                  <div>
                    <p className="text-sm text-muted-foreground">Income</p>
                    <p className="text-lg font-semibold text-[color:var(--sfms-success)]">
                      RM {monthlyIncome.toLocaleString()}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Budgeted</p>
                    <p className="text-lg font-semibold">
                      RM {totalBudget.toLocaleString()}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">Spent</p>
                    <p className={`text-lg font-semibold ${getStatusColor(totalSpent, totalBudget)}`}>
                      RM {totalSpent.toLocaleString()}
                    </p>
                  </div>
                </div>
                
                <div className="mt-4">
                  <div className="flex justify-between text-sm mb-2">
                    <span>Overall Progress</span>
                    <span>{((totalSpent / totalBudget) * 100).toFixed(1)}%</span>
                  </div>
                  <Progress 
                    value={(totalSpent / totalBudget) * 100} 
                    className={`h-2 ${getProgressColor(totalSpent, totalBudget)}`}
                  />
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* Overspending Alert */}
          {totalSpent > totalBudget && (
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.3 }}
            >
              <Alert className="border-[color:var(--sfms-danger)] bg-[color:var(--sfms-danger)]/10">
                <AlertTriangle className="h-4 w-4 text-[color:var(--sfms-danger)]" />
                <AlertDescription className="text-[color:var(--sfms-danger)]">
                  You've exceeded your budget by RM {(totalSpent - totalBudget).toLocaleString()}
                </AlertDescription>
              </Alert>
            </motion.div>
          )}

          {/* Category Breakdown */}
          <div className="space-y-3">
            {budgetCategories.map((category, index) => {
              const progressPercentage = (category.spent / category.amount) * 100;
              
              return (
                <motion.div
                  key={category.name}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ duration: 0.3, delay: 0.1 * index }}
                >
                  <Card>
                    <CardContent className="p-4">
                      <div className="flex justify-between items-center mb-2">
                        <div className="flex items-center gap-3">
                          <div 
                            className="w-3 h-3 rounded-full" 
                            style={{ backgroundColor: category.color }}
                          ></div>
                          <h4 className="font-medium">{category.name}</h4>
                        </div>
                        <div className="text-right">
                          <p className={`font-semibold ${getStatusColor(category.spent, category.amount)}`}>
                            RM {category.spent} / RM {category.amount.toFixed(0)}
                          </p>
                          <p className="text-xs text-muted-foreground">
                            {category.percentage}% of income
                          </p>
                        </div>
                      </div>
                      
                      <div className="space-y-1">
                        <div className="flex justify-between text-sm">
                          <span className="text-muted-foreground">Progress</span>
                          <span className={getStatusColor(category.spent, category.amount)}>
                            {Math.min(progressPercentage, 100).toFixed(1)}%
                          </span>
                        </div>
                        <Progress 
                          value={Math.min(progressPercentage, 100)} 
                          className={`h-1.5 ${getProgressColor(category.spent, category.amount)}`}
                        />
                        
                        {category.spent > category.amount && (
                          <p className="text-xs text-[color:var(--sfms-danger)]">
                            Over budget by RM {(category.spent - category.amount).toFixed(0)}
                          </p>
                        )}
                      </div>
                    </CardContent>
                  </Card>
                </motion.div>
              );
            })}
          </div>
        </TabsContent>

        <TabsContent value="create" className="space-y-4">
          {/* Income Input */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Monthly Income</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  <Label htmlFor="income">Total Monthly Income (RM)</Label>
                  <Input
                    id="income"
                    type="number"
                    value={monthlyIncome}
                    onChange={(e) => handleIncomeChange(e.target.value)}
                    placeholder="Enter your monthly income"
                  />
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* Budget Allocation */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3, delay: 0.1 }}
          >
            <Card>
              <CardHeader>
                <CardTitle>Budget Allocation</CardTitle>
                <p className="text-sm text-muted-foreground">
                  Total: {totalPercentage}% of income
                </p>
              </CardHeader>
              <CardContent className="space-y-6">
                {budgetCategories.map((category, index) => (
                  <div key={category.name} className="space-y-3">
                    <div className="flex justify-between items-center">
                      <Label className="flex items-center gap-2">
                        <div 
                          className="w-3 h-3 rounded-full" 
                          style={{ backgroundColor: category.color }}
                        ></div>
                        {category.name}
                      </Label>
                      <div className="text-right">
                        <span className="font-medium">{category.percentage}%</span>
                        <p className="text-sm text-muted-foreground">
                          RM {category.amount.toFixed(0)}
                        </p>
                      </div>
                    </div>
                    <Slider
                      value={[category.percentage]}
                      onValueChange={(value) => handlePercentageChange(index, value[0])}
                      max={50}
                      step={1}
                      className="w-full"
                    />
                  </div>
                ))}

                {totalPercentage !== 100 && (
                  <Alert className={totalPercentage > 100 ? 'border-[color:var(--sfms-danger)]' : 'border-[color:var(--sfms-warning)]'}>
                    <AlertTriangle className="h-4 w-4" />
                    <AlertDescription>
                      {totalPercentage > 100 
                        ? `Budget exceeds income by ${totalPercentage - 100}%`
                        : `${100 - totalPercentage}% of income unallocated`
                      }
                    </AlertDescription>
                  </Alert>
                )}

                <Button 
                  className="w-full bg-[color:var(--sfms-success)] hover:bg-[color:var(--sfms-success)]/90"
                  disabled={totalPercentage !== 100}
                >
                  <Save className="w-4 h-4 mr-2" />
                  Save Budget Plan
                </Button>
              </CardContent>
            </Card>
          </motion.div>
        </TabsContent>
      </Tabs>
    </div>
  );
}