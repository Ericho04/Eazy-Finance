import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Textarea } from './ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Switch } from './ui/switch';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from './ui/dialog';
import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle, AlertDialogTrigger } from './ui/alert-dialog';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from './ui/table';
import { toast } from 'sonner@2.0.3';
import { 
  Settings, 
  Plus, 
  Edit, 
  Trash2, 
  Save, 
  X, 
  Gift, 
  ShoppingBag, 
  Star, 
  BarChart3,
  Users,
  TrendingUp,
  ArrowLeft,
  Download,
  Upload,
  RefreshCw,
  Eye,
  EyeOff,
  Copy,
  Percent,
  Package,
  DollarSign
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

interface AdminPanelProps {
  onBack: () => void;
  user?: any;
  defaultTab?: string;
}

interface Prize {
  id: string;
  name: string;
  description: string;
  type: 'voucher' | 'points' | 'cashback' | 'gift';
  value: string;
  probability: number;
  color: string;
  emoji: string;
  isActive: boolean;
}

interface ShopItem {
  id: string;
  name: string;
  description: string;
  category: 'vouchers' | 'cashback' | 'experiences' | 'digital';
  pointsCost: number;
  originalValue: string;
  discount: number;
  emoji: string;
  availability: number;
  isPopular: boolean;
  isLimited: boolean;
  isActive: boolean;
}

// Sample data - in real app this would come from backend
const initialPrizes: Prize[] = [
  {
    id: '1',
    name: 'Cashback',
    description: 'Get money back',
    type: 'cashback',
    value: 'RM 10',
    probability: 25,
    color: 'from-green-400 to-emerald-500',
    emoji: '💰',
    isActive: true
  },
  {
    id: '2',
    name: 'Grab Voucher',
    description: 'Food delivery voucher',
    type: 'voucher',
    value: 'RM 20',
    probability: 20,
    color: 'from-orange-400 to-red-500',
    emoji: '🍔',
    isActive: true
  },
  {
    id: '3',
    name: 'Bonus Points',
    description: 'Extra reward points',
    type: 'points',
    value: '100 pts',
    probability: 30,
    color: 'from-yellow-400 to-orange-500',
    emoji: '⭐',
    isActive: true
  }
];

const initialShopItems: ShopItem[] = [
  {
    id: '1',
    name: 'Grab Food Voucher',
    description: 'RM 20 off on food delivery',
    category: 'vouchers',
    pointsCost: 150,
    originalValue: 'RM 20',
    discount: 25,
    emoji: '🍔',
    availability: 50,
    isPopular: true,
    isLimited: false,
    isActive: true
  },
  {
    id: '2',
    name: 'Starbucks Voucher',
    description: 'RM 15 Starbucks gift card',
    category: 'vouchers',
    pointsCost: 120,
    originalValue: 'RM 15',
    discount: 20,
    emoji: '☕',
    availability: 30,
    isPopular: false,
    isLimited: false,
    isActive: true
  }
];

export function AdminPanel({ onBack, user, defaultTab = 'overview' }: AdminPanelProps) {
  const [activeTab, setActiveTab] = useState(defaultTab);
  const [prizes, setPrizes] = useState<Prize[]>(initialPrizes);
  const [shopItems, setShopItems] = useState<ShopItem[]>(initialShopItems);
  const [editingPrize, setEditingPrize] = useState<Prize | null>(null);
  const [editingShopItem, setEditingShopItem] = useState<ShopItem | null>(null);
  const [showPrizeDialog, setShowPrizeDialog] = useState(false);
  const [showShopDialog, setShowShopDialog] = useState(false);
  const [isPreviewMode, setIsPreviewMode] = useState(false);

  // Form states
  const [prizeForm, setPrizeForm] = useState<Partial<Prize>>({});
  const [shopForm, setShopForm] = useState<Partial<ShopItem>>({});

  const resetPrizeForm = () => {
    setPrizeForm({
      name: '',
      description: '',
      type: 'points',
      value: '',
      probability: 10,
      color: 'from-blue-400 to-purple-500',
      emoji: '🎁',
      isActive: true
    });
  };

  const resetShopForm = () => {
    setShopForm({
      name: '',
      description: '',
      category: 'vouchers',
      pointsCost: 100,
      originalValue: '',
      discount: 0,
      emoji: '🎁',
      availability: 50,
      isPopular: false,
      isLimited: false,
      isActive: true
    });
  };

  const handleAddPrize = () => {
    setEditingPrize(null);
    resetPrizeForm();
    setShowPrizeDialog(true);
  };

  const handleEditPrize = (prize: Prize) => {
    setEditingPrize(prize);
    setPrizeForm(prize);
    setShowPrizeDialog(true);
  };

  const handleSavePrize = () => {
    if (!prizeForm.name || !prizeForm.value || !prizeForm.probability) {
      toast.error('Please fill in all required fields');
      return;
    }

    const newPrize: Prize = {
      id: editingPrize?.id || Date.now().toString(),
      name: prizeForm.name!,
      description: prizeForm.description!,
      type: prizeForm.type!,
      value: prizeForm.value!,
      probability: prizeForm.probability!,
      color: prizeForm.color!,
      emoji: prizeForm.emoji!,
      isActive: prizeForm.isActive!
    };

    if (editingPrize) {
      setPrizes(prev => prev.map(p => p.id === editingPrize.id ? newPrize : p));
      toast.success('Prize updated successfully');
    } else {
      setPrizes(prev => [...prev, newPrize]);
      toast.success('Prize added successfully');
    }

    setShowPrizeDialog(false);
    setEditingPrize(null);
    resetPrizeForm();
  };

  const handleDeletePrize = (id: string) => {
    setPrizes(prev => prev.filter(p => p.id !== id));
    toast.success('Prize deleted successfully');
  };

  const handleAddShopItem = () => {
    setEditingShopItem(null);
    resetShopForm();
    setShowShopDialog(true);
  };

  const handleEditShopItem = (item: ShopItem) => {
    setEditingShopItem(item);
    setShopForm(item);
    setShowShopDialog(true);
  };

  const handleSaveShopItem = () => {
    if (!shopForm.name || !shopForm.originalValue || !shopForm.pointsCost) {
      toast.error('Please fill in all required fields');
      return;
    }

    const newItem: ShopItem = {
      id: editingShopItem?.id || Date.now().toString(),
      name: shopForm.name!,
      description: shopForm.description!,
      category: shopForm.category!,
      pointsCost: shopForm.pointsCost!,
      originalValue: shopForm.originalValue!,
      discount: shopForm.discount!,
      emoji: shopForm.emoji!,
      availability: shopForm.availability!,
      isPopular: shopForm.isPopular!,
      isLimited: shopForm.isLimited!,
      isActive: shopForm.isActive!
    };

    if (editingShopItem) {
      setShopItems(prev => prev.map(i => i.id === editingShopItem.id ? newItem : i));
      toast.success('Shop item updated successfully');
    } else {
      setShopItems(prev => [...prev, newItem]);
      toast.success('Shop item added successfully');
    }

    setShowShopDialog(false);
    setEditingShopItem(null);
    resetShopForm();
  };

  const handleDeleteShopItem = (id: string) => {
    setShopItems(prev => prev.filter(i => i.id !== id));
    toast.success('Shop item deleted successfully');
  };

  const exportData = () => {
    const data = {
      prizes: prizes,
      shopItems: shopItems,
      exportDate: new Date().toISOString()
    };
    
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `sfms-admin-data-${new Date().toISOString().split('T')[0]}.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    
    toast.success('Data exported successfully');
  };

  const importData = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const data = JSON.parse(e.target?.result as string);
        if (data.prizes) setPrizes(data.prizes);
        if (data.shopItems) setShopItems(data.shopItems);
        toast.success('Data imported successfully');
      } catch (error) {
        toast.error('Failed to import data. Please check the file format.');
      }
    };
    reader.readAsText(file);
  };

  // Analytics calculations
  const totalActivePrizes = prizes.filter(p => p.isActive).length;
  const totalActiveShopItems = shopItems.filter(i => i.isActive).length;
  const totalProbability = prizes.reduce((sum, p) => sum + (p.isActive ? p.probability : 0), 0);
  const averageShopPrice = shopItems.reduce((sum, i) => sum + i.pointsCost, 0) / shopItems.length;

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-blue-50 to-pink-50 px-4 py-6">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <Button
            onClick={onBack}
            variant="ghost"
            className="cartoon-button bg-white/80 backdrop-blur-sm"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back
          </Button>
          
          <div className="flex items-center gap-2">
            <motion.div
              animate={{ rotate: [0, 360] }}
              transition={{ duration: 8, repeat: Infinity, ease: "linear" }}
              className="w-8 h-8 rounded-full bg-gradient-to-r from-purple-500 to-pink-500 flex items-center justify-center"
            >
              <Settings className="w-4 h-4 text-white" />
            </motion.div>
            <h1 className="text-xl font-bold text-gray-800">Admin Panel</h1>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <Button
            onClick={() => setIsPreviewMode(!isPreviewMode)}
            variant="outline"
            className="cartoon-button"
          >
            {isPreviewMode ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
          </Button>
          
          <Button
            onClick={exportData}
            variant="outline"
            className="cartoon-button"
          >
            <Download className="w-4 h-4" />
          </Button>
          
          <label htmlFor="import-file">
            <Button variant="outline" className="cartoon-button" asChild>
              <span>
                <Upload className="w-4 h-4" />
              </span>
            </Button>
          </label>
          <input
            id="import-file"
            type="file"
            accept=".json"
            onChange={importData}
            className="hidden"
          />
        </div>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid w-full grid-cols-4 cartoon-card bg-white/80 backdrop-blur-sm">
          <TabsTrigger value="overview" className="data-[state=active]:bg-gradient-to-r data-[state=active]:from-blue-500 data-[state=active]:to-purple-500 data-[state=active]:text-white">
            📊 Overview
          </TabsTrigger>
          <TabsTrigger value="lucky-draw" className="data-[state=active]:bg-gradient-to-r data-[state=active]:from-purple-500 data-[state=active]:to-pink-500 data-[state=active]:text-white">
            🎰 Lucky Draw
          </TabsTrigger>
          <TabsTrigger value="shop" className="data-[state=active]:bg-gradient-to-r data-[state=active]:from-pink-500 data-[state=active]:to-red-500 data-[state=active]:text-white">
            🛒 Shop
          </TabsTrigger>
          <TabsTrigger value="analytics" className="data-[state=active]:bg-gradient-to-r data-[state=active]:from-green-500 data-[state=active]:to-blue-500 data-[state=active]:text-white">
            📈 Analytics
          </TabsTrigger>
        </TabsList>

        {/* Overview Tab */}
        <TabsContent value="overview" className="space-y-6 mt-6">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <Card className="cartoon-card bg-gradient-to-br from-blue-50 to-purple-50">
              <CardContent className="p-4 text-center">
                <Gift className="w-8 h-8 mx-auto mb-2 text-purple-500" />
                <p className="text-2xl font-bold text-purple-600">{totalActivePrizes}</p>
                <p className="text-sm text-gray-600">Active Prizes</p>
              </CardContent>
            </Card>
            
            <Card className="cartoon-card bg-gradient-to-br from-pink-50 to-red-50">
              <CardContent className="p-4 text-center">
                <ShoppingBag className="w-8 h-8 mx-auto mb-2 text-pink-500" />
                <p className="text-2xl font-bold text-pink-600">{totalActiveShopItems}</p>
                <p className="text-sm text-gray-600">Shop Items</p>
              </CardContent>
            </Card>
            
            <Card className="cartoon-card bg-gradient-to-br from-yellow-50 to-orange-50">
              <CardContent className="p-4 text-center">
                <Percent className="w-8 h-8 mx-auto mb-2 text-orange-500" />
                <p className="text-2xl font-bold text-orange-600">{totalProbability}%</p>
                <p className="text-sm text-gray-600">Total Probability</p>
              </CardContent>
            </Card>
            
            <Card className="cartoon-card bg-gradient-to-br from-green-50 to-emerald-50">
              <CardContent className="p-4 text-center">
                <Star className="w-8 h-8 mx-auto mb-2 text-green-500" />
                <p className="text-2xl font-bold text-green-600">{Math.round(averageShopPrice)}</p>
                <p className="text-sm text-gray-600">Avg Price (pts)</p>
              </CardContent>
            </Card>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card className="cartoon-card">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Gift className="w-5 h-5 text-purple-500" />
                  Recent Lucky Draw Prizes
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {prizes.slice(0, 3).map((prize) => (
                    <div key={prize.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                      <div className="flex items-center gap-3">
                        <span className="text-xl">{prize.emoji}</span>
                        <div>
                          <p className="font-medium text-gray-800">{prize.name}</p>
                          <p className="text-sm text-gray-600">{prize.value}</p>
                        </div>
                      </div>
                      <Badge className={prize.isActive ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-600'}>
                        {prize.isActive ? 'Active' : 'Inactive'}
                      </Badge>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            <Card className="cartoon-card">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <ShoppingBag className="w-5 h-5 text-pink-500" />
                  Popular Shop Items
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {shopItems.filter(item => item.isPopular).slice(0, 3).map((item) => (
                    <div key={item.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                      <div className="flex items-center gap-3">
                        <span className="text-xl">{item.emoji}</span>
                        <div>
                          <p className="font-medium text-gray-800">{item.name}</p>
                          <p className="text-sm text-gray-600">{item.pointsCost} pts</p>
                        </div>
                      </div>
                      <Badge className="bg-orange-100 text-orange-800">
                        Popular
                      </Badge>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        {/* Lucky Draw Management Tab */}
        <TabsContent value="lucky-draw" className="space-y-6 mt-6">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-xl font-bold text-gray-800">Lucky Draw Prizes</h2>
              <p className="text-sm text-gray-600">Manage prizes and their probabilities</p>
            </div>
            <Button onClick={handleAddPrize} className="cartoon-button bg-gradient-to-r from-purple-500 to-pink-500 text-white">
              <Plus className="w-4 h-4 mr-2" />
              Add Prize
            </Button>
          </div>

          <Card className="cartoon-card">
            <CardContent className="p-0">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Prize</TableHead>
                    <TableHead>Type</TableHead>
                    <TableHead>Value</TableHead>
                    <TableHead>Probability</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {prizes.map((prize) => (
                    <TableRow key={prize.id}>
                      <TableCell>
                        <div className="flex items-center gap-3">
                          <span className="text-xl">{prize.emoji}</span>
                          <div>
                            <p className="font-medium">{prize.name}</p>
                            <p className="text-sm text-gray-600">{prize.description}</p>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge className="bg-blue-100 text-blue-800">{prize.type}</Badge>
                      </TableCell>
                      <TableCell className="font-medium">{prize.value}</TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <span className="font-medium">{prize.probability}%</span>
                          <div className="w-16 h-2 bg-gray-200 rounded-full overflow-hidden">
                            <div 
                              className="h-full bg-purple-500 rounded-full"
                              style={{ width: `${Math.min(prize.probability, 100)}%` }}
                            />
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge className={prize.isActive ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-600'}>
                          {prize.isActive ? 'Active' : 'Inactive'}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <Button
                            onClick={() => handleEditPrize(prize)}
                            size="sm"
                            variant="outline"
                            className="cartoon-button"
                          >
                            <Edit className="w-3 h-3" />
                          </Button>
                          <AlertDialog>
                            <AlertDialogTrigger asChild>
                              <Button size="sm" variant="destructive" className="cartoon-button">
                                <Trash2 className="w-3 h-3" />
                              </Button>
                            </AlertDialogTrigger>
                            <AlertDialogContent>
                              <AlertDialogHeader>
                                <AlertDialogTitle>Delete Prize</AlertDialogTitle>
                                <AlertDialogDescription>
                                  Are you sure you want to delete "{prize.name}"? This action cannot be undone.
                                </AlertDialogDescription>
                              </AlertDialogHeader>
                              <AlertDialogFooter>
                                <AlertDialogCancel>Cancel</AlertDialogCancel>
                                <AlertDialogAction onClick={() => handleDeletePrize(prize.id)}>
                                  Delete
                                </AlertDialogAction>
                              </AlertDialogFooter>
                            </AlertDialogContent>
                          </AlertDialog>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Shop Management Tab */}
        <TabsContent value="shop" className="space-y-6 mt-6">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-xl font-bold text-gray-800">Rewards Shop Items</h2>
              <p className="text-sm text-gray-600">Manage shop items, prices, and availability</p>
            </div>
            <Button onClick={handleAddShopItem} className="cartoon-button bg-gradient-to-r from-pink-500 to-red-500 text-white">
              <Plus className="w-4 h-4 mr-2" />
              Add Item
            </Button>
          </div>

          <Card className="cartoon-card">
            <CardContent className="p-0">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Item</TableHead>
                    <TableHead>Category</TableHead>
                    <TableHead>Price</TableHead>
                    <TableHead>Stock</TableHead>
                    <TableHead>Tags</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {shopItems.map((item) => (
                    <TableRow key={item.id}>
                      <TableCell>
                        <div className="flex items-center gap-3">
                          <span className="text-xl">{item.emoji}</span>
                          <div>
                            <p className="font-medium">{item.name}</p>
                            <p className="text-sm text-gray-600">{item.description}</p>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge className="bg-purple-100 text-purple-800">{item.category}</Badge>
                      </TableCell>
                      <TableCell>
                        <div>
                          <p className="font-medium">{item.pointsCost} pts</p>
                          <p className="text-sm text-gray-600">{item.originalValue}</p>
                          {item.discount > 0 && (
                            <Badge className="bg-green-100 text-green-800 text-xs">
                              {item.discount}% OFF
                            </Badge>
                          )}
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <Package className="w-4 h-4 text-gray-400" />
                          <span className="font-medium">{item.availability}</span>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex flex-wrap gap-1">
                          {item.isPopular && (
                            <Badge className="bg-orange-100 text-orange-800 text-xs">Popular</Badge>
                          )}
                          {item.isLimited && (
                            <Badge className="bg-red-100 text-red-800 text-xs">Limited</Badge>
                          )}
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge className={item.isActive ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-600'}>
                          {item.isActive ? 'Active' : 'Inactive'}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <Button
                            onClick={() => handleEditShopItem(item)}
                            size="sm"
                            variant="outline"
                            className="cartoon-button"
                          >
                            <Edit className="w-3 h-3" />
                          </Button>
                          <AlertDialog>
                            <AlertDialogTrigger asChild>
                              <Button size="sm" variant="destructive" className="cartoon-button">
                                <Trash2 className="w-3 h-3" />
                              </Button>
                            </AlertDialogTrigger>
                            <AlertDialogContent>
                              <AlertDialogHeader>
                                <AlertDialogTitle>Delete Shop Item</AlertDialogTitle>
                                <AlertDialogDescription>
                                  Are you sure you want to delete "{item.name}"? This action cannot be undone.
                                </AlertDialogDescription>
                              </AlertDialogHeader>
                              <AlertDialogFooter>
                                <AlertDialogCancel>Cancel</AlertDialogCancel>
                                <AlertDialogAction onClick={() => handleDeleteShopItem(item.id)}>
                                  Delete
                                </AlertDialogAction>
                              </AlertDialogFooter>
                            </AlertDialogContent>
                          </AlertDialog>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Analytics Tab */}
        <TabsContent value="analytics" className="space-y-6 mt-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card className="cartoon-card">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <BarChart3 className="w-5 h-5 text-blue-500" />
                  Prize Distribution
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {prizes.map((prize) => (
                    <div key={prize.id} className="space-y-2">
                      <div className="flex justify-between items-center">
                        <span className="text-sm font-medium">{prize.name}</span>
                        <span className="text-sm text-gray-600">{prize.probability}%</span>
                      </div>
                      <div className="w-full h-2 bg-gray-200 rounded-full overflow-hidden">
                        <div 
                          className="h-full bg-gradient-to-r from-blue-500 to-purple-500 rounded-full transition-all duration-500"
                          style={{ width: `${Math.min(prize.probability, 100)}%` }}
                        />
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            <Card className="cartoon-card">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <TrendingUp className="w-5 h-5 text-green-500" />
                  Category Breakdown
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {['vouchers', 'cashback', 'experiences', 'digital'].map((category) => {
                    const categoryItems = shopItems.filter(item => item.category === category);
                    const categoryPercentage = (categoryItems.length / shopItems.length) * 100;
                    
                    return (
                      <div key={category} className="space-y-2">
                        <div className="flex justify-between items-center">
                          <span className="text-sm font-medium capitalize">{category}</span>
                          <span className="text-sm text-gray-600">{categoryItems.length} items</span>
                        </div>
                        <div className="w-full h-2 bg-gray-200 rounded-full overflow-hidden">
                          <div 
                            className="h-full bg-gradient-to-r from-green-500 to-blue-500 rounded-full transition-all duration-500"
                            style={{ width: `${categoryPercentage}%` }}
                          />
                        </div>
                      </div>
                    );
                  })}
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>
      </Tabs>

      {/* Prize Edit Dialog */}
      <Dialog open={showPrizeDialog} onOpenChange={setShowPrizeDialog}>
        <DialogContent className="cartoon-card max-w-md">
          <DialogHeader>
            <DialogTitle>{editingPrize ? 'Edit Prize' : 'Add New Prize'}</DialogTitle>
            <DialogDescription>
              Configure the prize details and probability
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="prize-name">Name *</Label>
                <Input
                  id="prize-name"
                  value={prizeForm.name || ''}
                  onChange={(e) => setPrizeForm(prev => ({ ...prev, name: e.target.value }))}
                  placeholder="Prize name"
                />
              </div>
              <div>
                <Label htmlFor="prize-emoji">Emoji</Label>
                <Input
                  id="prize-emoji"
                  value={prizeForm.emoji || ''}
                  onChange={(e) => setPrizeForm(prev => ({ ...prev, emoji: e.target.value }))}
                  placeholder="🎁"
                />
              </div>
            </div>

            <div>
              <Label htmlFor="prize-description">Description</Label>
              <Textarea
                id="prize-description"
                value={prizeForm.description || ''}
                onChange={(e) => setPrizeForm(prev => ({ ...prev, description: e.target.value }))}
                placeholder="Prize description"
                rows={2}
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="prize-type">Type</Label>
                <Select value={prizeForm.type} onValueChange={(value) => setPrizeForm(prev => ({ ...prev, type: value as any }))}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select type" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="voucher">Voucher</SelectItem>
                    <SelectItem value="points">Points</SelectItem>
                    <SelectItem value="cashback">Cashback</SelectItem>
                    <SelectItem value="gift">Gift</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label htmlFor="prize-value">Value *</Label>
                <Input
                  id="prize-value"
                  value={prizeForm.value || ''}
                  onChange={(e) => setPrizeForm(prev => ({ ...prev, value: e.target.value }))}
                  placeholder="RM 10 or 100 pts"
                />
              </div>
            </div>

            <div>
              <Label htmlFor="prize-probability">Probability (%) *</Label>
              <Input
                id="prize-probability"
                type="number"
                min="0"
                max="100"
                value={prizeForm.probability || ''}
                onChange={(e) => setPrizeForm(prev => ({ ...prev, probability: Number(e.target.value) }))}
                placeholder="10"
              />
            </div>

            <div>
              <Label htmlFor="prize-color">Color Gradient</Label>
              <Select value={prizeForm.color} onValueChange={(value) => setPrizeForm(prev => ({ ...prev, color: value }))}>
                <SelectTrigger>
                  <SelectValue placeholder="Select color" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="from-blue-400 to-purple-500">Blue to Purple</SelectItem>
                  <SelectItem value="from-green-400 to-emerald-500">Green to Emerald</SelectItem>
                  <SelectItem value="from-yellow-400 to-orange-500">Yellow to Orange</SelectItem>
                  <SelectItem value="from-pink-400 to-purple-500">Pink to Purple</SelectItem>
                  <SelectItem value="from-orange-400 to-red-500">Orange to Red</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="flex items-center space-x-2">
              <Switch
                checked={prizeForm.isActive}
                onCheckedChange={(checked) => setPrizeForm(prev => ({ ...prev, isActive: checked }))}
              />
              <Label>Active</Label>
            </div>
          </div>

          <div className="flex gap-3 pt-4">
            <Button onClick={() => setShowPrizeDialog(false)} variant="outline" className="flex-1">
              Cancel
            </Button>
            <Button onClick={handleSavePrize} className="flex-1 bg-gradient-to-r from-purple-500 to-pink-500 text-white">
              {editingPrize ? 'Update' : 'Add'} Prize
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* Shop Item Edit Dialog */}
      <Dialog open={showShopDialog} onOpenChange={setShowShopDialog}>
        <DialogContent className="cartoon-card max-w-md max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{editingShopItem ? 'Edit Shop Item' : 'Add New Shop Item'}</DialogTitle>
            <DialogDescription>
              Configure the shop item details and pricing
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="shop-name">Name *</Label>
                <Input
                  id="shop-name"
                  value={shopForm.name || ''}
                  onChange={(e) => setShopForm(prev => ({ ...prev, name: e.target.value }))}
                  placeholder="Item name"
                />
              </div>
              <div>
                <Label htmlFor="shop-emoji">Emoji</Label>
                <Input
                  id="shop-emoji"
                  value={shopForm.emoji || ''}
                  onChange={(e) => setShopForm(prev => ({ ...prev, emoji: e.target.value }))}
                  placeholder="🎁"
                />
              </div>
            </div>

            <div>
              <Label htmlFor="shop-description">Description</Label>
              <Textarea
                id="shop-description"
                value={shopForm.description || ''}
                onChange={(e) => setShopForm(prev => ({ ...prev, description: e.target.value }))}
                placeholder="Item description"
                rows={2}
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="shop-category">Category</Label>
                <Select value={shopForm.category} onValueChange={(value) => setShopForm(prev => ({ ...prev, category: value as any }))}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select category" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="vouchers">Vouchers</SelectItem>
                    <SelectItem value="cashback">Cashback</SelectItem>
                    <SelectItem value="experiences">Experiences</SelectItem>
                    <SelectItem value="digital">Digital</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label htmlFor="shop-value">Original Value *</Label>
                <Input
                  id="shop-value"
                  value={shopForm.originalValue || ''}
                  onChange={(e) => setShopForm(prev => ({ ...prev, originalValue: e.target.value }))}
                  placeholder="RM 20"
                />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="shop-cost">Points Cost *</Label>
                <Input
                  id="shop-cost"
                  type="number"
                  min="1"
                  value={shopForm.pointsCost || ''}
                  onChange={(e) => setShopForm(prev => ({ ...prev, pointsCost: Number(e.target.value) }))}
                  placeholder="100"
                />
              </div>
              <div>
                <Label htmlFor="shop-discount">Discount (%)</Label>
                <Input
                  id="shop-discount"
                  type="number"
                  min="0"
                  max="100"
                  value={shopForm.discount || ''}
                  onChange={(e) => setShopForm(prev => ({ ...prev, discount: Number(e.target.value) }))}
                  placeholder="0"
                />
              </div>
            </div>

            <div>
              <Label htmlFor="shop-availability">Stock Availability</Label>
              <Input
                id="shop-availability"
                type="number"
                min="0"
                value={shopForm.availability || ''}
                onChange={(e) => setShopForm(prev => ({ ...prev, availability: Number(e.target.value) }))}
                placeholder="50"
              />
            </div>

            <div className="space-y-3">
              <div className="flex items-center space-x-2">
                <Switch
                  checked={shopForm.isPopular}
                  onCheckedChange={(checked) => setShopForm(prev => ({ ...prev, isPopular: checked }))}
                />
                <Label>Popular Item</Label>
              </div>
              
              <div className="flex items-center space-x-2">
                <Switch
                  checked={shopForm.isLimited}
                  onCheckedChange={(checked) => setShopForm(prev => ({ ...prev, isLimited: checked }))}
                />
                <Label>Limited Edition</Label>
              </div>
              
              <div className="flex items-center space-x-2">
                <Switch
                  checked={shopForm.isActive}
                  onCheckedChange={(checked) => setShopForm(prev => ({ ...prev, isActive: checked }))}
                />
                <Label>Active</Label>
              </div>
            </div>
          </div>

          <div className="flex gap-3 pt-4">
            <Button onClick={() => setShowShopDialog(false)} variant="outline" className="flex-1">
              Cancel
            </Button>
            <Button onClick={handleSaveShopItem} className="flex-1 bg-gradient-to-r from-pink-500 to-red-500 text-white">
              {editingShopItem ? 'Update' : 'Add'} Item
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}