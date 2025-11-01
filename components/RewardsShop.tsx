import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { 
  Star, 
  ShoppingBag, 
  Gift,
  Coffee,
  Car,
  Utensils,
  ShoppingCart,
  GamepadIcon,
  Heart,
  ArrowLeft,
  Check,
  Sparkles
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

interface RewardsShopProps {
  onBack: () => void;
  user?: any;
}

interface ShopItem {
  id: string;
  name: string;
  description: string;
  category: 'vouchers' | 'cashback' | 'experiences' | 'digital';
  pointsCost: number;
  originalValue: string;
  discount: number;
  image: string;
  emoji: string;
  availability: number;
  isPopular?: boolean;
  isLimited?: boolean;
}

const shopItems: ShopItem[] = [
  {
    id: '1',
    name: 'Grab Food Voucher',
    description: 'RM 20 off on food delivery',
    category: 'vouchers',
    pointsCost: 150,
    originalValue: 'RM 20',
    discount: 25,
    image: '',
    emoji: '🍔',
    availability: 50,
    isPopular: true
  },
  {
    id: '2',
    name: 'Starbucks Voucher',
    description: 'RM 15 Starbucks gift card',
    category: 'vouchers',
    pointsCost: 120,
    originalValue: 'RM 15',
    discount: 20,
    image: '',
    emoji: '☕',
    availability: 30
  },
  {
    id: '3',
    name: 'Shopee Voucher',
    description: 'RM 30 shopping voucher',
    category: 'vouchers',
    pointsCost: 250,
    originalValue: 'RM 30',
    discount: 17,
    image: '',
    emoji: '🛍️',
    availability: 25,
    isLimited: true
  },
  {
    id: '4',
    name: 'Cashback',
    description: 'Direct cash to your account',
    category: 'cashback',
    pointsCost: 100,
    originalValue: 'RM 10',
    discount: 0,
    image: '',
    emoji: '💰',
    availability: 100
  },
  {
    id: '5',
    name: 'Touch n Go eWallet',
    description: 'RM 25 TnG reload',
    category: 'digital',
    pointsCost: 200,
    originalValue: 'RM 25',
    discount: 20,
    image: '',
    emoji: '📱',
    availability: 40,
    isPopular: true
  },
  {
    id: '6',
    name: 'Cinema Tickets',
    description: '2x GSC movie tickets',
    category: 'experiences',
    pointsCost: 300,
    originalValue: 'RM 40',
    discount: 25,
    image: '',
    emoji: '🎬',
    availability: 15,
    isLimited: true
  },
  {
    id: '7',
    name: 'Fitness Class',
    description: '1 month gym membership',
    category: 'experiences',
    pointsCost: 800,
    originalValue: 'RM 120',
    discount: 33,
    image: '',
    emoji: '💪',
    availability: 5,
    isLimited: true
  },
  {
    id: '8',
    name: 'Spotify Premium',
    description: '3 months subscription',
    category: 'digital',
    pointsCost: 400,
    originalValue: 'RM 50',
    discount: 20,
    image: '',
    emoji: '🎵',
    availability: 20
  }
];

export function RewardsShop({ onBack, user }: RewardsShopProps) {
  const [userPoints, setUserPoints] = useState(850);
  const [activeTab, setActiveTab] = useState('vouchers');
  const [purchasedItems, setPurchasedItems] = useState<string[]>([]);
  const [showPurchaseModal, setShowPurchaseModal] = useState(false);
  const [selectedItem, setSelectedItem] = useState<ShopItem | null>(null);

  const categories = [
    { id: 'vouchers', label: 'Vouchers', icon: Gift, emoji: '🎁' },
    { id: 'cashback', label: 'Cashback', icon: Star, emoji: '💰' },
    { id: 'experiences', label: 'Experiences', icon: Heart, emoji: '🎭' },
    { id: 'digital', label: 'Digital', icon: GamepadIcon, emoji: '📱' }
  ];

  const filteredItems = shopItems.filter(item => item.category === activeTab);

  const handlePurchase = (item: ShopItem) => {
    if (userPoints >= item.pointsCost) {
      setSelectedItem(item);
      setShowPurchaseModal(true);
    }
  };

  const confirmPurchase = () => {
    if (selectedItem && userPoints >= selectedItem.pointsCost) {
      setUserPoints(prev => prev - selectedItem.pointsCost);
      setPurchasedItems(prev => [...prev, selectedItem.id]);
      setShowPurchaseModal(false);
      setSelectedItem(null);
      
      // Update availability
      const itemIndex = shopItems.findIndex(item => item.id === selectedItem.id);
      if (itemIndex !== -1) {
        shopItems[itemIndex].availability -= 1;
      }
    }
  };

  const getDiscountedPrice = (pointsCost: number, discount: number) => {
    return Math.floor(pointsCost * (1 - discount / 100));
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 px-4 py-6">
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
          animate={{ scale: [1, 1.1, 1] }}
          transition={{ duration: 2, repeat: Infinity }}
          className="text-6xl mb-4"
        >
          🛒
        </motion.div>
        <h1 className="text-3xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent mb-2">
          Rewards Shop
        </h1>
        <p className="text-gray-600">Exchange your points for amazing rewards!</p>
      </motion.div>

      {/* Categories Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid w-full grid-cols-4 cartoon-card bg-white p-1">
          {categories.map((category) => (
            <TabsTrigger
              key={category.id}
              value={category.id}
              className="cartoon-button data-[state=active]:bg-gradient-to-r data-[state=active]:from-purple-500 data-[state=active]:to-pink-500 data-[state=active]:text-white"
            >
              <div className="flex flex-col items-center gap-1">
                <span className="text-lg">{category.emoji}</span>
                <span className="text-xs font-medium">{category.label}</span>
              </div>
            </TabsTrigger>
          ))}
        </TabsList>

        {/* Shop Items */}
        {categories.map((category) => (
          <TabsContent key={category.id} value={category.id} className="mt-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {filteredItems.map((item, index) => (
                <motion.div
                  key={item.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.3, delay: index * 0.1 }}
                >
                  <Card className={`cartoon-card relative overflow-hidden ${
                    purchasedItems.includes(item.id) ? 'opacity-60' : ''
                  }`}>
                    {/* Badges */}
                    <div className="absolute top-3 left-3 flex gap-2 z-10">
                      {item.isPopular && (
                        <Badge className="bg-orange-100 text-orange-800 border-orange-200 text-xs">
                          🔥 Popular
                        </Badge>
                      )}
                      {item.isLimited && (
                        <Badge className="bg-red-100 text-red-800 border-red-200 text-xs">
                          ⚡ Limited
                        </Badge>
                      )}
                    </div>

                    {/* Purchased Overlay */}
                    {purchasedItems.includes(item.id) && (
                      <div className="absolute inset-0 bg-green-500 bg-opacity-20 flex items-center justify-center z-20">
                        <div className="bg-green-500 text-white rounded-full p-3">
                          <Check className="w-6 h-6" />
                        </div>
                      </div>
                    )}

                    <CardContent className="p-5">
                      {/* Item Header */}
                      <div className="flex items-start gap-4 mb-4">
                        <div className="text-4xl">{item.emoji}</div>
                        <div className="flex-1">
                          <h3 className="font-bold text-gray-800 mb-1">{item.name}</h3>
                          <p className="text-sm text-gray-600 mb-2">{item.description}</p>
                          <p className="text-lg font-bold text-purple-600">{item.originalValue}</p>
                        </div>
                      </div>

                      {/* Points and Availability */}
                      <div className="flex items-center justify-between mb-4">
                        <div className="flex items-center gap-2">
                          <Star className="w-4 h-4 text-yellow-500" />
                          <span className="font-bold text-gray-800">
                            {item.discount > 0 ? (
                              <>
                                <span className="line-through text-gray-500 text-sm mr-2">
                                  {item.pointsCost}
                                </span>
                                <span className="text-purple-600">
                                  {getDiscountedPrice(item.pointsCost, item.discount)}
                                </span>
                              </>
                            ) : (
                              item.pointsCost
                            )}
                            {' pts'}
                          </span>
                        </div>
                        
                        <div className="text-right">
                          <p className="text-xs text-gray-500">
                            {item.availability} left
                          </p>
                          {item.discount > 0 && (
                            <Badge className="bg-green-100 text-green-800 text-xs">
                              {item.discount}% OFF
                            </Badge>
                          )}
                        </div>
                      </div>

                      {/* Action Button */}
                      <Button
                        onClick={() => handlePurchase(item)}
                        disabled={
                          purchasedItems.includes(item.id) || 
                          userPoints < (item.discount > 0 ? getDiscountedPrice(item.pointsCost, item.discount) : item.pointsCost) ||
                          item.availability === 0
                        }
                        className={`w-full cartoon-button ${
                          purchasedItems.includes(item.id)
                            ? 'bg-green-500 text-white'
                            : userPoints >= (item.discount > 0 ? getDiscountedPrice(item.pointsCost, item.discount) : item.pointsCost) && item.availability > 0
                            ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white hover:shadow-xl'
                            : 'bg-gray-300 text-gray-500'
                        }`}
                      >
                        {purchasedItems.includes(item.id) ? (
                          <>
                            <Check className="w-4 h-4 mr-2" />
                            Purchased
                          </>
                        ) : item.availability === 0 ? (
                          'Sold Out'
                        ) : userPoints < (item.discount > 0 ? getDiscountedPrice(item.pointsCost, item.discount) : item.pointsCost) ? (
                          'Not Enough Points'
                        ) : (
                          <>
                            <ShoppingBag className="w-4 h-4 mr-2" />
                            Redeem Now
                          </>
                        )}
                      </Button>
                    </CardContent>
                  </Card>
                </motion.div>
              ))}
            </div>
          </TabsContent>
        ))}
      </Tabs>

      {/* Purchase Confirmation Modal */}
      <AnimatePresence>
        {showPurchaseModal && selectedItem && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
          >
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
            >
              <Card className="cartoon-card max-w-sm w-full">
                <CardHeader className="text-center">
                  <div className="text-6xl mb-4">{selectedItem.emoji}</div>
                  <CardTitle>Confirm Purchase</CardTitle>
                  <CardDescription>
                    Are you sure you want to redeem this item?
                  </CardDescription>
                </CardHeader>
                <CardContent className="text-center">
                  <div className="mb-6">
                    <h3 className="text-lg font-bold text-gray-800 mb-2">
                      {selectedItem.name}
                    </h3>
                    <p className="text-purple-600 font-bold mb-2">
                      {selectedItem.originalValue}
                    </p>
                    
                    <div className="bg-gray-50 rounded-lg p-4 mb-4">
                      <div className="flex items-center justify-center gap-2 mb-2">
                        <Star className="w-5 h-5 text-yellow-500" />
                        <span className="font-bold text-gray-800">
                          {selectedItem.discount > 0 
                            ? getDiscountedPrice(selectedItem.pointsCost, selectedItem.discount)
                            : selectedItem.pointsCost
                          } points
                        </span>
                      </div>
                      <p className="text-sm text-gray-600">
                        Remaining balance: {userPoints - (selectedItem.discount > 0 
                          ? getDiscountedPrice(selectedItem.pointsCost, selectedItem.discount)
                          : selectedItem.pointsCost)} points
                      </p>
                    </div>
                  </div>
                  
                  <div className="flex gap-3">
                    <Button
                      onClick={() => setShowPurchaseModal(false)}
                      variant="outline"
                      className="flex-1"
                    >
                      Cancel
                    </Button>
                    <Button
                      onClick={confirmPurchase}
                      className="flex-1 bg-gradient-to-r from-purple-500 to-pink-500 text-white"
                    >
                      Confirm
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Purchase History */}
      {purchasedItems.length > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mt-8"
        >
          <Card className="cartoon-card">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Sparkles className="w-5 h-5 text-purple-500" />
                Your Purchases
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {purchasedItems.map((itemId) => {
                  const item = shopItems.find(i => i.id === itemId);
                  if (!item) return null;
                  
                  return (
                    <div
                      key={itemId}
                      className="flex items-center justify-between p-3 bg-green-50 rounded-lg border border-green-200"
                    >
                      <div className="flex items-center gap-3">
                        <span className="text-xl">{item.emoji}</span>
                        <div>
                          <p className="font-medium text-gray-800">{item.name}</p>
                          <p className="text-sm text-gray-600">{item.originalValue}</p>
                        </div>
                      </div>
                      <Badge className="bg-green-100 text-green-800">
                        Redeemed
                      </Badge>
                    </div>
                  );
                })}
              </div>
            </CardContent>
          </Card>
        </motion.div>
      )}
    </div>
  );
}