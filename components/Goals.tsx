import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { 
  Plus, 
  Target, 
  Gift,
  Star,
  TrendingUp,
  Calendar,
  DollarSign,
  Award,
  Sparkles,
  ChevronRight,
  Trophy,
  Wallet
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { useApp } from '../utils/AppContext';

interface GoalsProps {
  onNavigate: (section: string) => void;
}

export function Goals({ onNavigate }: GoalsProps) {
  const { 
    state, 
    addGoal, 
    updateGoal, 
    contributeToGoal,
    getActiveGoals,
    getCompletedGoals
  } = useApp();
  
  const [showAddGoal, setShowAddGoal] = useState(false);
  const [showContributeModal, setShowContributeModal] = useState(false);
  const [selectedGoalId, setSelectedGoalId] = useState<string>('');
  const [contributionAmount, setContributionAmount] = useState<string>('');
  
  const [newGoal, setNewGoal] = useState({
    title: '',
    description: '',
    targetAmount: 0,
    deadline: '',
    category: 'savings',
    priority: 'medium' as const
  });

  const activeGoals = getActiveGoals();
  const completedGoals = getCompletedGoals();
  const totalGoalsValue = state.goals.reduce((sum, goal) => sum + goal.targetAmount, 0);
  const totalSaved = state.goals.reduce((sum, goal) => sum + goal.currentAmount, 0);

  const formatCurrency = (amount: number) => {
    return `RM ${amount.toFixed(2)}`;
  };

  const getProgressPercentage = (current: number, target: number) => {
    return Math.min((current / target) * 100, 100);
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high':
        return 'bg-cartoon-pink/20 text-cartoon-pink border-cartoon-pink/30';
      case 'medium':
        return 'bg-cartoon-yellow/20 text-cartoon-orange border-cartoon-yellow/30';
      case 'low':
        return 'bg-cartoon-mint/20 text-cartoon-mint border-cartoon-mint/30';
      default:
        return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const getCategoryEmoji = (category: string) => {
    const emojis: { [key: string]: string } = {
      savings: '💰',
      emergency: '🆘',
      travel: '✈️',
      technology: '💻',
      education: '📚',
      health: '🏥',
      home: '🏠',
      car: '🚗',
      investment: '📈'
    };
    return emojis[category] || '🎯';
  };

  const handleAddGoal = () => {
    if (newGoal.title && newGoal.targetAmount > 0) {
      addGoal({
        ...newGoal,
      });
      
      setNewGoal({
        title: '',
        description: '',
        targetAmount: 0,
        deadline: '',
        category: 'savings',
        priority: 'medium'
      });
      setShowAddGoal(false);
    }
  };

  const handleContributeToGoalClick = (goalId: string) => {
    setSelectedGoalId(goalId);
    setShowContributeModal(true);
  };

  const handleContributeSubmit = () => {
    const amount = parseFloat(contributionAmount);
    if (amount > 0 && selectedGoalId) {
      contributeToGoal(selectedGoalId, amount);
      setContributionAmount('');
      setSelectedGoalId('');
      setShowContributeModal(false);
    }
  };

  const handleQuickContribute = (goalId: string, amount: number) => {
    contributeToGoal(goalId, amount);
  };

  return (
    <div className="min-h-screen pb-32">
      {/* Header with Points */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, ease: "easeOut" }}
        className="px-6 pt-8 text-center mb-8"
      >
        <div className="flex items-center justify-between mb-6">
          <div className="text-left">
            <motion.div
              animate={{ rotate: [0, 10, -10, 0] }}
              transition={{ duration: 2, repeat: Infinity, repeatDelay: 3 }}
              className="text-5xl mb-3"
            >
              🎯
            </motion.div>
            <h1 className="text-3xl font-bold bg-gradient-to-r from-cartoon-purple to-cartoon-pink bg-clip-text text-transparent">
              Financial Goals
            </h1>
            <p className="text-gray-600">Build your financial future</p>
          </div>
          
          {/* Points Display */}
          <motion.div
            whileHover={{ scale: 1.05 }}
            className="flex items-center gap-3 cartoon-gradient-yellow rounded-2xl px-6 py-3 shadow-lg"
          >
            <Star className="w-6 h-6 text-white" />
            <div className="text-white">
              <span className="text-2xl font-bold">{state.rewardPoints}</span>
              <p className="text-sm opacity-90">points</p>
            </div>
          </motion.div>
        </div>
        
        {/* Quick Action Buttons */}
        <div className="flex gap-4 justify-center">
          <motion.button
            whileHover={{ scale: 1.05, y: -2 }}
            whileTap={{ scale: 0.95 }}
            onClick={() => onNavigate('lucky-draw')}
            className="cartoon-button cartoon-gradient-pink text-white px-8 py-4 rounded-2xl flex items-center gap-3 shadow-lg"
          >
            <Gift className="w-5 h-5" />
            <span className="font-bold">Lucky Draw</span>
          </motion.button>
          
          <motion.button
            whileHover={{ scale: 1.05, y: -2 }}
            whileTap={{ scale: 0.95 }}
            onClick={() => onNavigate('rewards-shop')}
            className="cartoon-button cartoon-gradient-cyan text-white px-8 py-4 rounded-2xl flex items-center gap-3 shadow-lg"
          >
            <Award className="w-5 h-5" />
            <span className="font-bold">Shop</span>
          </motion.button>
        </div>
      </motion.div>

      <div className="px-6 space-y-8">
        {/* Goals Overview */}
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.6, delay: 0.1 }}
        >
          <Card className="cartoon-card bg-gradient-to-br from-cartoon-blue/10 to-cartoon-purple/10 border-cartoon-blue/20 overflow-hidden relative">
            <div className="absolute top-0 right-0 text-6xl opacity-10">📊</div>
            <CardHeader className="pb-4">
              <CardTitle className="flex items-center gap-4">
                <motion.div
                  animate={{ scale: [1, 1.2, 1] }}
                  transition={{ duration: 1.5, repeat: Infinity }}
                  className="w-12 h-12 rounded-full cartoon-gradient-mint flex items-center justify-center"
                >
                  <TrendingUp className="w-6 h-6 text-white" />
                </motion.div>
                <div>
                  <span className="text-xl font-bold text-gray-800">Goals Progress</span>
                  <p className="text-sm text-gray-600 font-normal">Your financial journey</p>
                </div>
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="grid grid-cols-2 gap-6">
                <div className="text-center">
                  <p className="text-3xl font-bold text-gray-800">{formatCurrency(totalSaved)}</p>
                  <p className="text-sm text-gray-600">Total Saved</p>
                </div>
                <div className="text-center">
                  <p className="text-3xl font-bold text-gray-800">{formatCurrency(totalGoalsValue)}</p>
                  <p className="text-sm text-gray-600">Target Amount</p>
                </div>
              </div>
              
              <div className="space-y-3">
                <div className="flex justify-between text-sm">
                  <span>Overall Progress</span>
                  <span className="font-medium">
                    {totalGoalsValue > 0 ? ((totalSaved / totalGoalsValue) * 100).toFixed(0) : 0}%
                  </span>
                </div>
                <Progress 
                  value={totalGoalsValue > 0 ? (totalSaved / totalGoalsValue) * 100 : 0} 
                  className="h-4 rounded-full bg-gray-200 [&>div]:cartoon-gradient-mint"
                />
                <div className="flex justify-between text-sm text-gray-500">
                  <span>{completedGoals.length} completed</span>
                  <span>{activeGoals.length} active goals</span>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* Active Goals */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="space-y-6"
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <motion.div
                className="w-10 h-10 rounded-full cartoon-gradient-purple flex items-center justify-center"
                whileHover={{ rotate: 180 }}
                transition={{ duration: 0.5 }}
              >
                <Sparkles className="w-5 h-5 text-white" />
              </motion.div>
              <div>
                <h2 className="text-xl font-bold text-gray-800">Active Goals</h2>
                <p className="text-sm text-gray-600">Keep pushing forward</p>
              </div>
            </div>
            
            <Button
              onClick={() => setShowAddGoal(true)}
              className="cartoon-button cartoon-gradient-purple text-white border-0 hover:shadow-xl transition-all duration-200"
            >
              <Plus className="w-4 h-4 mr-2" />
              Add Goal
            </Button>
          </div>

          {/* Goals List */}
          <div className="space-y-4">
            {activeGoals.length === 0 ? (
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="text-center py-16"
              >
                <div className="text-8xl mb-6">🎯</div>
                <h3 className="text-2xl font-bold text-gray-700 mb-3">No active goals yet</h3>
                <p className="text-gray-500 mb-8">Create your first financial goal to get started!</p>
                <Button
                  onClick={() => setShowAddGoal(true)}
                  className="cartoon-button cartoon-gradient-purple text-white px-8 py-4 text-lg"
                >
                  <Plus className="w-5 h-5 mr-3" />
                  Create Your First Goal
                </Button>
              </motion.div>
            ) : (
              activeGoals.map((goal, index) => (
                <motion.div
                  key={goal.id}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ duration: 0.3, delay: index * 0.1 }}
                >
                  <Card className="cartoon-card bg-gradient-to-br from-white to-cartoon-purple/5 border-0">
                    <CardContent className="p-6">
                      <div className="flex items-start justify-between mb-4">
                        <div className="flex items-center gap-4">
                          <div className="text-3xl">{getCategoryEmoji(goal.category)}</div>
                          <div>
                            <h3 className="font-bold text-gray-800 text-lg">{goal.title}</h3>
                            <p className="text-gray-600">{goal.description}</p>
                          </div>
                        </div>
                        <div className="flex flex-col items-end gap-2">
                          <Badge className={`text-xs font-semibold ${getPriorityColor(goal.priority)}`}>
                            {goal.priority}
                          </Badge>
                          <div className="flex items-center gap-1 text-cartoon-yellow">
                            <Star className="w-4 h-4 fill-current" />
                            <span className="font-semibold">{goal.pointsReward} pts</span>
                          </div>
                        </div>
                      </div>
                      
                      <div className="space-y-4">
                        <div className="flex justify-between text-lg">
                          <span className="font-semibold">{formatCurrency(goal.currentAmount)}</span>
                          <span className="text-gray-600">{formatCurrency(goal.targetAmount)}</span>
                        </div>
                        
                        <Progress 
                          value={getProgressPercentage(goal.currentAmount, goal.targetAmount)}
                          className="h-4 rounded-full bg-gray-100 [&>div]:cartoon-gradient-purple"
                        />
                        
                        <div className="flex justify-between items-center">
                          <div className="flex items-center gap-2 text-gray-500">
                            <Calendar className="w-4 h-4" />
                            <span className="text-sm">{new Date(goal.deadline).toLocaleDateString()}</span>
                          </div>
                          
                          <div className="flex gap-2">
                            <Button
                              size="sm"
                              onClick={() => handleQuickContribute(goal.id, 100)}
                              className="cartoon-button cartoon-gradient-mint text-white text-sm px-4"
                            >
                              +RM100
                            </Button>
                            <Button
                              size="sm"
                              onClick={() => handleQuickContribute(goal.id, 500)}
                              className="cartoon-button cartoon-gradient-blue text-white text-sm px-4"
                            >
                              +RM500
                            </Button>
                            <Button
                              size="sm"
                              onClick={() => handleContributeToGoalClick(goal.id)}
                              className="cartoon-button cartoon-gradient-orange text-white px-3"
                            >
                              <Wallet className="w-4 h-4" />
                            </Button>
                          </div>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                </motion.div>
              ))
            )}
          </div>
        </motion.div>

        {/* Completed Goals */}
        {completedGoals.length > 0 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.4 }}
            className="space-y-4"
          >
            <div className="flex items-center gap-3">
              <motion.div
                className="w-10 h-10 rounded-full cartoon-gradient-yellow flex items-center justify-center"
                whileHover={{ rotate: 360 }}
                transition={{ duration: 0.8 }}
              >
                <Trophy className="w-5 h-5 text-white" />
              </motion.div>
              <div>
                <h2 className="text-xl font-bold text-gray-800">Completed Goals</h2>
                <p className="text-sm text-gray-600">Achievements unlocked</p>
              </div>
            </div>
            
            <div className="space-y-3">
              {completedGoals.map((goal, index) => (
                <motion.div
                  key={goal.id}
                  initial={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ duration: 0.3, delay: index * 0.1 }}
                >
                  <Card className="cartoon-card bg-gradient-to-br from-cartoon-mint/10 to-cartoon-mint/5 border-cartoon-mint/20">
                    <CardContent className="p-5">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-4">
                          <div className="text-3xl">{getCategoryEmoji(goal.category)}</div>
                          <div>
                            <h3 className="font-bold text-gray-800 flex items-center gap-3">
                              {goal.title}
                              <Badge className="bg-cartoon-mint/20 text-cartoon-mint text-xs border-cartoon-mint/30">
                                Completed
                              </Badge>
                            </h3>
                            <p className="text-sm text-gray-600">
                              {goal.completedDate && `Completed on ${new Date(goal.completedDate).toLocaleDateString()}`}
                            </p>
                          </div>
                        </div>
                        
                        <div className="text-right">
                          <p className="font-bold text-cartoon-mint text-lg">{formatCurrency(goal.targetAmount)}</p>
                          <div className="flex items-center gap-1 text-cartoon-yellow">
                            <Star className="w-4 h-4 fill-current" />
                            <span className="text-sm font-semibold">+{goal.pointsReward} pts</span>
                          </div>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                </motion.div>
              ))}
            </div>
          </motion.div>
        )}
      </div>

      {/* Add Goal Modal with Blurred Background */}
      <AnimatePresence>
        {showAddGoal && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 flex items-center justify-center p-4"
          >
            {/* Blurred Backdrop */}
            <motion.div
              initial={{ backdropFilter: "blur(0px)" }}
              animate={{ backdropFilter: "blur(12px)" }}
              exit={{ backdropFilter: "blur(0px)" }}
              className="absolute inset-0 bg-black/20"
              onClick={() => setShowAddGoal(false)}
            />
            
            {/* Modal */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="relative z-10 w-full max-w-md"
            >
              <Card className="cartoon-card bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
                <CardHeader>
                  <CardTitle className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-full cartoon-gradient-purple flex items-center justify-center">
                      <Target className="w-4 h-4 text-white" />
                    </div>
                    Create New Goal
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <Label htmlFor="title">Goal Title</Label>
                    <Input
                      id="title"
                      value={newGoal.title}
                      onChange={(e) => setNewGoal({...newGoal, title: e.target.value})}
                      placeholder="e.g., New Car"
                      className="cartoon-button border-gray-200"
                    />
                  </div>
                  
                  <div>
                    <Label htmlFor="description">Description</Label>
                    <Input
                      id="description"
                      value={newGoal.description}
                      onChange={(e) => setNewGoal({...newGoal, description: e.target.value})}
                      placeholder="Brief description"
                      className="cartoon-button border-gray-200"
                    />
                  </div>
                  
                  <div>
                    <Label htmlFor="amount">Target Amount (RM)</Label>
                    <Input
                      id="amount"
                      type="number"
                      value={newGoal.targetAmount || ''}
                      onChange={(e) => setNewGoal({...newGoal, targetAmount: parseFloat(e.target.value) || 0})}
                      placeholder="0"
                      className="cartoon-button border-gray-200"
                    />
                  </div>
                  
                  <div>
                    <Label htmlFor="deadline">Deadline</Label>
                    <Input
                      id="deadline"
                      type="date"
                      value={newGoal.deadline}
                      onChange={(e) => setNewGoal({...newGoal, deadline: e.target.value})}
                      className="cartoon-button border-gray-200"
                    />
                  </div>
                  
                  <div className="flex gap-3 pt-4">
                    <Button
                      onClick={() => setShowAddGoal(false)}
                      variant="outline"
                      className="flex-1 cartoon-button"
                    >
                      Cancel
                    </Button>
                    <Button
                      onClick={handleAddGoal}
                      className="flex-1 cartoon-button cartoon-gradient-purple text-white"
                    >
                      Create Goal
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Contribute Modal with Blurred Background */}
      <AnimatePresence>
        {showContributeModal && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 flex items-center justify-center p-4"
          >
            {/* Blurred Backdrop */}
            <motion.div
              initial={{ backdropFilter: "blur(0px)" }}
              animate={{ backdropFilter: "blur(12px)" }}
              exit={{ backdropFilter: "blur(0px)" }}
              className="absolute inset-0 bg-black/20"
              onClick={() => {
                setShowContributeModal(false);
                setContributionAmount('');
                setSelectedGoalId('');
              }}
            />
            
            {/* Modal */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="relative z-10 w-full max-w-sm"
            >
              <Card className="cartoon-card bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
                <CardHeader>
                  <CardTitle className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-full cartoon-gradient-mint flex items-center justify-center">
                      <Wallet className="w-4 h-4 text-white" />
                    </div>
                    Add Money to Goal
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <Label htmlFor="contribution">Amount (RM)</Label>
                    <Input
                      id="contribution"
                      type="number"
                      value={contributionAmount}
                      onChange={(e) => setContributionAmount(e.target.value)}
                      placeholder="Enter amount"
                      className="text-lg cartoon-button border-gray-200"
                    />
                  </div>
                  
                  {/* Quick amount buttons */}
                  <div className="grid grid-cols-3 gap-2">
                    {[50, 100, 200, 500, 1000, 2000].map((amount) => (
                      <Button
                        key={amount}
                        variant="outline"
                        size="sm"
                        onClick={() => setContributionAmount(amount.toString())}
                        className="cartoon-button text-xs border-gray-200 hover:cartoon-gradient-mint hover:text-white"
                      >
                        RM{amount}
                      </Button>
                    ))}
                  </div>
                  
                  <div className="flex gap-3 pt-4">
                    <Button
                      onClick={() => {
                        setShowContributeModal(false);
                        setContributionAmount('');
                        setSelectedGoalId('');
                      }}
                      variant="outline"
                      className="flex-1 cartoon-button"
                    >
                      Cancel
                    </Button>
                    <Button
                      onClick={handleContributeSubmit}
                      disabled={!contributionAmount || parseFloat(contributionAmount) <= 0}
                      className="flex-1 cartoon-button cartoon-gradient-mint text-white"
                    >
                      Add Money
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}