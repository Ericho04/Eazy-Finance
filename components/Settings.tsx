import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Switch } from './ui/switch';
import { 
  ArrowLeft,
  User, 
  Moon, 
  Sun, 
  Bell, 
  Shield, 
  Globe, 
  CreditCard, 
  HelpCircle, 
  LogOut,
  Smartphone,
  Download,
  Star,
  Heart,
  Coffee,
  Settings as SettingsIcon,
  ChevronRight,
  Check,
  Database,

} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

interface SettingsProps {
  onThemeToggle: () => void;
  isDarkMode: boolean;
  onNavigate: (destination: string) => void;
  onBack: () => void;
  user?: any;
}

export function Settings({ onThemeToggle, isDarkMode, onNavigate, onBack, user }: SettingsProps) {
  const [notifications, setNotifications] = useState(true);
  const [biometric, setBiometric] = useState(false);
  const [language, setLanguage] = useState('English');
  const [showLanguageModal, setShowLanguageModal] = useState(false);

  const languages = [
    { code: 'en', name: 'English', flag: '🇺🇸' },
    { code: 'ms', name: 'Bahasa Malaysia', flag: '🇲🇾' },
    { code: 'zh', name: '中文', flag: '🇨🇳' },
    { code: 'ta', name: 'தமிழ்', flag: '🇮🇳' },
  ];

  const handleBack = () => {
    onBack(); // Use the provided back handler
  };

  const handleLogout = async () => {
    if (user) {
      // Import signOut from auth utils
      const { signOut } = await import('../utils/auth');
      await signOut();
    }
    localStorage.removeItem('sfms_demo_authenticated');
    onNavigate('dashboard'); // Go back to dashboard as guest
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50">
      {/* Header */}
      <div className="flex items-center justify-between p-4 pb-2">
        <Button
          onClick={handleBack}
          variant="ghost"
          className="cartoon-button bg-white/80 backdrop-blur-sm"
        >
          <ArrowLeft className="w-4 h-4 mr-2" />
          Back
        </Button>
        
        <div className="flex items-center gap-2">
          <motion.div
            animate={{ rotate: [0, 180, 360] }}
            transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
          >
            <SettingsIcon className="w-5 h-5 text-purple-600" />
          </motion.div>
          <h1 className="font-bold text-gray-800">Settings</h1>
        </div>
        
        <div className="w-16" /> {/* Spacer for centering */}
      </div>

      <div className="px-4 space-y-6">
        {/* Profile Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
        >
          {user ? (
            // Authenticated User Profile
            <Card className="cartoon-card bg-gradient-to-r from-purple-500 to-pink-500 text-white border-0">
              <CardContent className="p-6">
                <div className="flex items-center gap-4">
                  <motion.div
                    whileHover={{ scale: 1.1 }}
                    whileTap={{ scale: 0.95 }}
                    className="w-16 h-16 bg-white/20 rounded-full flex items-center justify-center cartoon-avatar"
                  >
                    <User className="w-8 h-8 text-white" />
                  </motion.div>
                  
                  <div className="flex-1">
                    <h2 className="text-xl font-bold">{user.user_metadata?.name || 'User'}</h2>
                    <p className="text-white/80">{user.email}</p>
                    <Badge className="mt-2 bg-white/20 text-white border-white/30">
                      ✨ Premium Member
                    </Badge>
                  </div>
                  
                  <Button 
                    variant="ghost" 
                    size="sm"
                    className="text-white hover:bg-white/20"
                  >
                    <ChevronRight className="w-4 h-4" />
                  </Button>
                </div>
              </CardContent>
            </Card>
          ) : (
            // Guest User - Sign In Prompt
            <Card className="cartoon-card bg-gradient-to-r from-blue-500 to-cyan-500 text-white border-0">
              <CardContent className="p-6">
                <div className="flex items-center gap-4">
                  <motion.div
                    whileHover={{ scale: 1.1 }}
                    whileTap={{ scale: 0.95 }}
                    className="w-16 h-16 bg-white/20 rounded-full flex items-center justify-center cartoon-avatar"
                  >
                    <User className="w-8 h-8 text-white" />
                  </motion.div>
                  
                  <div className="flex-1">
                    <h2 className="text-xl font-bold">Guest User</h2>
                    <p className="text-white/80">Sign in to save your data</p>
                    <Badge className="mt-2 bg-white/20 text-white border-white/30">
                      🌟 Guest Mode
                    </Badge>
                  </div>
                  
                  <Button 
                    variant="ghost" 
                    size="sm"
                    className="text-white hover:bg-white/20"
                    onClick={() => onNavigate('login')}
                  >
                    <ChevronRight className="w-4 h-4" />
                  </Button>
                </div>
                
                <div className="mt-4 pt-4 border-t border-white/20">
                  <Button
                    onClick={() => onNavigate('login')}
                    className="w-full cartoon-button bg-white/20 hover:bg-white/30 border-0"
                  >
                    <User className="w-4 h-4 mr-2" />
                    Sign In or Create Account
                  </Button>
                </div>
              </CardContent>
            </Card>
          )}
        </motion.div>

        {/* Quick Stats */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.1 }}
          className="grid grid-cols-3 gap-3"
        >
          <Card className="cartoon-card bg-white border-0 text-center">
            <CardContent className="p-4">
              <div className="text-2xl mb-1">📊</div>
              <div className="text-lg font-bold text-gray-800">47</div>
              <div className="text-xs text-gray-600">Transactions</div>
            </CardContent>
          </Card>
          
          <Card className="cartoon-card bg-white border-0 text-center">
            <CardContent className="p-4">
              <div className="text-2xl mb-1">🎯</div>
              <div className="text-lg font-bold text-gray-800">3</div>
              <div className="text-xs text-gray-600">Goals Active</div>
            </CardContent>
          </Card>
          
          <Card className="cartoon-card bg-white border-0 text-center">
            <CardContent className="p-4">
              <div className="text-2xl mb-1">⭐</div>
              <div className="text-lg font-bold text-gray-800">1,250</div>
              <div className="text-xs text-gray-600">Points</div>
            </CardContent>
          </Card>
        </motion.div>

        {/* Settings Options */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
        >
          <Card className="cartoon-card bg-white border-0">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <span>⚙️</span>
                Preferences
              </CardTitle>
              <CardDescription>
                Customize your SFMS experience
              </CardDescription>
            </CardHeader>
            
            <CardContent className="space-y-4">
              {/* Dark Mode Toggle */}
              <div className="flex items-center justify-between p-3 rounded-xl bg-gray-50">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gradient-to-r from-purple-400 to-pink-500 rounded-full flex items-center justify-center">
                    {isDarkMode ? (
                      <Moon className="w-5 h-5 text-white" />
                    ) : (
                      <Sun className="w-5 h-5 text-white" />
                    )}
                  </div>
                  <div>
                    <div className="font-medium text-gray-800">Dark Mode</div>
                    <div className="text-sm text-gray-600">Toggle theme appearance</div>
                  </div>
                </div>
                <Switch
                  checked={isDarkMode}
                  onCheckedChange={onThemeToggle}
                  className="data-[state=checked]:bg-purple-500"
                />
              </div>

              {/* Notifications */}
              <div className="flex items-center justify-between p-3 rounded-xl bg-gray-50">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gradient-to-r from-blue-400 to-cyan-500 rounded-full flex items-center justify-center">
                    <Bell className="w-5 h-5 text-white" />
                  </div>
                  <div>
                    <div className="font-medium text-gray-800">Notifications</div>
                    <div className="text-sm text-gray-600">Push notifications</div>
                  </div>
                </div>
                <Switch
                  checked={notifications}
                  onCheckedChange={setNotifications}
                  className="data-[state=checked]:bg-blue-500"
                />
              </div>

              {/* Biometric */}
              <div className="flex items-center justify-between p-3 rounded-xl bg-gray-50">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gradient-to-r from-green-400 to-emerald-500 rounded-full flex items-center justify-center">
                    <Shield className="w-5 h-5 text-white" />
                  </div>
                  <div>
                    <div className="font-medium text-gray-800">Biometric Login</div>
                    <div className="text-sm text-gray-600">Fingerprint & Face ID</div>
                  </div>
                </div>
                <Switch
                  checked={biometric}
                  onCheckedChange={setBiometric}
                  className="data-[state=checked]:bg-green-500"
                />
              </div>

              {/* Language */}
              <motion.button
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                onClick={() => setShowLanguageModal(true)}
                className="w-full flex items-center justify-between p-3 rounded-xl bg-gray-50 transition-colors hover:bg-gray-100"
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gradient-to-r from-orange-400 to-red-500 rounded-full flex items-center justify-center">
                    <Globe className="w-5 h-5 text-white" />
                  </div>
                  <div className="text-left">
                    <div className="font-medium text-gray-800">Language</div>
                    <div className="text-sm text-gray-600">{language}</div>
                  </div>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400" />
              </motion.button>
            </CardContent>
          </Card>
        </motion.div>



        {/* App Info */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
        >
          <Card className="cartoon-card bg-white border-0">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <span>📱</span>
                App & Support
              </CardTitle>
            </CardHeader>
            
            <CardContent className="space-y-3">
              {[
                { icon: Database, label: 'Database Schema (ERD)', color: 'from-indigo-400 to-purple-500', action: () => onNavigate('erd-diagram') },
                { icon: HelpCircle, label: 'Help & Support', color: 'from-blue-400 to-cyan-500' },
                { icon: Star, label: 'Rate SFMS', color: 'from-yellow-400 to-orange-500' },
                { icon: Heart, label: 'Share with Friends', color: 'from-pink-400 to-red-500' },
                { icon: Coffee, label: 'Buy us a Coffee', color: 'from-amber-400 to-orange-500' },
                { icon: Download, label: 'Export Data', color: 'from-green-400 to-emerald-500' },
              ].map((item, index) => (
                <motion.button
                  key={item.label}
                  whileHover={{ scale: 1.02, x: 5 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={item.action}
                  className="w-full flex items-center gap-3 p-3 rounded-xl bg-gray-50 transition-colors hover:bg-gray-100"
                >
                  <div className={`w-10 h-10 bg-gradient-to-r ${item.color} rounded-full flex items-center justify-center`}>
                    <item.icon className="w-5 h-5 text-white" />
                  </div>
                  <span className="font-medium text-gray-800">{item.label}</span>
                  <ChevronRight className="w-4 h-4 text-gray-400 ml-auto" />
                </motion.button>
              ))}
            </CardContent>
          </Card>
        </motion.div>

        {/* Logout Button - Only show if user is authenticated */}
        {user && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.4 }}
          >
            <Button
              onClick={handleLogout}
              variant="outline"
              className="w-full cartoon-button border-red-200 text-red-600 hover:bg-red-50 h-14"
            >
              <LogOut className="w-5 h-5 mr-2" />
              Sign Out
            </Button>
          </motion.div>
        )}

        {/* App Version */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.5 }}
          className="text-center py-4"
        >
          <p className="text-sm text-gray-500">SFMS v2.1.0</p>
          <p className="text-xs text-gray-400">Made with ❤️ in Malaysia</p>
        </motion.div>
      </div>

      {/* Language Selection Modal */}
      <AnimatePresence>
        {showLanguageModal && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
          >
            <motion.div
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="bg-white rounded-3xl p-6 w-full max-w-sm"
            >
              <h3 className="text-lg font-bold text-gray-800 mb-4 flex items-center gap-2">
                <Globe className="w-5 h-5" />
                Select Language
              </h3>
              
              <div className="space-y-2">
                {languages.map((lang) => (
                  <motion.button
                    key={lang.code}
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    onClick={() => {
                      setLanguage(lang.name);
                      setShowLanguageModal(false);
                    }}
                    className={`w-full flex items-center gap-3 p-3 rounded-xl transition-colors ${
                      language === lang.name 
                        ? 'bg-purple-100 border-2 border-purple-500' 
                        : 'bg-gray-50 hover:bg-gray-100'
                    }`}
                  >
                    <span className="text-2xl">{lang.flag}</span>
                    <span className="font-medium text-gray-800">{lang.name}</span>
                    {language === lang.name && (
                      <Check className="w-5 h-5 text-purple-500 ml-auto" />
                    )}
                  </motion.button>
                ))}
              </div>
              
              <Button
                onClick={() => setShowLanguageModal(false)}
                variant="outline"
                className="w-full mt-4"
              >
                Cancel
              </Button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}