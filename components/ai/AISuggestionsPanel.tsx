import { useState } from "react";
import { Card, CardContent } from "../ui/card";
import { Button } from "../ui/button";
import { Badge } from "../ui/badge";
import { Sparkles, TrendingDown, Target, DollarSign, ArrowRight, X } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";

interface AISuggestion {
  id: string;
  type: 'spending' | 'saving' | 'goal' | 'budget';
  title: string;
  description: string;
  impact: string;
  savings?: number;
  category?: string;
  priority: 'high' | 'medium' | 'low';
}

interface AISuggestionsPanelProps {
  suggestions: AISuggestion[];
  onNavigate: (section: string) => void;
}

export function AISuggestionsPanel({ suggestions, onNavigate }: AISuggestionsPanelProps) {
  const [dismissedSuggestions, setDismissedSuggestions] = useState<string[]>([]);

  const handleDismiss = (suggestionId: string) => {
    setDismissedSuggestions([...dismissedSuggestions, suggestionId]);
  };

  const handleApply = (suggestion: AISuggestion) => {
    console.log('Applying suggestion:', suggestion);
    
    // Navigate to relevant section based on suggestion type
    switch (suggestion.type) {
      case 'spending':
        onNavigate('expense-history');
        break;
      case 'budget':
        onNavigate('budget');
        break;
      case 'goal':
      case 'saving':
        onNavigate('goals');
        break;
      default:
        onNavigate('insights');
    }
  };

  const getIcon = (type: string) => {
    switch (type) {
      case 'spending':
        return <TrendingDown className="w-4 h-4" />;
      case 'goal':
      case 'saving':
        return <Target className="w-4 h-4" />;
      case 'budget':
        return <DollarSign className="w-4 h-4" />;
      default:
        return <Sparkles className="w-4 h-4" />;
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high':
        return 'bg-[color:var(--sfms-danger-light)] text-[color:var(--sfms-danger)]';
      case 'medium':
        return 'bg-[color:var(--sfms-warning-light)] text-[color:var(--sfms-warning)]';
      case 'low':
        return 'bg-[color:var(--sfms-success-light)] text-[color:var(--sfms-success)]';
      default:
        return 'bg-muted text-muted-foreground';
    }
  };

  const getCategoryEmoji = (category?: string) => {
    const emojis: { [key: string]: string } = {
      'Food & Dining': '🍽️',
      'Transportation': '🚗',
      'Shopping': '🛍️',
      'Emergency Fund': '🛡️',
      'Entertainment': '🎬',
      'Bills & Utilities': '💡',
      'Healthcare': '⚕️',
      'Education': '📚'
    };
    return emojis[category || ''] || '💡';
  };

  const activeSuggestions = suggestions.filter(s => !dismissedSuggestions.includes(s.id));

  if (activeSuggestions.length === 0) {
    return null;
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg gradient-ai flex items-center justify-center">
            <Sparkles className="w-4 h-4 text-white" />
          </div>
          <div>
            <h3 className="font-semibold">AI Suggestions</h3>
            <p className="text-xs text-muted-foreground">Personalized recommendations</p>
          </div>
        </div>
        <Badge className="bg-[color:var(--sfms-ai-light)] text-[color:var(--sfms-ai)] border-[color:var(--sfms-ai)]/30">
          {activeSuggestions.length} active
        </Badge>
      </div>

      <div className="flex gap-4 overflow-x-auto pb-2">
        <AnimatePresence>
          {activeSuggestions.map((suggestion, index) => (
            <motion.div
              key={suggestion.id}
              initial={{ opacity: 0, x: 20, scale: 0.9 }}
              animate={{ opacity: 1, x: 0, scale: 1 }}
              exit={{ opacity: 0, x: -20, scale: 0.9 }}
              transition={{ duration: 0.3, delay: index * 0.1 }}
              className="flex-shrink-0 w-72"
            >
              <Card className="relative border-2 border-[color:var(--sfms-ai)]/20 bg-gradient-to-br from-[color:var(--sfms-ai-light)] to-white hover:shadow-lg transition-all duration-300">
                {/* AI Badge */}
                <div className="absolute -top-2 -right-2">
                  <Badge className="gradient-ai text-white text-xs px-2 py-1 shadow-lg">
                    <Sparkles className="w-3 h-3 mr-1" />
                    AI
                  </Badge>
                </div>

                {/* Dismiss Button */}
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => handleDismiss(suggestion.id)}
                  className="absolute top-2 right-2 h-6 w-6 p-0 hover:bg-white/20 opacity-60 hover:opacity-100"
                >
                  <X className="w-3 h-3" />
                </Button>

                <CardContent className="p-4 space-y-3">
                  {/* Header */}
                  <div className="flex items-start gap-3">
                    <div className="flex-shrink-0 w-10 h-10 rounded-full bg-white/80 flex items-center justify-center text-lg">
                      {getCategoryEmoji(suggestion.category)}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <h4 className="font-medium text-sm truncate">{suggestion.title}</h4>
                        <Badge className={`text-xs px-1.5 py-0.5 ${getPriorityColor(suggestion.priority)}`}>
                          {suggestion.priority}
                        </Badge>
                      </div>
                      <p className="text-xs text-muted-foreground leading-relaxed">
                        {suggestion.description}
                      </p>
                    </div>
                  </div>

                  {/* Impact */}
                  <div className="bg-white/60 rounded-lg p-3">
                    <div className="flex items-center gap-2 mb-1">
                      {getIcon(suggestion.type)}
                      <span className="text-xs font-medium text-muted-foreground">Expected Impact</span>
                    </div>
                    <p className="text-sm font-semibold text-[color:var(--sfms-success)]">
                      {suggestion.impact}
                    </p>
                    {suggestion.savings && (
                      <p className="text-xs text-muted-foreground mt-1">
                        Potential monthly savings
                      </p>
                    )}
                  </div>

                  {/* Actions */}
                  <div className="flex gap-2">
                    <Button
                      size="sm"
                      onClick={() => handleApply(suggestion)}
                      className="flex-1 h-8 bg-[color:var(--sfms-ai)] hover:bg-[color:var(--sfms-ai)]/90 text-white text-xs"
                    >
                      Apply
                      <ArrowRight className="w-3 h-3 ml-1" />
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      className="h-8 px-3 text-xs border-[color:var(--sfms-ai)]/30 text-[color:var(--sfms-ai)]"
                      onClick={() => console.log('View details for:', suggestion)}
                    >
                      Details
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          ))}
        </AnimatePresence>
      </div>

      {/* View All Button */}
      <div className="text-center">
        <Button
          variant="outline"
          size="sm"
          onClick={() => onNavigate('insights')}
          className="border-[color:var(--sfms-ai)]/30 text-[color:var(--sfms-ai)] hover:bg-[color:var(--sfms-ai-light)]"
        >
          <Sparkles className="w-4 h-4 mr-2" />
          View All AI Insights
        </Button>
      </div>
    </div>
  );
}