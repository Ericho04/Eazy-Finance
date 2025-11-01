import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { Hono } from "npm:hono";
import { cors } from "npm:hono/cors";
import { logger } from "npm:hono/logger";
import * as kv from './kv_store.tsx';

const app = new Hono();

// Middleware
app.use('*', cors({
  origin: '*',
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['*'],
}));

app.use('*', logger(console.log));

// Helper functions
function generateId(): string {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

function getCurrentTimestamp(): string {
  return new Date().toISOString();
}

// Routes

// User Profile Routes
app.get('/make-server-2f663dc1/user/:userId', async (c) => {
  try {
    const userId = c.req.param('userId');
    const profile = await kv.get(`user:${userId}`);
    
    if (!profile) {
      return c.json({ error: 'User not found' }, 404);
    }
    
    return c.json(profile);
  } catch (error) {
    console.error('Error fetching user profile:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

app.put('/make-server-2f663dc1/user/:userId', async (c) => {
  try {
    const userId = c.req.param('userId');
    const updates = await c.req.json();
    
    let profile = await kv.get(`user:${userId}`);
    
    if (!profile) {
      // Create new profile
      profile = {
        id: userId,
        email: updates.email || '',
        name: updates.name || '',
        currency: 'RM',
        language: 'en',
        timezone: 'Asia/Kuala_Lumpur',
        preferences: {
          notifications: {
            budgetAlerts: true,
            goalReminders: true,
            expenseNotifications: false,
            weeklyReports: true
          },
          theme: 'system'
        },
        createdAt: getCurrentTimestamp(),
        updatedAt: getCurrentTimestamp()
      };
    }
    
    // Update profile
    const updatedProfile = {
      ...profile,
      ...updates,
      updatedAt: getCurrentTimestamp()
    };
    
    await kv.set(`user:${userId}`, updatedProfile);
    return c.json(updatedProfile);
  } catch (error) {
    console.error('Error updating user profile:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// Transaction Routes
app.get('/make-server-2f663dc1/transactions/:userId', async (c) => {
  try {
    const userId = c.req.param('userId');
    const { category, dateFrom, dateTo, type, search } = c.req.query();
    
    const transactionKeys = await kv.getByPrefix(`transaction:${userId}:`);
    let transactions = transactionKeys.map(item => item.value);
    
    // Apply filters
    if (category && category !== 'all') {
      transactions = transactions.filter(t => t.category === category);
    }
    
    if (type) {
      transactions = transactions.filter(t => t.type === type);
    }
    
    if (dateFrom) {
      transactions = transactions.filter(t => new Date(t.date) >= new Date(dateFrom));
    }
    
    if (dateTo) {
      transactions = transactions.filter(t => new Date(t.date) <= new Date(dateTo));
    }
    
    if (search) {
      const searchLower = search.toLowerCase();
      transactions = transactions.filter(t => 
        t.description.toLowerCase().includes(searchLower) ||
        (t.merchant && t.merchant.toLowerCase().includes(searchLower))
      );
    }
    
    // Sort by date (newest first)
    transactions.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
    
    return c.json(transactions);
  } catch (error) {
    console.error('Error fetching transactions:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

app.post('/make-server-2f663dc1/transactions', async (c) => {
  try {
    const transactionData = await c.req.json();
    const transaction = {
      ...transactionData,
      id: generateId(),
      createdAt: getCurrentTimestamp(),
      updatedAt: getCurrentTimestamp()
    };
    
    await kv.set(`transaction:${transaction.userId}:${transaction.id}`, transaction);
    
    // Update budget if it's an expense
    if (transaction.type === 'expense') {
      await updateBudgetSpending(transaction.userId, transaction.category, transaction.amount);
    }
    
    return c.json(transaction);
  } catch (error) {
    console.error('Error adding transaction:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

app.put('/make-server-2f663dc1/transactions/:transactionId', async (c) => {
  try {
    const transactionId = c.req.param('transactionId');
    const updates = await c.req.json();
    
    // Find the transaction
    const allTransactions = await kv.getByPrefix('transaction:');
    const transactionItem = allTransactions.find(item => item.value.id === transactionId);
    
    if (!transactionItem) {
      return c.json({ error: 'Transaction not found' }, 404);
    }
    
    const transaction = transactionItem.value;
    const updatedTransaction = {
      ...transaction,
      ...updates,
      updatedAt: getCurrentTimestamp()
    };
    
    await kv.set(transactionItem.key, updatedTransaction);
    return c.json(updatedTransaction);
  } catch (error) {
    console.error('Error updating transaction:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

app.delete('/make-server-2f663dc1/transactions/:transactionId', async (c) => {
  try {
    const transactionId = c.req.param('transactionId');
    
    // Find and delete the transaction
    const allTransactions = await kv.getByPrefix('transaction:');
    const transactionItem = allTransactions.find(item => item.value.id === transactionId);
    
    if (!transactionItem) {
      return c.json({ error: 'Transaction not found' }, 404);
    }
    
    await kv.del(transactionItem.key);
    return c.json({ success: true });
  } catch (error) {
    console.error('Error deleting transaction:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// Budget Routes
app.get('/make-server-2f663dc1/budgets/:userId', async (c) => {
  try {
    const userId = c.req.param('userId');
    const budgetKeys = await kv.getByPrefix(`budget:${userId}:`);
    const budgets = budgetKeys.map(item => item.value);
    
    return c.json(budgets);
  } catch (error) {
    console.error('Error fetching budgets:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

app.post('/make-server-2f663dc1/budgets', async (c) => {
  try {
    const budgetData = await c.req.json();
    const budget = {
      ...budgetData,
      id: generateId(),
      spent: 0,
      createdAt: getCurrentTimestamp(),
      updatedAt: getCurrentTimestamp()
    };
    
    await kv.set(`budget:${budget.userId}:${budget.id}`, budget);
    return c.json(budget);
  } catch (error) {
    console.error('Error adding budget:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// Goal Routes
app.get('/make-server-2f663dc1/goals/:userId', async (c) => {
  try {
    const userId = c.req.param('userId');
    const goalKeys = await kv.getByPrefix(`goal:${userId}:`);
    const goals = goalKeys.map(item => item.value);
    
    return c.json(goals);
  } catch (error) {
    console.error('Error fetching goals:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

app.post('/make-server-2f663dc1/goals', async (c) => {
  try {
    const goalData = await c.req.json();
    const goal = {
      ...goalData,
      id: generateId(),
      currentAmount: 0,
      createdAt: getCurrentTimestamp(),
      updatedAt: getCurrentTimestamp()
    };
    
    await kv.set(`goal:${goal.userId}:${goal.id}`, goal);
    return c.json(goal);
  } catch (error) {
    console.error('Error adding goal:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// Analytics Routes
app.get('/make-server-2f663dc1/analytics/:userId', async (c) => {
  try {
    const userId = c.req.param('userId');
    const period = c.req.query('period') || 'monthly';
    
    const transactionKeys = await kv.getByPrefix(`transaction:${userId}:`);
    const transactions = transactionKeys.map(item => item.value);
    
    // Calculate totals
    const totalIncome = transactions
      .filter(t => t.type === 'income')
      .reduce((sum, t) => sum + t.amount, 0);
    
    const totalExpenses = transactions
      .filter(t => t.type === 'expense')
      .reduce((sum, t) => sum + t.amount, 0);
    
    const totalSavings = totalIncome - totalExpenses;
    
    // Category breakdown for expenses
    const categoryTotals = {};
    transactions
      .filter(t => t.type === 'expense')
      .forEach(t => {
        categoryTotals[t.category] = (categoryTotals[t.category] || 0) + t.amount;
      });
    
    const categoryBreakdown = Object.entries(categoryTotals).map(([category, amount]) => ({
      category,
      amount: amount as number,
      percentage: Math.round(((amount as number) / totalExpenses) * 100)
    }));
    
    // Generate trends data based on period
    const trends = generateTrendsData(transactions, period);
    
    return c.json({
      totalIncome,
      totalExpenses,
      totalSavings,
      categoryBreakdown,
      trends
    });
  } catch (error) {
    console.error('Error generating analytics:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// AI Suggestions Routes
app.get('/make-server-2f663dc1/ai/suggestions/:userId', async (c) => {
  try {
    const userId = c.req.param('userId');
    
    // Get user's transactions and budgets
    const transactionKeys = await kv.getByPrefix(`transaction:${userId}:`);
    const transactions = transactionKeys.map(item => item.value);
    
    const budgetKeys = await kv.getByPrefix(`budget:${userId}:`);
    const budgets = budgetKeys.map(item => item.value);
    
    // Generate AI suggestions based on spending patterns
    const suggestions = generateAISuggestions(transactions, budgets);
    
    return c.json(suggestions);
  } catch (error) {
    console.error('Error generating AI suggestions:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// Helper functions
async function updateBudgetSpending(userId: string, category: string, amount: number) {
  try {
    const budgetKeys = await kv.getByPrefix(`budget:${userId}:`);
    const budget = budgetKeys.find(item => item.value.category === category && item.value.isActive);
    
    if (budget) {
      const updatedBudget = {
        ...budget.value,
        spent: budget.value.spent + amount,
        updatedAt: getCurrentTimestamp()
      };
      
      await kv.set(budget.key, updatedBudget);
    }
  } catch (error) {
    console.error('Error updating budget spending:', error);
  }
}

function generateTrendsData(transactions: any[], period: string) {
  const now = new Date();
  const trends = [];
  
  for (let i = 5; i >= 0; i--) {
    let periodStart: Date;
    let periodEnd: Date;
    let label: string;
    
    if (period === 'weekly') {
      periodStart = new Date(now.getTime() - (i + 1) * 7 * 24 * 60 * 60 * 1000);
      periodEnd = new Date(now.getTime() - i * 7 * 24 * 60 * 60 * 1000);
      label = `Week ${6 - i}`;
    } else if (period === 'yearly') {
      periodStart = new Date(now.getFullYear() - i - 1, 0, 1);
      periodEnd = new Date(now.getFullYear() - i, 0, 1);
      label = (now.getFullYear() - i).toString();
    } else {
      periodStart = new Date(now.getFullYear(), now.getMonth() - i - 1, 1);
      periodEnd = new Date(now.getFullYear(), now.getMonth() - i, 1);
      label = periodStart.toLocaleDateString('en-MY', { month: 'short' });
    }
    
    const periodTransactions = transactions.filter(t => {
      const tDate = new Date(t.date);
      return tDate >= periodStart && tDate < periodEnd;
    });
    
    const income = periodTransactions
      .filter(t => t.type === 'income')
      .reduce((sum, t) => sum + t.amount, 0);
    
    const expenses = periodTransactions
      .filter(t => t.type === 'expense')
      .reduce((sum, t) => sum + t.amount, 0);
    
    trends.push({
      period: label,
      income,
      expenses,
      savings: income - expenses
    });
  }
  
  return trends;
}

function generateAISuggestions(transactions: any[], budgets: any[]) {
  const suggestions = [];
  const now = new Date();
  const thisMonth = transactions.filter(t => {
    const tDate = new Date(t.date);
    return tDate.getMonth() === now.getMonth() && tDate.getFullYear() === now.getFullYear();
  });
  
  // Category spending analysis
  const categorySpending = {};
  thisMonth.filter(t => t.type === 'expense').forEach(t => {
    categorySpending[t.category] = (categorySpending[t.category] || 0) + t.amount;
  });
  
  // Find highest spending categories
  const sortedCategories = Object.entries(categorySpending)
    .sort(([,a], [,b]) => (b as number) - (a as number))
    .slice(0, 3);
  
  sortedCategories.forEach(([category, amount], index) => {
    if (amount > 300) { // Threshold for suggestions
      suggestions.push({
        id: generateId(),
        type: 'spending',
        title: `Reduce ${category} Expenses`,
        description: `You've spent RM ${amount.toFixed(0)} on ${category} this month. Consider reducing by 15%.`,
        impact: `Save RM ${(amount * 0.15).toFixed(0)} monthly`,
        priority: index === 0 ? 'high' : 'medium',
        category,
        savings: amount * 0.15
      });
    }
  });
  
  // Budget overspending alerts
  budgets.filter(b => b.isActive).forEach(budget => {
    const spent = categorySpending[budget.category] || 0;
    if (spent > budget.allocated * 0.8) {
      suggestions.push({
        id: generateId(),
        type: 'budget',
        title: `${budget.category} Budget Alert`,
        description: `You've used ${Math.round((spent / budget.allocated) * 100)}% of your ${budget.category} budget.`,
        impact: spent > budget.allocated ? 'Over budget!' : 'Approaching limit',
        priority: spent > budget.allocated ? 'high' : 'medium',
        category: budget.category
      });
    }
  });
  
  // General savings suggestions
  const totalIncome = transactions
    .filter(t => t.type === 'income')
    .reduce((sum, t) => sum + t.amount, 0);
  
  const totalExpenses = transactions
    .filter(t => t.type === 'expense')
    .reduce((sum, t) => sum + t.amount, 0);
  
  const savingsRate = ((totalIncome - totalExpenses) / totalIncome) * 100;
  
  if (savingsRate < 20) {
    suggestions.push({
      id: generateId(),
      type: 'saving',
      title: 'Boost Your Savings Rate',
      description: `Your current savings rate is ${savingsRate.toFixed(1)}%. Aim for at least 20%.`,
      impact: 'Build financial security',
      priority: 'medium'
    });
  }
  
  return suggestions;
}

serve(app.fetch);