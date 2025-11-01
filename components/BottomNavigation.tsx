import { motion } from 'motion/react';
import { 
  Home, 
  PiggyBank, 
  Building2, 
  Target, 
  TrendingUp,
  Sparkles
} from 'lucide-react';

interface BottomNavigationProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}

export function BottomNavigation({ activeTab, onTabChange }: BottomNavigationProps) {
  const tabs = [
    {
      id: 'dashboard',
      label: 'Home',
      icon: Home,
      gradient: 'from-blue-500 to-cyan-500',
      emoji: '🏠'
    },
    {
      id: 'budget',
      label: 'Budget',
      icon: PiggyBank,
      gradient: 'from-green-500 to-emerald-500',
      emoji: '💰'
    },
    {
      id: 'financial',
      label: 'Financial',
      icon: Building2,
      gradient: 'from-purple-500 to-pink-500',
      emoji: '🏦'
    },
    {
      id: 'goals',
      label: 'Goals',
      icon: Target,
      gradient: 'from-orange-500 to-red-500',
      emoji: '🎯'
    },
    {
      id: 'insights',
      label: 'Insights',
      icon: TrendingUp,
      gradient: 'from-indigo-500 to-purple-500',
      emoji: '📊'
    }
  ];

  return (
    <motion.div
      initial={{ y: 100, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ 
        duration: 0.6,
        type: "spring",
        stiffness: 100,
        damping: 15
      }}
      className="fixed bottom-0 left-0 right-0 z-40"
    >
      <div className="max-w-md mx-auto">
        {/* Glass Background */}
        <div className="relative mx-4 mb-4">
          <div className="absolute inset-0 bg-white/80 backdrop-blur-xl rounded-3xl shadow-2xl border border-white/30" />
          
          {/* Active Tab Background Indicator */}
          <motion.div
            className="absolute top-3 bottom-3 bg-gradient-to-r rounded-2xl shadow-lg"
            initial={false}
            animate={{
              left: `${tabs.findIndex(tab => tab.id === activeTab) * 20}%`,
              width: '20%'
            }}
            transition={{
              type: "spring",
              stiffness: 300,
              damping: 30
            }}
            style={{
              background: tabs.find(tab => tab.id === activeTab)?.gradient 
                ? `linear-gradient(135deg, var(--tw-gradient-stops))` 
                : 'linear-gradient(135deg, #8B5CF6, #EC4899)'
            }}
          />
          
          {/* Navigation Items */}
          <div className="relative flex items-center justify-between px-2 py-3">
            {tabs.map((tab, index) => {
              const isActive = activeTab === tab.id;
              const Icon = tab.icon;
              
              return (
                <motion.button
                  key={tab.id}
                  onClick={() => onTabChange(tab.id)}
                  className="relative flex-1 flex flex-col items-center justify-center py-2 px-1"
                  whileTap={{ scale: 0.9 }}
                  whileHover={{ scale: 1.05 }}
                >
                  {/* Icon Container */}
                  <motion.div
                    className="relative flex items-center justify-center w-8 h-8 mb-1"
                    animate={{
                      scale: isActive ? 1.1 : 1,
                      y: isActive ? -2 : 0
                    }}
                    transition={{ duration: 0.2 }}
                  >
                    {/* Animated Emoji for Active State */}
                    <motion.div
                      className="absolute inset-0 flex items-center justify-center"
                      animate={{
                        opacity: isActive ? 1 : 0,
                        scale: isActive ? 1 : 0.8,
                        rotate: isActive ? [0, 10, -10, 0] : 0
                      }}
                      transition={{ 
                        duration: isActive ? 0.6 : 0.2,
                        repeat: isActive ? Infinity : 0,
                        repeatDelay: 2
                      }}
                    >
                      <span className="text-lg">{tab.emoji}</span>
                    </motion.div>
                    
                    {/* Icon for Inactive State */}
                    <motion.div
                      animate={{
                        opacity: isActive ? 0 : 1,
                        scale: isActive ? 0.8 : 1
                      }}
                      transition={{ duration: 0.2 }}
                    >
                      <Icon 
                        className={`w-5 h-5 ${
                          isActive 
                            ? 'text-white' 
                            : 'text-gray-600'
                        }`} 
                      />
                    </motion.div>
                    
                    {/* Active State Sparkle Effect */}
                    {isActive && (
                      <motion.div
                        className="absolute -top-1 -right-1"
                        animate={{ 
                          scale: [0, 1.2, 0],
                          opacity: [0, 1, 0],
                          rotate: [0, 180, 360]
                        }}
                        transition={{ 
                          duration: 1.5,
                          repeat: Infinity,
                          repeatDelay: 1
                        }}
                      >
                        <Sparkles className="w-3 h-3 text-yellow-400" />
                      </motion.div>
                    )}
                  </motion.div>
                  
                  {/* Label */}
                  <motion.span
                    className={`text-xs font-medium transition-colors duration-200 ${
                      isActive 
                        ? 'text-white' 
                        : 'text-gray-600'
                    }`}
                    animate={{
                      opacity: isActive ? 1 : 0.8,
                      y: isActive ? -1 : 0
                    }}
                    transition={{ duration: 0.2 }}
                  >
                    {tab.label}
                  </motion.span>
                  
                  {/* Ripple Effect on Tap */}
                  <motion.div
                    className="absolute inset-0 rounded-2xl"
                    whileTap={{
                      background: "radial-gradient(circle, rgba(255,255,255,0.3) 0%, transparent 70%)"
                    }}
                  />
                </motion.button>
              );
            })}
          </div>
          
          {/* Floating Dots Decoration */}
          {[...Array(5)].map((_, i) => (
            <motion.div
              key={i}
              className="absolute w-1 h-1 bg-white/30 rounded-full"
              style={{
                top: `${20 + i * 15}%`,
                right: `-${5 + i * 2}px`,
              }}
              animate={{
                opacity: [0.3, 0.8, 0.3],
                scale: [1, 1.5, 1]
              }}
              transition={{
                duration: 2 + i * 0.5,
                repeat: Infinity,
                delay: i * 0.3
              }}
            />
          ))}
        </div>
        
        {/* Safe Area Bottom Padding */}
        <div className="h-safe-bottom" />
      </div>
    </motion.div>
  );
}