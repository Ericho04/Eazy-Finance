import { useState, useEffect } from 'react';
import { AdminPanel } from './AdminPanel';
import { motion } from 'motion/react';
import { Button } from './ui/button';
import { LogOut, Shield, Database, BarChart3, Settings as SettingsIcon } from 'lucide-react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Badge } from './ui/badge';
import { Toaster } from './ui/sonner';

interface AdminAppProps {
  onLogout: () => void;
}

interface AdminStats {
  totalPrizes: number;
  totalShopItems: number;
  totalUsers: number;
  totalTransactions: number;
}

export function AdminApp({ onLogout }: AdminAppProps) {
  const [currentView, setCurrentView] = useState<'dashboard' | 'prizes' | 'shop' | 'analytics'>('dashboard');
  const [adminStats, setAdminStats] = useState<AdminStats>({
    totalPrizes: 7,
    totalShopItems: 8,
    totalUsers: 1247,
    totalTransactions: 3892
  });

  // Simulate real-time stats updates
  useEffect(() => {
    const interval = setInterval(() => {
      setAdminStats(prev => ({
        ...prev,
        totalUsers: prev.totalUsers + Math.floor(Math.random() * 3),
        totalTransactions: prev.totalTransactions + Math.floor(Math.random() * 5)
      }));
    }, 10000); // Update every 10 seconds

    return () => clearInterval(interval);
  }, []);

  const renderDashboard = () => (
    <div className="space-y-6">
      {/* Welcome Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center mb-8"
      >
        <div className="flex items-center justify-center gap-3 mb-4">
          <motion.div
            animate={{ rotate: [0, 360] }}
            transition={{ duration: 8, repeat: Infinity, ease: "linear" }}
            className="w-16 h-16 rounded-full bg-gradient-to-r from-amber-500 to-orange-500 flex items-center justify-center shadow-lg"
          >
            <Shield className="w-8 h-8 text-white" />
          </motion.div>
          <div>
            <h1 className="text-3xl font-bold text-gray-800">SFMS Admin Panel</h1>
            <p className="text-gray-600">Manage your rewards and gamification system</p>
          </div>
        </div>
        <Badge className="bg-amber-100 text-amber-800 border-amber-200 px-4 py-2">
          Administrator Access
        </Badge>
      </motion.div>

      {/* Stats Overview */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.1 }}
        >
          <Card className="cartoon-card bg-gradient-to-br from-purple-50 to-purple-100">
            <CardContent className="p-4 text-center">
              <div className="text-3xl mb-2">🎰</div>
              <p className="text-2xl font-bold text-purple-600">{adminStats.totalPrizes}</p>
              <p className="text-sm text-gray-600">Lucky Draw Prizes</p>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.2 }}
        >
          <Card className="cartoon-card bg-gradient-to-br from-pink-50 to-pink-100">
            <CardContent className="p-4 text-center">
              <div className="text-3xl mb-2">🛒</div>
              <p className="text-2xl font-bold text-pink-600">{adminStats.totalShopItems}</p>
              <p className="text-sm text-gray-600">Shop Items</p>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.3 }}
        >
          <Card className="cartoon-card bg-gradient-to-br from-blue-50 to-blue-100">
            <CardContent className="p-4 text-center">
              <div className="text-3xl mb-2">👥</div>
              <p className="text-2xl font-bold text-blue-600">{adminStats.totalUsers.toLocaleString()}</p>
              <p className="text-sm text-gray-600">Active Users</p>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.4 }}
        >
          <Card className="cartoon-card bg-gradient-to-br from-green-50 to-green-100">
            <CardContent className="p-4 text-center">
              <div className="text-3xl mb-2">💰</div>
              <p className="text-2xl font-bold text-green-600">{adminStats.totalTransactions.toLocaleString()}</p>
              <p className="text-sm text-gray-600">Total Transactions</p>
            </CardContent>
          </Card>
        </motion.div>
      </div>

      {/* Quick Actions */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.5 }}
        className="grid grid-cols-1 md:grid-cols-3 gap-6"
      >
        <Card className="cartoon-card">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <span>🎰</span>
              Lucky Draw Management
            </CardTitle>
            <CardDescription>
              Configure prizes, probabilities, and spin mechanics
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Button
              onClick={() => setCurrentView('prizes')}
              className="w-full cartoon-button bg-gradient-to-r from-purple-500 to-pink-500 text-white"
            >
              Manage Prizes
            </Button>
          </CardContent>
        </Card>

        <Card className="cartoon-card">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <span>🛒</span>
              Rewards Shop
            </CardTitle>
            <CardDescription>
              Add items, set prices, and manage inventory
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Button
              onClick={() => setCurrentView('shop')}
              className="w-full cartoon-button bg-gradient-to-r from-pink-500 to-red-500 text-white"
            >
              Manage Shop
            </Button>
          </CardContent>
        </Card>

        <Card className="cartoon-card">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <span>📊</span>
              Analytics & Reports
            </CardTitle>
            <CardDescription>
              View detailed statistics and user engagement
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Button
              onClick={() => setCurrentView('analytics')}
              className="w-full cartoon-button bg-gradient-to-r from-blue-500 to-cyan-500 text-white"
            >
              View Analytics
            </Button>
          </CardContent>
        </Card>
      </motion.div>

      {/* Recent Activity */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6 }}
      >
        <Card className="cartoon-card">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <BarChart3 className="w-5 h-5 text-green-500" />
              Recent Activity
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {[
                { action: 'Prize Updated', item: 'Grab Food Voucher', time: '2 minutes ago', type: 'edit' },
                { action: 'New User Registered', item: 'user@example.com', time: '5 minutes ago', type: 'user' },
                { action: 'Shop Item Purchased', item: 'Starbucks Voucher', time: '8 minutes ago', type: 'purchase' },
                { action: 'Lucky Draw Spin', item: 'Bonus Points won', time: '12 minutes ago', type: 'spin' },
              ].map((activity, index) => (
                <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                  <div className="flex items-center gap-3">
                    <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm ${
                      activity.type === 'edit' ? 'bg-blue-100 text-blue-600' :
                      activity.type === 'user' ? 'bg-green-100 text-green-600' :
                      activity.type === 'purchase' ? 'bg-purple-100 text-purple-600' :
                      'bg-orange-100 text-orange-600'
                    }`}>
                      {activity.type === 'edit' ? '✏️' :
                       activity.type === 'user' ? '👤' :
                       activity.type === 'purchase' ? '🛒' : '🎰'}
                    </div>
                    <div>
                      <p className="font-medium text-gray-800 text-sm">{activity.action}</p>
                      <p className="text-xs text-gray-600">{activity.item}</p>
                    </div>
                  </div>
                  <p className="text-xs text-gray-500">{activity.time}</p>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </motion.div>
    </div>
  );

  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-yellow-50">
      {/* Admin Header */}
      <div className="bg-white/90 backdrop-blur-sm border-b border-amber-200 sticky top-0 z-40">
        <div className="max-w-6xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            {/* Navigation */}
            <div className="flex items-center gap-4">
              <Button
                onClick={() => setCurrentView('dashboard')}
                variant={currentView === 'dashboard' ? 'default' : 'ghost'}
                className={currentView === 'dashboard' ? 'bg-amber-500 text-white' : ''}
              >
                <Database className="w-4 h-4 mr-2" />
                Dashboard
              </Button>
              
              <Button
                onClick={() => setCurrentView('prizes')}
                variant={currentView === 'prizes' ? 'default' : 'ghost'}
                className={currentView === 'prizes' ? 'bg-purple-500 text-white' : ''}
              >
                🎰 Prizes
              </Button>
              
              <Button
                onClick={() => setCurrentView('shop')}
                variant={currentView === 'shop' ? 'default' : 'ghost'}
                className={currentView === 'shop' ? 'bg-pink-500 text-white' : ''}
              >
                🛒 Shop
              </Button>
              
              <Button
                onClick={() => setCurrentView('analytics')}
                variant={currentView === 'analytics' ? 'default' : 'ghost'}
                className={currentView === 'analytics' ? 'bg-blue-500 text-white' : ''}
              >
                📊 Analytics
              </Button>
            </div>

            {/* Admin Info & Logout */}
            <div className="flex items-center gap-3">
              <div className="flex items-center gap-2 bg-amber-100 rounded-lg px-3 py-1">
                <Shield className="w-4 h-4 text-amber-600" />
                <span className="text-sm font-medium text-amber-800">Admin</span>
              </div>
              
              <Button
                onClick={onLogout}
                variant="outline"
                size="sm"
                className="cartoon-button border-red-200 text-red-600 hover:bg-red-50"
              >
                <LogOut className="w-4 h-4 mr-2" />
                Logout
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="max-w-6xl mx-auto p-6">
        <motion.div
          key={currentView}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
        >
          {currentView === 'dashboard' && renderDashboard()}
          {(currentView === 'prizes' || currentView === 'shop' || currentView === 'analytics') && (
            <AdminPanel 
              onBack={() => setCurrentView('dashboard')} 
              user={{ role: 'admin', email: 'admin@sfms.app' }}
              defaultTab={currentView === 'prizes' ? 'lucky-draw' : currentView === 'shop' ? 'shop' : 'analytics'}
            />
          )}
        </motion.div>
      </div>

      {/* Floating Elements */}
      <div className="fixed inset-0 -z-10 overflow-hidden pointer-events-none">
        {[...Array(5)].map((_, i) => (
          <motion.div
            key={i}
            className="absolute w-20 h-20 opacity-5"
            style={{
              left: `${10 + i * 20}%`,
              top: `${20 + i * 15}%`,
            }}
            animate={{
              y: [0, -30, 0],
              rotate: [0, 180, 360],
            }}
            transition={{
              duration: 10 + i * 2,
              repeat: Infinity,
              ease: "easeInOut",
              delay: i * 2
            }}
          >
            <div className="w-full h-full rounded-full bg-gradient-to-br from-amber-300 to-orange-300" />
          </motion.div>
        ))}
      </div>

      {/* Toast Notifications */}
      <Toaster position="top-center" />
    </div>
  );
}