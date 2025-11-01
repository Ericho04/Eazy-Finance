import React, { createContext, useContext, useReducer, ReactNode, useEffect } from 'react';

// Types
export interface Transaction {
  id: string;
  userId: string;
  type: 'income' | 'expense';
  amount: number;
  category: string;
  description: string;
  date: string;
  createdAt: string;
}

export interface Budget {
  id: string;
  userId: string;
  category: string;
  amount: number;
  spent: number;
  period: 'weekly' | 'monthly' | 'yearly';
  createdAt: string;
}

export interface Goal {
  id: string;
  userId: string;
  title: string;
  description: string;
  targetAmount: number;
  currentAmount: number;
  deadline: string;
  category: string;
  priority: 'low' | 'medium' | 'high';
  pointsReward: number;
  isCompleted: boolean;
  completedDate?: string;
  createdAt: string;
}

export interface AppState {
  transactions: Transaction[];
  budgets: Budget[];
  goals: Goal[];
  rewardPoints: number;
  isLoading: boolean;
  error: string | null;
}

// Actions
type AppAction =
  | { type: 'ADD_TRANSACTION'; payload: Transaction }
  | { type: 'UPDATE_TRANSACTION'; payload: Transaction }
  | { type: 'DELETE_TRANSACTION'; payload: string }
  | { type: 'ADD_BUDGET'; payload: Budget }
  | { type: 'UPDATE_BUDGET'; payload: Budget }
  | { type: 'DELETE_BUDGET'; payload: string }
  | { type: 'ADD_GOAL'; payload: Goal }
  | { type: 'UPDATE_GOAL'; payload: Goal }
  | { type: 'DELETE_GOAL'; payload: string }
  | { type: 'CONTRIBUTE_TO_GOAL'; payload: { goalId: string; amount: number } }
  | { type: 'ADD_REWARD_POINTS'; payload: number }
  | { type: 'SPEND_REWARD_POINTS'; payload: number }
  | { type: 'SET_LOADING'; payload: boolean }
  | { type: 'SET_ERROR'; payload: string | null }
  | { type: 'LOAD_DATA'; payload: Partial<AppState> };

// Initial state with sample data
const initialState: AppState = {
  transactions: [
    {
      id: '1',
      userId: 'demo-user',
      type: 'expense',
      amount: 25.50,
      category: 'Food & Dining',
      description: 'Lunch at cafe',
      date: new Date().toISOString().split('T')[0],
      createdAt: new Date().toISOString(),
    },
    {
      id: '2',
      userId: 'demo-user',
      type: 'income',
      amount: 3000,
      category: 'Salary',
      description: 'Monthly salary',
      date: new Date().toISOString().split('T')[0],
      createdAt: new Date().toISOString(),
    }
  ],
  budgets: [
    {
      id: '1',
      userId: 'demo-user',
      category: 'Food & Dining',
      amount: 500,
      spent: 125.50,
      period: 'monthly',
      createdAt: new Date().toISOString(),
    },
    {
      id: '2',
      userId: 'demo-user',
      category: 'Transportation',
      amount: 300,
      spent: 85,
      period: 'monthly',
      createdAt: new Date().toISOString(),
    }
  ],
  goals: [
    {
      id: '1',
      userId: 'demo-user',
      title: 'Emergency Fund',
      description: 'Build 6 months of expenses',
      targetAmount: 15000,
      currentAmount: 8500,
      deadline: '2024-12-31',
      category: 'emergency',
      priority: 'high',
      pointsReward: 150,
      isCompleted: false,
      createdAt: new Date().toISOString(),
    },
    {
      id: '2',
      userId: 'demo-user',
      title: 'Vacation to Japan',
      description: 'Save for dream vacation',
      targetAmount: 8000,
      currentAmount: 3200,
      deadline: '2024-10-15',
      category: 'travel',
      priority: 'medium',
      pointsReward: 80,
      isCompleted: false,
      createdAt: new Date().toISOString(),
    },
    {
      id: '3',
      userId: 'demo-user',
      title: 'New Laptop',
      description: 'MacBook Pro for work',
      targetAmount: 2500,
      currentAmount: 2500,
      deadline: '2024-06-30',
      category: 'technology',
      priority: 'low',
      pointsReward: 25,
      isCompleted: true,
      completedDate: '2024-06-25',
      createdAt: new Date(Date.now() - 90 * 24 * 60 * 60 * 1000).toISOString(),
    }
  ],
  rewardPoints: 850,
  isLoading: false,
  error: null,
};

// Reducer
function appReducer(state: AppState, action: AppAction): AppState {
  switch (action.type) {
    case 'ADD_TRANSACTION':
      return {
        ...state,
        transactions: [...state.transactions, action.payload],
      };

    case 'UPDATE_TRANSACTION':
      return {
        ...state,
        transactions: state.transactions.map(t =>
          t.id === action.payload.id ? action.payload : t
        ),
      };

    case 'DELETE_TRANSACTION':
      return {
        ...state,
        transactions: state.transactions.filter(t => t.id !== action.payload),
      };

    case 'ADD_BUDGET':
      return {
        ...state,
        budgets: [...state.budgets, action.payload],
      };

    case 'UPDATE_BUDGET':
      return {
        ...state,
        budgets: state.budgets.map(b =>
          b.id === action.payload.id ? action.payload : b
        ),
      };

    case 'DELETE_BUDGET':
      return {
        ...state,
        budgets: state.budgets.filter(b => b.id !== action.payload),
      };

    case 'ADD_GOAL':
      const newGoal = {
        ...action.payload,
        id: action.payload.id || Date.now().toString(),
        userId: 'demo-user',
        createdAt: new Date().toISOString(),
      };
      return {
        ...state,
        goals: [...state.goals, newGoal],
      };

    case 'UPDATE_GOAL':
      return {
        ...state,
        goals: state.goals.map(g =>
          g.id === action.payload.id ? action.payload : g
        ),
      };

    case 'DELETE_GOAL':
      return {
        ...state,
        goals: state.goals.filter(g => g.id !== action.payload),
      };

    case 'CONTRIBUTE_TO_GOAL':
      return {
        ...state,
        goals: state.goals.map(goal => {
          if (goal.id === action.payload.goalId && !goal.isCompleted) {
            const newAmount = goal.currentAmount + action.payload.amount;
            const isCompleted = newAmount >= goal.targetAmount;

            return {
              ...goal,
              currentAmount: isCompleted ? goal.targetAmount : newAmount,
              isCompleted,
              completedDate: isCompleted ? new Date().toISOString().split('T')[0] : goal.completedDate,
            };
          }
          return goal;
        }),
        rewardPoints: (() => {
          const goal = state.goals.find(g => g.id === action.payload.goalId);
          if (goal && !goal.isCompleted) {
            const newAmount = goal.currentAmount + action.payload.amount;
            const isCompleted = newAmount >= goal.targetAmount;
            return isCompleted ? state.rewardPoints + goal.pointsReward : state.rewardPoints;
          }
          return state.rewardPoints;
        })(),
      };

    case 'ADD_REWARD_POINTS':
      return {
        ...state,
        rewardPoints: state.rewardPoints + action.payload,
      };

    case 'SPEND_REWARD_POINTS':
      return {
        ...state,
        rewardPoints: Math.max(0, state.rewardPoints - action.payload),
      };

    case 'SET_LOADING':
      return {
        ...state,
        isLoading: action.payload,
      };

    case 'SET_ERROR':
      return {
        ...state,
        error: action.payload,
      };

    case 'LOAD_DATA':
      return {
        ...state,
        ...action.payload,
      };

    default:
      return state;
  }
}

// Context
interface AppContextType {
  state: AppState;
  addTransaction: (transaction: Omit<Transaction, 'id' | 'userId' | 'createdAt'>) => void;
  updateTransaction: (transaction: Transaction) => void;
  deleteTransaction: (id: string) => void;
  addBudget: (budget: Omit<Budget, 'id' | 'userId' | 'createdAt' | 'spent'>) => void;
  updateBudget: (budget: Budget) => void;
  deleteBudget: (id: string) => void;
  addGoal: (goal: Omit<Goal, 'id' | 'userId' | 'createdAt' | 'currentAmount' | 'isCompleted'>) => void;
  updateGoal: (goal: Goal) => void;
  deleteGoal: (id: string) => void;
  contributeToGoal: (goalId: string, amount: number) => void;
  addRewardPoints: (points: number) => void;
  spendRewardPoints: (points: number) => void;
  getActiveGoals: () => Goal[];
  getCompletedGoals: () => Goal[];
  getTodayTransactions: () => Transaction[];
  getRecentTransactions: (limit?: number) => Transaction[];
  getCategorySpending: (category: string) => number;
  getMonthlySpending: () => number;
  calculateTotals: () => { totalIncome: number; totalExpenses: number; totalSavings: number };
}

const AppContext = createContext<AppContextType | undefined>(undefined);

// Provider component
export function AppProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(appReducer, initialState);

  // Load data from localStorage on mount
  useEffect(() => {
    const savedData = localStorage.getItem('sfms-app-data');
    if (savedData) {
      try {
        const parsedData = JSON.parse(savedData);
        dispatch({ type: 'LOAD_DATA', payload: parsedData });
      } catch (error) {
        console.error('Error loading saved data:', error);
      }
    }
  }, []);

  // Save data to localStorage whenever state changes
  useEffect(() => {
    localStorage.setItem('sfms-app-data', JSON.stringify(state));
  }, [state]);

  // Actions
  const addTransaction = (transaction: Omit<Transaction, 'id' | 'userId' | 'createdAt'>) => {
    const newTransaction: Transaction = {
      ...transaction,
      id: Date.now().toString(),
      userId: 'demo-user',
      createdAt: new Date().toISOString(),
    };
    dispatch({ type: 'ADD_TRANSACTION', payload: newTransaction });
  };

  const updateTransaction = (transaction: Transaction) => {
    dispatch({ type: 'UPDATE_TRANSACTION', payload: transaction });
  };

  const deleteTransaction = (id: string) => {
    dispatch({ type: 'DELETE_TRANSACTION', payload: id });
  };

  const addBudget = (budget: Omit<Budget, 'id' | 'userId' | 'createdAt' | 'spent'>) => {
    const newBudget: Budget = {
      ...budget,
      id: Date.now().toString(),
      userId: 'demo-user',
      spent: 0,
      createdAt: new Date().toISOString(),
    };
    dispatch({ type: 'ADD_BUDGET', payload: newBudget });
  };

  const updateBudget = (budget: Budget) => {
    dispatch({ type: 'UPDATE_BUDGET', payload: budget });
  };

  const deleteBudget = (id: string) => {
    dispatch({ type: 'DELETE_BUDGET', payload: id });
  };

  const addGoal = (goalData: Omit<Goal, 'id' | 'userId' | 'createdAt' | 'currentAmount' | 'isCompleted'>) => {
    const newGoal: Goal = {
      ...goalData,
      id: Date.now().toString(),
      userId: 'demo-user',
      currentAmount: 0,
      isCompleted: false,
      pointsReward: Math.floor(goalData.targetAmount / 100), // 1 point per RM100
      createdAt: new Date().toISOString(),
    };
    dispatch({ type: 'ADD_GOAL', payload: newGoal });
  };

  const updateGoal = (goal: Goal) => {
    dispatch({ type: 'UPDATE_GOAL', payload: goal });
  };

  const deleteGoal = (id: string) => {
    dispatch({ type: 'DELETE_GOAL', payload: id });
  };

  const contributeToGoal = (goalId: string, amount: number) => {
    dispatch({ type: 'CONTRIBUTE_TO_GOAL', payload: { goalId, amount } });
  };

  const addRewardPoints = (points: number) => {
    dispatch({ type: 'ADD_REWARD_POINTS', payload: points });
  };

  const spendRewardPoints = (points: number) => {
    dispatch({ type: 'SPEND_REWARD_POINTS', payload: points });
  };

  // Helper functions
  const getActiveGoals = () => state.goals.filter(goal => !goal.isCompleted);

  const getCompletedGoals = () => state.goals.filter(goal => goal.isCompleted);

  const getTodayTransactions = () => {
    const today = new Date().toISOString().split('T')[0];
    return state.transactions.filter(t => t.date === today);
  };

  const getRecentTransactions = (limit = 10) => {
    return [...state.transactions]
      .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
      .slice(0, limit);
  };

  const getCategorySpending = (category: string) => {
    const currentMonth = new Date().getMonth();
    const currentYear = new Date().getFullYear();

    return state.transactions
      .filter(t => {
        const transactionDate = new Date(t.date);
        return (
          t.type === 'expense' &&
          t.category === category &&
          transactionDate.getMonth() === currentMonth &&
          transactionDate.getFullYear() === currentYear
        );
      })
      .reduce((sum, t) => sum + t.amount, 0);
  };

  const getMonthlySpending = () => {
    const currentMonth = new Date().getMonth();
    const currentYear = new Date().getFullYear();

    return state.transactions
      .filter(t => {
        const transactionDate = new Date(t.date);
        return (
          t.type === 'expense' &&
          transactionDate.getMonth() === currentMonth &&
          transactionDate.getFullYear() === currentYear
        );
      })
      .reduce((sum, t) => sum + t.amount, 0);
  };

  // Calculate totals function - the missing function that was causing the error
  const calculateTotals = () => {
    const currentMonth = new Date().getMonth();
    const currentYear = new Date().getFullYear();

    const monthlyTransactions = state.transactions.filter(t => {
      const transactionDate = new Date(t.date);
      return (
        transactionDate.getMonth() === currentMonth &&
        transactionDate.getFullYear() === currentYear
      );
    });

    const totalIncome = monthlyTransactions
      .filter(t => t.type === 'income')
      .reduce((sum, t) => sum + t.amount, 0);

    const totalExpenses = monthlyTransactions
      .filter(t => t.type === 'expense')
      .reduce((sum, t) => sum + t.amount, 0);

    const totalSavings = totalIncome - totalExpenses;

    return {
      totalIncome,
      totalExpenses,
      totalSavings,
    };
  };

  const contextValue: AppContextType = {
    state,
    addTransaction,
    updateTransaction,
    deleteTransaction,
    addBudget,
    updateBudget,
    deleteBudget,
    addGoal,
    updateGoal,
    deleteGoal,
    contributeToGoal,
    addRewardPoints,
    spendRewardPoints,
    getActiveGoals,
    getCompletedGoals,
    getTodayTransactions,
    getRecentTransactions,
    getCategorySpending,
    getMonthlySpending,
    calculateTotals, // Added the missing function
  };

  return (
    <AppContext.Provider value={contextValue}>
      {children}
    </AppContext.Provider>
  );
}

// Hook to use the context
export function useApp() {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
}