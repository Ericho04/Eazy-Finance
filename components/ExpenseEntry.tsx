import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { 
  ArrowLeft,
  Calculator,
  Calendar,
  Tag,
  FileText,
  Save,
  TrendingDown,
  TrendingUp,
  Camera,
  QrCode,
  Scan,
  Receipt,
  Sparkles,
  X
} from 'lucide-react';
import { Badge } from './ui/badge';
import { motion, AnimatePresence } from 'motion/react';
import { useApp } from '../utils/AppContext';

interface ExpenseEntryProps {
  onBack: () => void;
  onNavigate?: (destination: string) => void;
  preSelectedCategory?: string;
  transactionType?: 'expense' | 'income';
  prefilledData?: {
    amount?: string;
    description?: string;
    category?: string;
    date?: string;
    merchant?: string;
    reference?: string;
  };
}

export function ExpenseEntry({ 
  onBack, 
  onNavigate,
  preSelectedCategory, 
  transactionType = 'expense',
  prefilledData 
}: ExpenseEntryProps) {
  const { addTransaction } = useApp();
  
  const [formData, setFormData] = useState({
    type: transactionType,
    amount: prefilledData?.amount || '',
    category: preSelectedCategory || prefilledData?.category || '',
    description: prefilledData?.description || '',
    date: prefilledData?.date || new Date().toISOString().split('T')[0],
    merchant: prefilledData?.merchant || '',
    reference: prefilledData?.reference || '',
  });
  
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [showScanOptions, setShowScanOptions] = useState(false);

  // Update form when prefilled data changes
  useEffect(() => {
    if (prefilledData) {
      setFormData(prev => ({
        ...prev,
        amount: prefilledData.amount || prev.amount,
        category: prefilledData.category || prev.category,
        description: prefilledData.description || prev.description,
        date: prefilledData.date || prev.date,
        merchant: prefilledData.merchant || prev.merchant,
        reference: prefilledData.reference || prev.reference,
      }));
    }
  }, [prefilledData]);

  const expenseCategories = [
    'Food & Dining', 'Transportation', 'Shopping', 'Entertainment',
    'Bills & Utilities', 'Healthcare', 'Coffee & Tea', 'Fuel',
    'Education', 'Travel', 'Fitness', 'Groceries', 'Others'
  ];

  const incomeCategories = [
    'Salary', 'Freelance', 'Business', 'Investment',
    'Rental', 'Gift', 'Bonus', 'Others'
  ];

  const categories = formData.type === 'expense' ? expenseCategories : incomeCategories;

  const getCategoryEmoji = (category: string) => {
    const emojis: { [key: string]: string } = {
      'Food & Dining': '🍽️',
      'Transportation': '🚗',
      'Shopping': '🛍️',
      'Entertainment': '🎮',
      'Bills & Utilities': '🏠',
      'Healthcare': '❤️',
      'Coffee & Tea': '☕',
      'Fuel': '⛽',
      'Education': '📚',
      'Travel': '✈️',
      'Fitness': '💪',
      'Groceries': '🛒',
      'Salary': '💼',
      'Freelance': '💻',
      'Business': '🏢',
      'Investment': '📈',
      'Rental': '🏠',
      'Gift': '🎁',
      'Bonus': '💰',
      'Others': '📝'
    };
    return emojis[category] || '📝';
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.amount || !formData.category || !formData.description) {
      return;
    }

    setIsSubmitting(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 1000)); // Simulate API call
      
      addTransaction({
        type: formData.type as 'expense' | 'income',
        amount: parseFloat(formData.amount),
        category: formData.category,
        description: formData.description,
        date: formData.date,
      });

      setShowSuccess(true);
      
      // Reset form
      setFormData({
        type: transactionType,
        amount: '',
        category: preSelectedCategory || '',
        description: '',
        date: new Date().toISOString().split('T')[0],
        merchant: '',
        reference: '',
      });
      
      // Auto hide success message and go back
      setTimeout(() => {
        setShowSuccess(false);
        onBack();
      }, 2000);
      
    } catch (error) {
      console.error('Error adding transaction:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleQuickAmount = (amount: number) => {
    setFormData(prev => ({
      ...prev,
      amount: amount.toString()
    }));
  };

  const handleScanOption = (type: 'ocr' | 'qr') => {
    setShowScanOptions(false);
    if (onNavigate) {
      onNavigate(type === 'ocr' ? 'ocr-scan' : 'qr-scan');
    }
  };

  const clearPrefilledData = () => {
    setFormData({
      type: transactionType,
      amount: '',
      category: preSelectedCategory || '',
      description: '',
      date: new Date().toISOString().split('T')[0],
      merchant: '',
      reference: '',
    });
  };

  if (showSuccess) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-teal-50 to-blue-50 flex items-center justify-center px-4">
        <motion.div
          initial={{ scale: 0.8, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.5 }}
          className="text-center"
        >
          <motion.div
            animate={{ scale: [1, 1.2, 1] }}
            transition={{ duration: 1, repeat: Infinity }}
            className="text-8xl mb-6"
          >
            ✅
          </motion.div>
          <h2 className="text-2xl font-bold text-gray-800 mb-2">
            {formData.type === 'expense' ? 'Expense Added!' : 'Income Added!'}
          </h2>
          <p className="text-gray-600">
            {formData.type === 'expense' 
              ? `RM ${formData.amount} expense recorded successfully`
              : `RM ${formData.amount} income recorded successfully`
            }
          </p>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50">
      {/* Header */}
      <div className="flex items-center justify-between p-4 pb-2">
        <Button
          onClick={onBack}
          variant="ghost"
          className="cartoon-button bg-white/80 backdrop-blur-sm"
        >
          <ArrowLeft className="w-4 h-4 mr-2" />
          Back
        </Button>
        
        <div className="flex items-center gap-2">
          {formData.type === 'expense' ? (
            <TrendingDown className="w-5 h-5 text-red-500" />
          ) : (
            <TrendingUp className="w-5 h-5 text-green-500" />
          )}
          <h1 className="font-bold text-gray-800">
            Add {formData.type === 'expense' ? 'Expense' : 'Income'}
          </h1>
        </div>
        
        <div className="w-16" /> {/* Spacer for centering */}
      </div>

      <div className="px-4 space-y-6">
        {/* Pre-filled Data Indicator */}
        {prefilledData && (formData.amount || formData.description || formData.merchant) && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-gradient-to-r from-green-50 to-teal-50 border border-green-200 rounded-2xl p-4"
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Sparkles className="w-4 h-4 text-green-600" />
                <span className="text-sm font-medium text-green-800">
                  Auto-filled from scan
                </span>
                <Badge className="bg-green-100 text-green-800 text-xs">
                  AI Detected
                </Badge>
              </div>
              
              <Button
                onClick={clearPrefilledData}
                variant="ghost"
                size="sm"
                className="h-8 w-8 p-0 text-green-600 hover:text-green-700"
              >
                <X className="w-4 h-4" />
              </Button>
            </div>
            
            {formData.merchant && (
              <p className="text-xs text-green-700 mt-2">
                Merchant: <span className="font-medium">{formData.merchant}</span>
              </p>
            )}
          </motion.div>
        )}

        {/* Main Form */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
        >
          <Card className="cartoon-card bg-white border-0">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <motion.div
                  animate={{ scale: [1, 1.1, 1] }}
                  transition={{ duration: 2, repeat: Infinity }}
                >
                  {formData.type === 'expense' ? '💸' : '💰'}
                </motion.div>
                {formData.type === 'expense' ? 'New Expense' : 'New Income'}
              </CardTitle>
              <CardDescription>
                Fill in the details or use scanning for quick entry
              </CardDescription>
            </CardHeader>
            
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-6">
                {/* Transaction Type Toggle */}
                <div>
                  <Label className="text-sm font-medium mb-3 block">Transaction Type</Label>
                  <div className="flex rounded-2xl bg-gray-100 p-1">
                    <Button
                      type="button"
                      onClick={() => setFormData(prev => ({ ...prev, type: 'expense' }))}
                      className={`flex-1 rounded-xl transition-all ${
                        formData.type === 'expense'
                          ? 'bg-gradient-to-r from-red-400 to-pink-500 text-white shadow-lg'
                          : 'bg-transparent text-gray-600 hover:bg-white'
                      }`}
                    >
                      <TrendingDown className="w-4 h-4 mr-2" />
                      Expense
                    </Button>
                    <Button
                      type="button"
                      onClick={() => setFormData(prev => ({ ...prev, type: 'income' }))}
                      className={`flex-1 rounded-xl transition-all ${
                        formData.type === 'income'
                          ? 'bg-gradient-to-r from-green-400 to-teal-500 text-white shadow-lg'
                          : 'bg-transparent text-gray-600 hover:bg-white'
                      }`}
                    >
                      <TrendingUp className="w-4 h-4 mr-2" />
                      Income
                    </Button>
                  </div>
                </div>

                {/* Amount */}
                <div>
                  <Label htmlFor="amount" className="flex items-center gap-2 text-sm font-medium mb-3">
                    <Calculator className="w-4 h-4" />
                    Amount (RM)
                  </Label>
                  <Input
                    id="amount"
                    type="number"
                    step="0.01"
                    placeholder="0.00"
                    value={formData.amount}
                    onChange={(e) => setFormData(prev => ({ ...prev, amount: e.target.value }))}
                    className="cartoon-card text-xl font-bold text-center border-2 border-dashed border-gray-300 focus:border-purple-400 h-16"
                    required
                  />
                  
                  {/* Quick amount buttons */}
                  <div className="grid grid-cols-4 gap-2 mt-3">
                    {[5, 10, 20, 50, 100, 200, 500, 1000].map((amount) => (
                      <Button
                        key={amount}
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={() => handleQuickAmount(amount)}
                        className="cartoon-button text-xs"
                      >
                        RM{amount}
                      </Button>
                    ))}
                  </div>
                </div>

                {/* Category */}
                <div>
                  <Label htmlFor="category" className="flex items-center gap-2 text-sm font-medium mb-3">
                    <Tag className="w-4 h-4" />
                    Category
                  </Label>
                  
                  {/* Category Grid */}
                  <div className="grid grid-cols-3 gap-2">
                    {categories.map((category) => (
                      <Button
                        key={category}
                        type="button"
                        onClick={() => setFormData(prev => ({ ...prev, category }))}
                        className={`cartoon-button p-3 h-auto flex flex-col items-center gap-2 transition-all ${
                          formData.category === category
                            ? formData.type === 'expense'
                              ? 'bg-gradient-to-r from-red-400 to-pink-500 text-white'
                              : 'bg-gradient-to-r from-green-400 to-teal-500 text-white'
                            : 'bg-white border-2 border-gray-200 text-gray-700 hover:border-purple-300'
                        }`}
                      >
                        <span className="text-lg">{getCategoryEmoji(category)}</span>
                        <span className="text-xs font-medium text-center leading-tight">
                          {category}
                        </span>
                      </Button>
                    ))}
                  </div>
                </div>

                {/* Description */}
                <div>
                  <Label htmlFor="description" className="flex items-center gap-2 text-sm font-medium mb-3">
                    <FileText className="w-4 h-4" />
                    Description
                  </Label>
                  <Input
                    id="description"
                    placeholder={`Enter ${formData.type} description...`}
                    value={formData.description}
                    onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
                    className="cartoon-card border-2 border-dashed border-gray-300 focus:border-purple-400"
                    required
                  />
                </div>

                {/* Date */}
                <div>
                  <Label htmlFor="date" className="flex items-center gap-2 text-sm font-medium mb-3">
                    <Calendar className="w-4 h-4" />
                    Date
                  </Label>
                  <Input
                    id="date"
                    type="date"
                    value={formData.date}
                    onChange={(e) => setFormData(prev => ({ ...prev, date: e.target.value }))}
                    className="cartoon-card border-2 border-dashed border-gray-300 focus:border-purple-400"
                    required
                  />
                </div>

                {/* Submit Button */}
                <div className="pt-6">
                  <Button
                    type="submit"
                    disabled={isSubmitting || !formData.amount || !formData.category || !formData.description}
                    className={`cartoon-button w-full h-14 text-lg font-bold ${
                      formData.type === 'expense'
                        ? 'bg-gradient-to-r from-red-400 to-pink-500'
                        : 'bg-gradient-to-r from-green-400 to-teal-500'
                    } text-white disabled:bg-gray-300 disabled:text-gray-500`}
                  >
                    {isSubmitting ? (
                      <div className="flex items-center gap-2">
                        <motion.div
                          animate={{ rotate: 360 }}
                          transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                        >
                          <Receipt className="w-5 h-5" />
                        </motion.div>
                        Saving...
                      </div>
                    ) : (
                      <div className="flex items-center gap-2">
                        <Save className="w-5 h-5" />
                        Save {formData.type === 'expense' ? 'Expense' : 'Income'}
                      </div>
                    )}
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>
        </motion.div>

        {/* Quick Scanning Actions */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
          className="grid grid-cols-2 gap-3"
        >
          <Button
            onClick={() => setShowScanOptions(true)}
            className="cartoon-card h-14 flex items-center gap-2 bg-gradient-to-r from-purple-400 to-pink-500 text-white"
          >
            <Scan className="w-4 h-4" />
            Quick Scan
          </Button>
          
          <Button
            variant="outline"
            onClick={() => {
              setFormData(prev => ({
                ...prev,
                amount: '',
                category: preSelectedCategory || '',
                description: '',
                date: new Date().toISOString().split('T')[0],
                merchant: '',
                reference: '',
              }));
            }}
            className="cartoon-card h-14 flex items-center gap-2"
          >
            <X className="w-4 h-4" />
            Clear Form
          </Button>
        </motion.div>
      </div>

      {/* Scanning Options Modal */}
      <AnimatePresence>
        {showScanOptions && (
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.9 }}
            className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
          >
            <Card className="cartoon-card w-full max-w-sm bg-white">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <motion.div
                    animate={{ scale: [1, 1.1, 1] }}
                    transition={{ duration: 1, repeat: Infinity }}
                  >
                    📱
                  </motion.div>
                  Choose Scanning Method
                </CardTitle>
                <CardDescription>
                  Use your camera to quickly add expenses
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                {/* OCR Receipt Scanner */}
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => handleScanOption('ocr')}
                  className="w-full p-4 rounded-2xl bg-gradient-to-r from-orange-400 to-red-500 text-white flex items-center gap-4 cartoon-button"
                >
                  <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
                    <Camera className="w-6 h-6" />
                  </div>
                  <div className="text-left">
                    <h3 className="font-bold">Scan Receipt</h3>
                    <p className="text-sm opacity-90">Photo → Auto extract data</p>
                  </div>
                </motion.button>

                {/* QR Code Scanner */}
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => handleScanOption('qr')}
                  className="w-full p-4 rounded-2xl bg-gradient-to-r from-blue-400 to-cyan-500 text-white flex items-center gap-4 cartoon-button"
                >
                  <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
                    <QrCode className="w-6 h-6" />
                  </div>
                  <div className="text-left">
                    <h3 className="font-bold">Scan QR Code</h3>
                    <p className="text-sm opacity-90">Digital receipts & payments</p>
                  </div>
                </motion.button>

                {/* Cancel */}
                <Button
                  onClick={() => setShowScanOptions(false)}
                  variant="outline"
                  className="w-full mt-4"
                >
                  Cancel
                </Button>
              </CardContent>
            </Card>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}