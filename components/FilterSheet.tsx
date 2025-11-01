import { useState } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Separator } from "./ui/separator";
import { Badge } from "./ui/badge";
import { X, Search, Calendar, Tag } from "lucide-react";
import { motion } from "motion/react";

interface FilterSheetProps {
  isOpen: boolean;
  onClose: () => void;
  onApplyFilter: (searchTerm: string, category: string, dateRange: string) => void;
}

export function FilterSheet({ isOpen, onClose, onApplyFilter }: FilterSheetProps) {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [selectedDateRange, setSelectedDateRange] = useState('all');

  const categories = [
    { value: 'all', label: 'All Categories', icon: '📋' },
    { value: 'Food & Dining', label: 'Food & Dining', icon: '🍽️' },
    { value: 'Transportation', label: 'Transportation', icon: '🚗' },
    { value: 'Shopping', label: 'Shopping', icon: '🛍️' },
    { value: 'Bills & Utilities', label: 'Bills & Utilities', icon: '💡' },
    { value: 'Entertainment', label: 'Entertainment', icon: '🎬' },
    { value: 'Income', label: 'Income', icon: '💰' },
    { value: 'Healthcare', label: 'Healthcare', icon: '⚕️' },
    { value: 'Education', label: 'Education', icon: '📚' },
  ];

  const dateRanges = [
    { value: 'all', label: 'All Time' },
    { value: 'today', label: 'Today' },
    { value: 'week', label: 'Past Week' },
    { value: 'month', label: 'Past Month' },
  ];

  const handleApply = () => {
    onApplyFilter(searchTerm, selectedCategory, selectedDateRange);
  };

  const handleReset = () => {
    setSearchTerm('');
    setSelectedCategory('all');
    setSelectedDateRange('all');
  };

  const getActiveFiltersCount = () => {
    let count = 0;
    if (searchTerm.trim()) count++;
    if (selectedCategory !== 'all') count++;
    if (selectedDateRange !== 'all') count++;
    return count;
  };

  return (
    <>
      {/* Backdrop */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.3 }}
        className="fixed inset-0 bg-black/50 z-40"
        onClick={onClose}
      />

      {/* Filter Sheet */}
      <motion.div
        initial={{ y: '100%' }}
        animate={{ y: 0 }}
        exit={{ y: '100%' }}
        transition={{ duration: 0.3, ease: 'easeInOut' }}
        className="fixed bottom-0 left-0 right-0 z-50 bg-background rounded-t-xl max-h-[80vh] overflow-hidden"
      >
        <div className="max-w-md mx-auto">
          {/* Handle */}
          <div className="flex justify-center py-3">
            <div className="w-10 h-1 bg-muted rounded-full"></div>
          </div>

          {/* Header */}
          <div className="flex items-center justify-between px-4 pb-4">
            <div className="flex items-center gap-2">
              <h2 className="text-lg font-semibold">Filter & Search</h2>
              {getActiveFiltersCount() > 0 && (
                <Badge variant="secondary" className="bg-[color:var(--sfms-success)]/10 text-[color:var(--sfms-success)]">
                  {getActiveFiltersCount()} active
                </Badge>
              )}
            </div>
            <Button variant="ghost" size="sm" onClick={onClose}>
              <X className="w-4 h-4" />
            </Button>
          </div>

          {/* Content */}
          <div className="px-4 pb-6 max-h-[60vh] overflow-y-auto">
            {/* Search Section */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3, delay: 0.1 }}
              className="space-y-3 mb-6"
            >
              <div className="flex items-center gap-2 mb-3">
                <Search className="w-4 h-4 text-muted-foreground" />
                <Label className="font-medium">Search Transactions</Label>
              </div>
              
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                <Input
                  placeholder="Search by name or merchant..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
              
              {searchTerm && (
                <p className="text-xs text-muted-foreground">
                  Searching for transactions containing "{searchTerm}"
                </p>
              )}
            </motion.div>

            <Separator className="mb-6" />

            {/* Category Filter */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3, delay: 0.2 }}
              className="space-y-3 mb-6"
            >
              <div className="flex items-center gap-2 mb-3">
                <Tag className="w-4 h-4 text-muted-foreground" />
                <Label className="font-medium">Category</Label>
              </div>
              
              <div className="grid grid-cols-2 gap-2">
                {categories.map((category) => (
                  <Button
                    key={category.value}
                    variant={selectedCategory === category.value ? "default" : "outline"}
                    size="sm"
                    onClick={() => setSelectedCategory(category.value)}
                    className={`justify-start h-auto py-3 px-3 ${
                      selectedCategory === category.value
                        ? 'bg-[color:var(--sfms-success)] hover:bg-[color:var(--sfms-success)]/90 text-[color:var(--sfms-success-foreground)]'
                        : ''
                    }`}
                  >
                    <span className="mr-2">{category.icon}</span>
                    <span className="text-xs truncate">{category.label}</span>
                  </Button>
                ))}
              </div>
            </motion.div>

            <Separator className="mb-6" />

            {/* Date Range Filter */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3, delay: 0.3 }}
              className="space-y-3 mb-6"
            >
              <div className="flex items-center gap-2 mb-3">
                <Calendar className="w-4 h-4 text-muted-foreground" />
                <Label className="font-medium">Date Range</Label>
              </div>
              
              <div className="grid grid-cols-2 gap-2">
                {dateRanges.map((range) => (
                  <Button
                    key={range.value}
                    variant={selectedDateRange === range.value ? "default" : "outline"}
                    size="sm"
                    onClick={() => setSelectedDateRange(range.value)}
                    className={`justify-center py-3 ${
                      selectedDateRange === range.value
                        ? 'bg-[color:var(--sfms-success)] hover:bg-[color:var(--sfms-success)]/90 text-[color:var(--sfms-success-foreground)]'
                        : ''
                    }`}
                  >
                    {range.label}
                  </Button>
                ))}
              </div>
            </motion.div>
          </div>

          {/* Actions */}
          <div className="px-4 py-4 border-t bg-background">
            <div className="flex gap-3">
              <Button
                variant="outline"
                onClick={handleReset}
                className="flex-1"
                disabled={getActiveFiltersCount() === 0}
              >
                Reset Filters
              </Button>
              <Button
                onClick={handleApply}
                className="flex-1 bg-[color:var(--sfms-success)] hover:bg-[color:var(--sfms-success)]/90 text-[color:var(--sfms-success-foreground)]"
              >
                Apply Filters
              </Button>
            </div>
          </div>
        </div>
      </motion.div>
    </>
  );
}