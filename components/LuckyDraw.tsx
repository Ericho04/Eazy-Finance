import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { 
  Gift, 
  Star, 
  RotateCcw,
  Trophy,
  Sparkles,
  ArrowLeft,
  Zap
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

interface LuckyDrawProps {
  onBack: () => void;
  user?: any;
}

interface Prize {
  id: string;
  name: string;
  description: string;
  type: 'voucher' | 'points' | 'cashback' | 'gift';
  value: string;
  probability: number; // percentage
  color: string;
  emoji: string;
}

const prizes: Prize[] = [
  {
    id: '1',
    name: 'Cashback',
    description: 'Get money back',
    type: 'cashback',
    value: 'RM 10',
    probability: 25,
    color: 'from-green-400 to-emerald-500',
    emoji: '💰'
  },
  {
    id: '2',
    name: 'Grab Voucher',
    description: 'Food delivery voucher',
    type: 'voucher',
    value: 'RM 20',
    probability: 20,
    color: 'from-orange-400 to-red-500',
    emoji: '🍔'
  },
  {
    id: '3',
    name: 'Bonus Points',
    description: 'Extra reward points',
    type: 'points',
    value: '100 pts',
    probability: 30,
    color: 'from-yellow-400 to-orange-500',
    emoji: '⭐'
  },
  {
    id: '4',
    name: 'Coffee Voucher',
    description: 'Starbucks voucher',
    type: 'voucher',
    value: 'RM 15',
    probability: 15,
    color: 'from-amber-400 to-yellow-500',
    emoji: '☕'
  },
  {
    id: '5',
    name: 'Mega Points',
    description: 'Huge point bonus',
    type: 'points',
    value: '500 pts',
    probability: 5,
    color: 'from-purple-400 to-pink-500',
    emoji: '💎'
  },
  {
    id: '6',
    name: 'Shopping Voucher',
    description: 'Shopee voucher',
    type: 'voucher',
    value: 'RM 30',
    probability: 3,
    color: 'from-pink-400 to-purple-500',
    emoji: '🛍️'
  },
  {
    id: '7',
    name: 'Try Again',
    description: 'Better luck next time',
    type: 'points',
    value: '5 pts',
    probability: 2,
    color: 'from-gray-400 to-gray-500',
    emoji: '🔄'
  }
];

export function LuckyDraw({ onBack, user }: LuckyDrawProps) {
  const [userPoints, setUserPoints] = useState(850);
  const [isSpinning, setIsSpinning] = useState(false);
  const [currentRotation, setCurrentRotation] = useState(0);
  const [wonPrize, setWonPrize] = useState<Prize | null>(null);
  const [showResult, setShowResult] = useState(false);
  const [dailySpins, setDailySpins] = useState(2); // Daily free spins
  const [spinHistory, setSpinHistory] = useState<Prize[]>([]);

  const spinCost = 50; // Points required for paid spin
  const segmentAngle = 360 / prizes.length;

  const canSpin = dailySpins > 0 || userPoints >= spinCost;

  const getRandomPrize = (): Prize => {
    const random = Math.random() * 100;
    let cumulative = 0;
    
    for (const prize of prizes) {
      cumulative += prize.probability;
      if (random <= cumulative) {
        return prize;
      }
    }
    
    return prizes[prizes.length - 1]; // Fallback
  };

  const spin = () => {
    if (!canSpin || isSpinning) return;

    setIsSpinning(true);
    setShowResult(false);
    
    // Deduct cost
    if (dailySpins > 0) {
      setDailySpins(prev => prev - 1);
    } else {
      setUserPoints(prev => prev - spinCost);
    }

    // Get random prize
    const prize = getRandomPrize();
    setWonPrize(prize);
    
    // Calculate final rotation
    const prizeIndex = prizes.findIndex(p => p.id === prize.id);
    const prizeAngle = prizeIndex * segmentAngle;
    const randomOffset = Math.random() * segmentAngle;
    const finalAngle = 360 * 5 + (360 - prizeAngle - randomOffset); // 5 full rotations + prize position
    
    setCurrentRotation(prev => prev + finalAngle);
    
    // Show result after animation
    setTimeout(() => {
      setIsSpinning(false);
      setShowResult(true);
      
      // Award prize
      if (prize.type === 'points') {
        const points = parseInt(prize.value.split(' ')[0]);
        setUserPoints(prev => prev + points);
      }
      
      // Add to history
      setSpinHistory(prev => [prize, ...prev.slice(0, 4)]);
    }, 3000);
  };

  const formatTimeUntilReset = () => {
    const now = new Date();
    const tomorrow = new Date(now);
    tomorrow.setDate(now.getDate() + 1);
    tomorrow.setHours(0, 0, 0, 0);
    
    const diff = tomorrow.getTime() - now.getTime();
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
    
    return `${hours}h ${minutes}m`;
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-100 via-pink-50 to-yellow-100 px-4 py-6">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <Button
          onClick={onBack}
          variant="ghost"
          className="cartoon-button bg-white/80 backdrop-blur-sm"
        >
          <ArrowLeft className="w-4 h-4 mr-2" />
          Back
        </Button>
        
        <div className="flex items-center gap-2 bg-gradient-to-r from-yellow-400 to-orange-400 rounded-2xl px-4 py-2 shadow-lg">
          <Star className="w-5 h-5 text-white" />
          <span className="text-white font-bold">{userPoints}</span>
          <span className="text-white text-sm">points</span>
        </div>
      </div>

      {/* Title */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center mb-8"
      >
        <motion.div
          animate={{ rotate: [0, 10, -10, 0] }}
          transition={{ duration: 2, repeat: Infinity, repeatDelay: 3 }}
          className="text-6xl mb-4"
        >
          🎰
        </motion.div>
        <h1 className="text-3xl font-bold bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent mb-2">
          Lucky Draw
        </h1>
        <p className="text-gray-600">Spin the wheel and win amazing prizes!</p>
      </motion.div>

      {/* Spin Info */}
      <div className="flex justify-center gap-4 mb-8">
        <Badge className="bg-green-100 text-green-800 border-green-200 px-4 py-2">
          <Gift className="w-4 h-4 mr-2" />
          {dailySpins} free spins left
        </Badge>
        
        <Badge className="bg-blue-100 text-blue-800 border-blue-200 px-4 py-2">
          <Zap className="w-4 h-4 mr-2" />
          Next spin: {dailySpins > 0 ? 'FREE' : `${spinCost} pts`}
        </Badge>
      </div>

      {/* Spinning Wheel */}
      <div className="flex justify-center mb-8">
        <div className="relative">
          {/* Wheel Container */}
          <motion.div
            className="w-80 h-80 rounded-full border-8 border-white shadow-2xl relative overflow-hidden"
            style={{
              background: `conic-gradient(${prizes.map((prize, index) => {
                const startAngle = (index * segmentAngle);
                const endAngle = ((index + 1) * segmentAngle);
                return `var(--color-${prize.color.split('-')[1]}-400) ${startAngle}deg ${endAngle}deg`;
              }).join(', ')})`
            }}
            animate={{ rotate: currentRotation }}
            transition={{ 
              duration: isSpinning ? 3 : 0, 
              ease: isSpinning ? "easeOut" : "linear"
            }}
          >
            {/* Prize Segments */}
            {prizes.map((prize, index) => {
              const angle = (index * segmentAngle) + (segmentAngle / 2);
              const radian = (angle * Math.PI) / 180;
              const x = Math.cos(radian) * 100;
              const y = Math.sin(radian) * 100;
              
              return (
                <div
                  key={prize.id}
                  className="absolute w-full h-full flex items-center justify-center"
                  style={{
                    transform: `rotate(${angle}deg)`,
                    transformOrigin: 'center'
                  }}
                >
                  <div className="text-center text-white transform -translate-y-16">
                    <div className="text-2xl mb-1">{prize.emoji}</div>
                    <div className="text-xs font-bold whitespace-nowrap">
                      {prize.value}
                    </div>
                  </div>
                </div>
              );
            })}
            
            {/* Center Circle */}
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="w-20 h-20 bg-white rounded-full shadow-lg flex items-center justify-center">
                <motion.div
                  animate={isSpinning ? { rotate: 360 } : {}}
                  transition={{ duration: 0.5, repeat: isSpinning ? Infinity : 0 }}
                >
                  <Sparkles className="w-8 h-8 text-purple-500" />
                </motion.div>
              </div>
            </div>
          </motion.div>
          
          {/* Pointer */}
          <div className="absolute top-0 left-1/2 transform -translate-x-1/2 -translate-y-2 z-10">
            <div className="w-0 h-0 border-l-4 border-r-4 border-b-8 border-l-transparent border-r-transparent border-b-white shadow-lg"></div>
          </div>
        </div>
      </div>

      {/* Spin Button */}
      <div className="flex justify-center mb-8">
        <motion.button
          onClick={spin}
          disabled={!canSpin || isSpinning}
          whileHover={canSpin ? { scale: 1.05 } : {}}
          whileTap={canSpin ? { scale: 0.95 } : {}}
          className={`cartoon-button px-8 py-4 rounded-2xl font-bold text-lg shadow-lg transition-all duration-200 ${
            canSpin && !isSpinning
              ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white hover:shadow-xl'
              : 'bg-gray-300 text-gray-500 cursor-not-allowed'
          }`}
        >
          {isSpinning ? (
            <>
              <RotateCcw className="w-5 h-5 mr-2 animate-spin" />
              Spinning...
            </>
          ) : (
            <>
              <Gift className="w-5 h-5 mr-2" />
              {dailySpins > 0 ? 'Spin FREE!' : `Spin (${spinCost} pts)`}
            </>
          )}
        </motion.button>
      </div>

      {/* Result Modal */}
      <AnimatePresence>
        {showResult && wonPrize && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
          >
            <motion.div
              initial={{ scale: 0, rotate: -180 }}
              animate={{ scale: 1, rotate: 0 }}
              exit={{ scale: 0, rotate: 180 }}
              transition={{ type: "spring", damping: 15, stiffness: 300 }}
            >
              <Card className="cartoon-card max-w-sm w-full text-center">
                <CardHeader>
                  <div className="text-6xl mb-4">{wonPrize.emoji}</div>
                  <CardTitle className="text-2xl bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
                    Congratulations!
                  </CardTitle>
                  <CardDescription>You won:</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="mb-6">
                    <h3 className="text-xl font-bold text-gray-800 mb-2">{wonPrize.name}</h3>
                    <p className="text-lg text-purple-600 font-bold">{wonPrize.value}</p>
                    <p className="text-sm text-gray-600 mt-1">{wonPrize.description}</p>
                  </div>
                  
                  <Button
                    onClick={() => setShowResult(false)}
                    className="w-full cartoon-button bg-gradient-to-r from-purple-500 to-pink-500 text-white"
                  >
                    Awesome! 🎉
                  </Button>
                </CardContent>
              </Card>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Spin History */}
      {spinHistory.length > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-8"
        >
          <Card className="cartoon-card">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Trophy className="w-5 h-5 text-yellow-500" />
                Recent Wins
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                {spinHistory.map((prize, index) => (
                  <div
                    key={index}
                    className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                  >
                    <div className="flex items-center gap-3">
                      <span className="text-xl">{prize.emoji}</span>
                      <div>
                        <p className="font-medium text-gray-800">{prize.name}</p>
                        <p className="text-sm text-gray-600">{prize.value}</p>
                      </div>
                    </div>
                    <Badge className="bg-green-100 text-green-800 text-xs">
                      Won
                    </Badge>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>
      )}

      {/* Reset Timer */}
      <div className="text-center">
        <p className="text-sm text-gray-600">
          Free spins reset in: <span className="font-bold text-purple-600">{formatTimeUntilReset()}</span>
        </p>
      </div>
    </div>
  );
}