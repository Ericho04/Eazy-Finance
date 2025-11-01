import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";
import { Progress } from "./ui/progress";
import { 
  ArrowLeft,
  Target,
  Plus,
  Edit,
  Trash2,
  TrendingUp,
  Calendar,
  DollarSign,
  CheckCircle,
  Clock
} from "lucide-react";
import { motion } from "motion/react";
import { useApp } from "../utils/AppContext";

interface FinancialGoalsProps {
  onBack: () => void;
}

export function FinancialGoals({ onBack }: FinancialGoalsProps) {
  const { state, addGoal, updateGoal, deleteGoal } = useApp();

  const formatCurrency = (amount: number) => {
    return `RM ${amount.toLocaleString('en-MY', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`;
  };

  const calculateGoalProgress = (current: number, target: number) => {
    return Math.min(Math.round((current / target) * 100), 100);
  };

  const getDaysUntil = (dateStr: string) => {
    const targetDate = new Date(dateStr);
    const today = new Date();
    const diffTime = targetDate.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
  };

  // Calculate total progress and stats
  const totalGoals = state.goals.length;
  const completedGoals = state.goals.filter(goal => calculateGoalProgress(goal.currentAmount, goal.targetAmount) >= 100).length;
  const totalTargetAmount = state.goals.reduce((sum, goal) => sum + goal.targetAmount, 0);
  const totalCurrentAmount = state.goals.reduce((sum, goal) => sum + goal.currentAmount, 0);
  const overallProgress = totalTargetAmount > 0 ? (totalCurrentAmount / totalTargetAmount) * 100 : 0;

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
            <h1 className="text-2xl text-[color:var(--sfms-success)]">Financial Goals</h1>
            <p className="text-muted-foreground">Track your savings and financial objectives</p>
          </div>
        </motion.div>
      </div>

      {/* Summary Cards */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.1 }}
        className="grid grid-cols-3 gap-3"
      >
        <Card className="border-[color:var(--sfms-success)]/20">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <Target className="w-4 h-4 text-[color:var(--sfms-success)]" />
              <span className="text-xs font-medium">Total Goals</span>
            </div>
            <p className="text-2xl font-bold text-[color:var(--sfms-success)]">
              {totalGoals}
            </p>
          </CardContent>
        </Card>

        <Card className="border-[color:var(--sfms-ai)]/20">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <CheckCircle className="w-4 h-4 text-[color:var(--sfms-ai)]" />
              <span className="text-xs font-medium">Completed</span>
            </div>
            <p className="text-2xl font-bold text-[color:var(--sfms-ai)]">
              {completedGoals}
            </p>
          </CardContent>
        </Card>

        <Card className="border-[color:var(--sfms-warning)]/20">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <TrendingUp className="w-4 h-4 text-[color:var(--sfms-warning)]" />
              <span className="text-xs font-medium">Progress</span>
            </div>
            <p className="text-2xl font-bold text-[color:var(--sfms-warning)]">
              {overallProgress.toFixed(0)}%
            </p>
          </CardContent>
        </Card>
      </motion.div>

      {/* Overall Progress */}
      {totalGoals > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3, delay: 0.2 }}
        >
          <Card className="border-[color:var(--sfms-success)]/20 bg-gradient-to-br from-[color:var(--sfms-success-light)] to-white">
            <CardHeader>
              <CardTitle className="text-[color:var(--sfms-success)] flex items-center gap-2">
                <DollarSign className="w-5 h-5" />
                Overall Goal Progress
              </CardTitle>
              <CardDescription>Your total savings progress across all goals</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex justify-between text-sm">
                  <span>Total Progress</span>
                  <span className="font-medium">{overallProgress.toFixed(1)}%</span>
                </div>
                <Progress value={overallProgress} className="h-3" />
                <div className="flex justify-between text-sm text-muted-foreground">
                  <span>{formatCurrency(totalCurrentAmount)} saved</span>
                  <span>Target: {formatCurrency(totalTargetAmount)}</span>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      )}

      {/* Goals List */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.3 }}
        className="space-y-4"
      >
        <div className="flex justify-between items-center">
          <h2 className="text-lg font-medium">Your Goals</h2>
          <Button 
            size="sm" 
            className="gradient-success text-white"
            onClick={() => {
              const newGoal = {
                userId: 'demo-user-123',
                title: 'New Goal',
                description: 'Describe your financial goal',
                targetAmount: 10000,
                targetDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
                category: 'Savings',
                priority: 'medium' as const,
                isActive: true
              };
              addGoal(newGoal);
            }}
          >
            <Plus className="w-4 h-4 mr-1" />
            Add Goal
          </Button>
        </div>

        {state.goals.length === 0 ? (
          <Card className="shadow-lg">
            <CardContent className="p-8">
              <div className="text-center">
                <Target className="w-12 h-12 mx-auto text-muted-foreground mb-4" />
                <h3 className="text-lg font-medium mb-2">No Financial Goals Yet</h3>
                <p className="text-muted-foreground mb-6">
                  Start your financial journey by setting your first goal
                </p>
                <Button 
                  className="gradient-success text-white"
                  onClick={() => {
                    const newGoal = {
                      userId: 'demo-user-123',
                      title: 'Emergency Fund',
                      description: 'Build 6 months of emergency savings',
                      targetAmount: 20000,
                      targetDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
                      category: 'Emergency Fund',
                      priority: 'high' as const,
                      isActive: true
                    };
                    addGoal(newGoal);
                  }}
                >
                  <Plus className="w-4 h-4 mr-2" />
                  Create Your First Goal
                </Button>
              </div>
            </CardContent>
          </Card>
        ) : (
          state.goals.map((goal, index) => {
            const progress = calculateGoalProgress(goal.currentAmount, goal.targetAmount);
            const daysLeft = getDaysUntil(goal.targetDate);
            const isOverdue = daysLeft < 0;
            const isCompleted = progress >= 100;
            
            return (
              <motion.div
                key={goal.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.3, delay: 0.4 + index * 0.1 }}
              >
                <Card className={`shadow-lg border-l-4 ${
                  isCompleted ? 'border-l-[color:var(--sfms-success)]' :
                  isOverdue ? 'border-l-[color:var(--sfms-danger)]' :
                  'border-l-[color:var(--sfms-warning)]'
                }`}>
                  <CardContent className="p-4">
                    <div className="space-y-4">
                      {/* Header */}
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <div className={`p-2 rounded-lg ${
                            isCompleted ? 'bg-[color:var(--sfms-success-light)] text-[color:var(--sfms-success)]' :
                            isOverdue ? 'bg-[color:var(--sfms-danger-light)] text-[color:var(--sfms-danger)]' :
                            'bg-[color:var(--sfms-warning-light)] text-[color:var(--sfms-warning)]'
                          }`}>
                            {isCompleted ? <CheckCircle className="w-4 h-4" /> : <Target className="w-4 h-4" />}
                          </div>
                          <div>
                            <h3 className="font-medium">{goal.title}</h3>
                            <p className="text-sm text-muted-foreground">{goal.description}</p>
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => {
                              const newAmount = prompt(`Update progress for "${goal.title}":`, goal.currentAmount.toString());
                              if (newAmount && !isNaN(Number(newAmount))) {
                                updateGoal(goal.id, { currentAmount: Number(newAmount) });
                              }
                            }}
                          >
                            <Edit className="w-4 h-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => {
                              if (confirm(`Delete goal "${goal.title}"?`)) {
                                deleteGoal(goal.id);
                              }
                            }}
                            className="text-[color:var(--sfms-danger)]"
                          >
                            <Trash2 className="w-4 h-4" />
                          </Button>
                        </div>
                      </div>

                      {/* Progress */}
                      <div className="space-y-2">
                        <div className="flex justify-between text-sm">
                          <span>Progress</span>
                          <span className={`font-medium ${
                            isCompleted ? 'text-[color:var(--sfms-success)]' : 'text-foreground'
                          }`}>
                            {progress}%
                          </span>
                        </div>
                        <Progress 
                          value={progress} 
                          className={`h-3 ${
                            isCompleted ? '[&>div]:bg-[color:var(--sfms-success)]' : ''
                          }`}
                        />
                        <div className="flex justify-between text-sm text-muted-foreground">
                          <span>{formatCurrency(goal.currentAmount)} of {formatCurrency(goal.targetAmount)}</span>
                          <span>Remaining: {formatCurrency(goal.targetAmount - goal.currentAmount)}</span>
                        </div>
                      </div>

                      {/* Details and Status */}
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-4">
                          <Badge 
                            variant={goal.priority === 'high' ? 'destructive' : goal.priority === 'medium' ? 'default' : 'secondary'}
                            className="text-xs"
                          >
                            {goal.priority} priority
                          </Badge>
                          <Badge variant="outline" className="text-xs">
                            {goal.category}
                          </Badge>
                        </div>
                        <div className="flex items-center gap-2 text-sm">
                          <Calendar className="w-4 h-4 text-muted-foreground" />
                          <span className={`${
                            isOverdue ? 'text-[color:var(--sfms-danger)]' :
                            daysLeft <= 30 ? 'text-[color:var(--sfms-warning)]' :
                            'text-muted-foreground'
                          }`}>
                            {isOverdue ? `${Math.abs(daysLeft)} days overdue` : 
                             isCompleted ? 'Completed' :
                             `${daysLeft} days left`}
                          </span>
                        </div>
                      </div>

                      {/* Target Date */}
                      <div className="pt-2 border-t border-[color:var(--sfms-neutral-light)]">
                        <div className="flex justify-between items-center text-sm">
                          <span className="text-muted-foreground">Target Date:</span>
                          <span className="font-medium">
                            {new Date(goal.targetDate).toLocaleDateString()}
                          </span>
                        </div>
                      </div>

                      {/* Action Button */}
                      {!isCompleted && (
                        <Button 
                          size="sm" 
                          className="w-full gradient-success text-white"
                          onClick={() => {
                            const addAmount = prompt(`Add money to "${goal.title}":`, "100");
                            if (addAmount && !isNaN(Number(addAmount))) {
                              updateGoal(goal.id, { currentAmount: goal.currentAmount + Number(addAmount) });
                            }
                          }}
                        >
                          <Plus className="w-4 h-4 mr-2" />
                          Add Money
                        </Button>
                      )}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            );
          })
        )}
      </motion.div>

      {/* Goal Templates */}
      {state.goals.length === 0 && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3, delay: 0.5 }}
        >
          <Card className="border-[color:var(--sfms-ai)]/20 bg-gradient-to-br from-[color:var(--sfms-ai-light)] to-white">
            <CardHeader>
              <CardTitle className="text-[color:var(--sfms-ai)] flex items-center gap-2">
                <Target className="w-5 h-5" />
                Popular Goal Templates
              </CardTitle>
              <CardDescription>Quick start with common financial goals</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 gap-3">
                {[
                  { title: 'Emergency Fund', amount: 20000, category: 'Emergency Fund' },
                  { title: 'Vacation Fund', amount: 8000, category: 'Travel' },
                  { title: 'New Car', amount: 50000, category: 'Transportation' },
                  { title: 'Home Down Payment', amount: 100000, category: 'Housing' }
                ].map((template) => (
                  <Button
                    key={template.title}
                    variant="outline"
                    className="h-auto p-3 text-left"
                    onClick={() => {
                      const newGoal = {
                        userId: 'demo-user-123',
                        title: template.title,
                        description: `Save for ${template.title.toLowerCase()}`,
                        targetAmount: template.amount,
                        targetDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
                        category: template.category,
                        priority: 'medium' as const,
                        isActive: true
                      };
                      addGoal(newGoal);
                    }}
                  >
                    <div>
                      <p className="font-medium">{template.title}</p>
                      <p className="text-sm text-muted-foreground">{formatCurrency(template.amount)}</p>
                    </div>
                  </Button>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>
      )}

      {/* Action Buttons */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.6 }}
        className="grid grid-cols-2 gap-3"
      >
        <Button variant="outline" className="h-12">
          <Clock className="w-4 h-4 mr-2" />
          Goal Calculator
        </Button>
        <Button className="gradient-ai text-white h-12">
          <TrendingUp className="w-4 h-4 mr-2" />
          Smart Suggestions
        </Button>
      </motion.div>
    </div>
  );
}