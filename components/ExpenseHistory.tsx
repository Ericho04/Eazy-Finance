import { useState } from "react";
import { Card, CardContent } from "./ui/card";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";
import { ArrowLeft, Filter, Search, MoreVertical } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";
import { FilterSheet } from "./FilterSheet";

interface ExpenseHistoryProps {
  onBack: () => void;
}

interface ExpenseTransaction {
  id: string;
  name: string;
  category: string;
  amount: number;
  date: string;
  time: string;
  type: 'expense' | 'income';
  merchant?: string;
  status: 'completed' | 'pending' | 'failed';
}

export function ExpenseHistory({ onBack }: ExpenseHistoryProps) {
  const [isFilterOpen, setIsFilterOpen] = useState(false);
  const [filteredTransactions, setFilteredTransactions] = useState<ExpenseTransaction[]>([]);
  
  // Mock transaction data
  const allTransactions: ExpenseTransaction[] = [
    {
      id: '1',
      name: 'McDonald\'s',
      category: 'Food & Dining',
      amount: -15.90,
      date: '2024-12-18',
      time: '14:30',
      type: 'expense',
      merchant: 'McDonald\'s Pavilion KL',
      status: 'completed'
    },
    {
      id: '2',
      name: 'Salary',
      category: 'Income',
      amount: 3500.00,
      date: '2024-12-15',
      time: '09:00',
      type: 'income',
      status: 'completed'
    },
    {
      id: '3',
      name: 'Grab',
      category: 'Transportation',
      amount: -12.50,
      date: '2024-12-18',
      time: '08:45',
      type: 'expense',
      merchant: 'Grab Malaysia',
      status: 'completed'
    },
    {
      id: '4',
      name: 'Starbucks',
      category: 'Food & Dining',
      amount: -18.20,
      date: '2024-12-17',
      time: '16:15',
      type: 'expense',
      merchant: 'Starbucks KLCC',
      status: 'completed'
    },
    {
      id: '5',
      name: 'TNB Bill',
      category: 'Bills & Utilities',
      amount: -89.50,
      date: '2024-12-16',
      time: '11:20',
      type: 'expense',
      status: 'pending'
    },
    {
      id: '6',
      name: 'Shopee',
      category: 'Shopping',
      amount: -45.60,
      date: '2024-12-15',
      time: '20:30',
      type: 'expense',
      merchant: 'Shopee Malaysia',
      status: 'completed'
    },
    {
      id: '7',
      name: 'Cinema',
      category: 'Entertainment',
      amount: -28.00,
      date: '2024-12-14',
      time: '19:45',
      type: 'expense',
      merchant: 'TGV Cinemas',
      status: 'completed'
    },
    {
      id: '8',
      name: 'Freelance Work',
      category: 'Income',
      amount: 800.00,
      date: '2024-12-13',
      time: '15:00',
      type: 'income',
      status: 'completed'
    }
  ];

  useState(() => {
    setFilteredTransactions(allTransactions);
  });

  const handleFilter = (searchTerm: string, category: string, dateRange: string) => {
    let filtered = [...allTransactions];

    // Search by name/merchant
    if (searchTerm) {
      filtered = filtered.filter(transaction => 
        transaction.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        transaction.merchant?.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    // Filter by category
    if (category && category !== 'all') {
      filtered = filtered.filter(transaction => transaction.category === category);
    }

    // Filter by date range
    if (dateRange && dateRange !== 'all') {
      const today = new Date();
      const transactionDate = new Date();
      
      switch (dateRange) {
        case 'today':
          filtered = filtered.filter(transaction => {
            const txDate = new Date(transaction.date);
            return txDate.toDateString() === today.toDateString();
          });
          break;
        case 'week':
          const weekAgo = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);
          filtered = filtered.filter(transaction => {
            const txDate = new Date(transaction.date);
            return txDate >= weekAgo;
          });
          break;
        case 'month':
          const monthAgo = new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000);
          filtered = filtered.filter(transaction => {
            const txDate = new Date(transaction.date);
            return txDate >= monthAgo;
          });
          break;
      }
    }

    setFilteredTransactions(filtered);
    setIsFilterOpen(false);
  };

  const getCategoryIcon = (category: string) => {
    const icons: { [key: string]: string } = {
      'Food & Dining': '🍽️',
      'Transportation': '🚗',
      'Shopping': '🛍️',
      'Bills & Utilities': '💡',
      'Entertainment': '🎬',
      'Income': '💰',
      'Healthcare': '⚕️',
      'Education': '📚'
    };
    return icons[category] || '💳';
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'bg-[color:var(--sfms-success)]/10 text-[color:var(--sfms-success)]';
      case 'pending':
        return 'bg-[color:var(--sfms-warning)]/10 text-[color:var(--sfms-warning)]';
      case 'failed':
        return 'bg-[color:var(--sfms-danger)]/10 text-[color:var(--sfms-danger)]';
      default:
        return 'bg-muted text-muted-foreground';
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const today = new Date();
    const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
    
    if (date.toDateString() === today.toDateString()) {
      return 'Today';
    } else if (date.toDateString() === yesterday.toDateString()) {
      return 'Yesterday';
    } else {
      return date.toLocaleDateString('en-MY', { 
        day: '2-digit', 
        month: 'short',
        year: date.getFullYear() !== today.getFullYear() ? 'numeric' : undefined
      });
    }
  };

  const groupTransactionsByDate = (transactions: ExpenseTransaction[]) => {
    const grouped: { [key: string]: ExpenseTransaction[] } = {};
    
    transactions.forEach(transaction => {
      const dateKey = formatDate(transaction.date);
      if (!grouped[dateKey]) {
        grouped[dateKey] = [];
      }
      grouped[dateKey].push(transaction);
    });

    return grouped;
  };

  const groupedTransactions = groupTransactionsByDate(filteredTransactions);

  return (
    <>
      <div className="pb-20 px-4">
        {/* Header */}
        <div className="flex items-center justify-between pt-6 pb-4">
          <div className="flex items-center gap-3">
            <Button variant="ghost" size="sm" onClick={onBack}>
              <ArrowLeft className="w-4 h-4" />
            </Button>
            <div>
              <h1 className="text-xl font-semibold">Transaction History</h1>
              <p className="text-sm text-muted-foreground">
                {filteredTransactions.length} transaction{filteredTransactions.length !== 1 ? 's' : ''}
              </p>
            </div>
          </div>
          
          <Button 
            variant="outline" 
            size="sm"
            onClick={() => setIsFilterOpen(true)}
            className="flex items-center gap-2"
          >
            <Filter className="w-4 h-4" />
            Filter
          </Button>
        </div>

        {/* Transaction List */}
        <div className="space-y-4">
          {Object.keys(groupedTransactions).length === 0 ? (
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.3 }}
              className="text-center py-12"
            >
              <Search className="w-12 h-12 mx-auto text-muted-foreground mb-4" />
              <h3 className="font-medium mb-2">No transactions found</h3>
              <p className="text-muted-foreground">
                Try adjusting your search or filter criteria
              </p>
            </motion.div>
          ) : (
            Object.entries(groupedTransactions).map(([date, transactions], groupIndex) => (
              <motion.div
                key={date}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.3, delay: groupIndex * 0.1 }}
                className="space-y-3"
              >
                {/* Date Header */}
                <div className="flex items-center justify-between py-2 px-1">
                  <h3 className="font-medium text-muted-foreground">{date}</h3>
                  <div className="text-sm text-muted-foreground">
                    {transactions.length} transaction{transactions.length !== 1 ? 's' : ''}
                  </div>
                </div>

                {/* Transactions for this date */}
                <div className="space-y-2">
                  {transactions.map((transaction, index) => (
                    <motion.div
                      key={transaction.id}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ duration: 0.3, delay: (groupIndex * 0.1) + (index * 0.05) }}
                    >
                      <Card className="hover:shadow-sm transition-shadow cursor-pointer">
                        <CardContent className="p-4">
                          <div className="flex items-center gap-3">
                            {/* Icon */}
                            <div className="w-10 h-10 rounded-full bg-muted flex items-center justify-center text-lg">
                              {getCategoryIcon(transaction.category)}
                            </div>

                            {/* Transaction Details */}
                            <div className="flex-1 min-w-0">
                              <div className="flex items-start justify-between">
                                <div className="flex-1">
                                  <h4 className="font-medium truncate">{transaction.name}</h4>
                                  <div className="flex items-center gap-2 mt-1">
                                    <p className="text-sm text-muted-foreground">
                                      {transaction.merchant || transaction.category}
                                    </p>
                                    <Badge 
                                      variant="secondary" 
                                      className={`text-xs px-2 py-0 ${getStatusColor(transaction.status)}`}
                                    >
                                      {transaction.status}
                                    </Badge>
                                  </div>
                                </div>

                                {/* Amount and More */}
                                <div className="flex items-center gap-2">
                                  <div className="text-right">
                                    <p className={`font-semibold ${
                                      transaction.type === 'expense' 
                                        ? 'text-foreground' 
                                        : 'text-[color:var(--sfms-success)]'
                                    }`}>
                                      {transaction.type === 'expense' ? '-' : '+'}RM {Math.abs(transaction.amount).toFixed(2)}
                                    </p>
                                    <p className="text-xs text-muted-foreground">
                                      {transaction.time}
                                    </p>
                                  </div>
                                  <Button variant="ghost" size="sm" className="p-1 h-8 w-8">
                                    <MoreVertical className="w-4 h-4" />
                                  </Button>
                                </div>
                              </div>
                            </div>
                          </div>
                        </CardContent>
                      </Card>
                    </motion.div>
                  ))}
                </div>
              </motion.div>
            ))
          )}
        </div>
      </div>

      {/* Filter Sheet */}
      <AnimatePresence>
        {isFilterOpen && (
          <FilterSheet 
            isOpen={isFilterOpen}
            onClose={() => setIsFilterOpen(false)}
            onApplyFilter={handleFilter}
          />
        )}
      </AnimatePresence>
    </>
  );
}