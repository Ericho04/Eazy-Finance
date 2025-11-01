import { useState } from 'react';
import { motion } from 'motion/react';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../ui/tabs';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '../ui/card';
import { Eye, EyeOff, Mail, Lock, Sparkles, TrendingUp, Loader2, Shield, User, ArrowLeft } from 'lucide-react';
import { signIn, demoLogin } from '../../utils/auth';
import { toast } from 'sonner@2.0.3';

interface LoginPageProps {
  onNavigate: (destination: string) => void;
  onAdminLogin?: () => void;
  onWebAdminAccess?: () => void;
}

export function LoginPage({ onNavigate, onAdminLogin, onWebAdminAccess }: LoginPageProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [demoLoading, setDemoLoading] = useState(false);
  const [activeTab, setActiveTab] = useState('user');
  const [error, setError] = useState('');

  // Clear error when switching tabs
  const handleTabChange = (value: string) => {
    setActiveTab(value);
    setError('');
    setEmail('');
    setPassword('');
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim() || !password.trim()) return;

    setLoading(true);
    setError('');
    try {
      if (activeTab === 'admin') {
        // Simple admin credential check for demo
        if (email.trim().toLowerCase() === 'admin@sfms.app' && password.trim() === 'admin123') {
          toast.success('Accessing Mobile Admin Panel...');
          onAdminLogin?.();
        } else if (email.trim().toLowerCase() === 'webadmin@sfms.app' && password.trim() === 'webadmin123') {
          toast.success('Accessing Web Admin Panel...');
          onWebAdminAccess?.();
        } else {
          const errorMsg = 'Invalid admin credentials. Please use the correct admin email and password.';
          setError(errorMsg);
          toast.error(errorMsg);
        }
      } else {
        const { user, error } = await signIn(email.trim(), password);
        if (user) {
          toast.success('Welcome back!');
          // Navigate back to settings after successful login
          onNavigate('settings');
        } else if (error) {
          setError(error.message || 'Login failed');
          toast.error(error.message || 'Login failed');
        }
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Login failed';
      setError(errorMsg);
      toast.error(errorMsg);
      console.error('Login error:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleDemoLogin = async () => {
    setDemoLoading(true);
    try {
      const { user, error } = await demoLogin();
      if (user) {
        // Navigate back to settings after successful demo login
        onNavigate('settings');
      }
    } catch (error) {
      console.error('Demo login error:', error);
    } finally {
      setDemoLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-cartoon-blue/20 via-cartoon-purple/20 to-cartoon-pink/20 flex items-center justify-center p-4">
      {/* Back Button */}
      <div className="fixed top-4 left-4 z-20">
        <Button
          onClick={() => onNavigate('settings')}
          variant="ghost"
          className="cartoon-button bg-white/80 backdrop-blur-sm"
        >
          <ArrowLeft className="w-4 h-4 mr-2" />
          Back
        </Button>
      </div>
      {/* Floating Background Elements */}
      <div className="absolute inset-0 overflow-hidden">
        {[...Array(6)].map((_, i) => (
          <motion.div
            key={i}
            className="absolute w-20 h-20 rounded-full opacity-10"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              background: `linear-gradient(45deg, var(--cartoon-${['pink', 'purple', 'blue', 'cyan', 'mint', 'yellow'][i]}))`
            }}
            animate={{
              x: [0, 50, 0],
              y: [0, -50, 0],
              scale: [1, 1.2, 1],
            }}
            transition={{
              duration: 8 + i * 2,
              repeat: Infinity,
              ease: "easeInOut",
              delay: i * 1.5
            }}
          />
        ))}
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="w-full max-w-md z-10"
      >
        {/* App Logo and Title */}
        <div className="text-center mb-8">
          <motion.div
            initial={{ scale: 0.5, rotate: -180 }}
            animate={{ scale: 1, rotate: 0 }}
            transition={{ 
              duration: 0.8,
              type: "spring",
              stiffness: 200,
              damping: 10
            }}
            className="w-20 h-20 mx-auto mb-6 rounded-3xl bg-gradient-to-br from-cartoon-blue to-cartoon-purple flex items-center justify-center shadow-2xl"
          >
            <TrendingUp className="w-10 h-10 text-white" />
          </motion.div>
          
          <motion.h1
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3, duration: 0.6 }}
            className="text-3xl font-bold bg-gradient-to-r from-cartoon-blue to-cartoon-purple bg-clip-text text-transparent"
          >
            SFMS
          </motion.h1>
          
          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.5, duration: 0.6 }}
            className="text-muted-foreground mt-2"
          >
            Smart Finance Management System
          </motion.p>
        </div>

        {/* Login Card */}
        <Card className="cartoon-card border-0 bg-white/95 backdrop-blur-sm shadow-2xl">
          <CardHeader className="text-center pb-6">
            <CardTitle className="text-2xl">Welcome Back! 👋</CardTitle>
            <CardDescription>
              Sign in to continue your financial journey
            </CardDescription>
          </CardHeader>

          <CardContent className="space-y-6">
            {/* Login Type Tabs */}
            <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
              <TabsList className="grid w-full grid-cols-2 cartoon-card bg-muted p-1">
                <TabsTrigger 
                  value="user" 
                  className="cartoon-button data-[state=active]:bg-white data-[state=active]:shadow-sm"
                >
                  <User className="w-4 h-4 mr-2" />
                  User Login
                </TabsTrigger>
                <TabsTrigger 
                  value="admin" 
                  className="cartoon-button data-[state=active]:bg-white data-[state=active]:shadow-sm"
                >
                  <Shield className="w-4 h-4 mr-2" />
                  Admin Login
                </TabsTrigger>
              </TabsList>

              <TabsContent value="user" className="space-y-4 mt-6">
                <form onSubmit={handleLogin} className="space-y-4">
                  {/* Email Input */}
                  <div className="space-y-2">
                    <Label htmlFor="email" className="text-sm font-medium">
                      Email Address
                    </Label>
                    <div className="relative">
                      <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                      <Input
                        id="email"
                        type="email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        placeholder="Enter your email"
                        className="pl-10 cartoon-button border-2 focus:border-primary/50"
                        required
                      />
                    </div>
                  </div>

                  {/* Password Input */}
                  <div className="space-y-2">
                    <Label htmlFor="password" className="text-sm font-medium">
                      Password
                    </Label>
                    <div className="relative">
                      <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                      <Input
                        id="password"
                        type={showPassword ? "text" : "password"}
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        placeholder="Enter your password"
                        className="pl-10 pr-10 cartoon-button border-2 focus:border-primary/50"
                        required
                      />
                      <Button
                        type="button"
                        variant="ghost"
                        size="sm"
                        className="absolute right-2 top-1/2 transform -translate-y-1/2 h-6 w-6 p-0"
                        onClick={() => setShowPassword(!showPassword)}
                      >
                        {showPassword ? (
                          <EyeOff className="w-4 h-4" />
                        ) : (
                          <Eye className="w-4 h-4" />
                        )}
                      </Button>
                    </div>
                  </div>

                  {/* User Login Button */}
                  <Button
                    type="submit"
                    className="w-full cartoon-button bg-gradient-to-r from-cartoon-blue to-cartoon-purple hover:from-cartoon-blue/90 hover:to-cartoon-purple/90 text-white"
                    disabled={loading || !email.trim() || !password.trim()}
                  >
                    {loading ? (
                      <>
                        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                        Signing In...
                      </>
                    ) : (
                      <>
                        <User className="mr-2 w-4 h-4" />
                        Sign In to SFMS
                      </>
                    )}
                  </Button>
                </form>

                {/* Divider - Only show for user login */}
                <div className="relative">
                  <div className="absolute inset-0 flex items-center">
                    <span className="w-full border-t border-muted" />
                  </div>
                  <div className="relative flex justify-center text-xs uppercase">
                    <span className="bg-white px-2 text-muted-foreground">Or continue with</span>
                  </div>
                </div>

                {/* Demo Login Button */}
                <Button
                  type="button"
                  variant="outline"
                  className="w-full cartoon-button border-2 border-cartoon-mint/50 text-cartoon-mint hover:bg-cartoon-mint/10"
                  onClick={handleDemoLogin}
                  disabled={demoLoading}
                >
                  {demoLoading ? (
                    <>
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                      Setting up demo...
                    </>
                  ) : (
                    <>
                      <Sparkles className="mr-2 w-4 h-4" />
                      Try Demo Account
                    </>
                  )}
                </Button>
              </TabsContent>

              <TabsContent value="admin" className="space-y-4 mt-6">
                <div className="p-4 bg-amber-50 border border-amber-200 rounded-xl mb-4">
                  <div className="flex items-center gap-2 text-amber-800 mb-2">
                    <Shield className="w-4 h-4" />
                    <p className="text-sm font-medium">Admin Access</p>
                  </div>
                  <p className="text-xs text-amber-700 mb-3">
                    Use admin credentials to access the management panel for Lucky Draw and Rewards Shop.
                  </p>
                  <div className="space-y-2">
                    <div className="text-xs text-amber-600 bg-amber-100 rounded px-2 py-1">
                      <strong>Mobile Admin:</strong> admin@sfms.app / admin123
                    </div>
                    <div className="text-xs text-blue-600 bg-blue-100 rounded px-2 py-1">
                      <strong>Web Admin Panel:</strong> webadmin@sfms.app / webadmin123
                    </div>
                  </div>
                </div>

                <form onSubmit={handleLogin} className="space-y-4">
                  {/* Admin Email Input */}
                  <div className="space-y-2">
                    <Label htmlFor="admin-email" className="text-sm font-medium">
                      Admin Email
                    </Label>
                    <div className="relative">
                      <Shield className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                      <Input
                        id="admin-email"
                        type="email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        placeholder="Enter admin email"
                        className="pl-10 cartoon-button border-2 focus:border-amber-500/50"
                        required
                      />
                    </div>
                  </div>

                  {/* Admin Password Input */}
                  <div className="space-y-2">
                    <Label htmlFor="admin-password" className="text-sm font-medium">
                      Admin Password
                    </Label>
                    <div className="relative">
                      <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                      <Input
                        id="admin-password"
                        type={showPassword ? "text" : "password"}
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        placeholder="Enter admin password"
                        className="pl-10 pr-10 cartoon-button border-2 focus:border-amber-500/50"
                        required
                      />
                      <Button
                        type="button"
                        variant="ghost"
                        size="sm"
                        className="absolute right-2 top-1/2 transform -translate-y-1/2 h-6 w-6 p-0"
                        onClick={() => setShowPassword(!showPassword)}
                      >
                        {showPassword ? (
                          <EyeOff className="w-4 h-4" />
                        ) : (
                          <Eye className="w-4 h-4" />
                        )}
                      </Button>
                    </div>
                  </div>

                  {/* Admin Login Button */}
                  <Button
                    type="submit"
                    className="w-full cartoon-button bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 text-white"
                    disabled={loading || !email.trim() || !password.trim()}
                  >
                    {loading ? (
                      <>
                        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                        Signing In...
                      </>
                    ) : (
                      <>
                        <Shield className="mr-2 w-4 h-4" />
                        Access Admin Panel
                      </>
                    )}
                  </Button>
                </form>
              </TabsContent>
            </Tabs>

          </CardContent>

          <CardFooter className="flex flex-col space-y-4 pt-0">
            {/* Only show user-related links for user login */}
            {activeTab === 'user' && (
              <>
                {/* Forgot Password Link */}
                <Button
                  variant="link"
                  className="text-cartoon-purple hover:text-cartoon-purple/80"
                  onClick={() => onNavigate('forgot-password')}
                >
                  Forgot your password?
                </Button>

                {/* Sign Up Link */}
                <div className="text-center text-sm text-muted-foreground">
                  Don't have an account?{' '}
                  <Button
                    variant="link"
                    className="text-cartoon-blue hover:text-cartoon-blue/80 p-0 h-auto font-medium"
                    onClick={() => onNavigate('signup')}
                  >
                    Sign up here
                  </Button>
                </div>
              </>
            )}
          </CardFooter>
        </Card>

        {/* Feature Highlights */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.8, duration: 0.6 }}
          className="mt-8 grid grid-cols-3 gap-4 text-center"
        >
          {[
            { icon: '📊', title: 'Smart Analytics', color: 'from-cartoon-blue to-blue-400' },
            { icon: '🎯', title: 'Goal Tracking', color: 'from-cartoon-purple to-purple-400' },
            { icon: '💰', title: 'Budget Control', color: 'from-cartoon-mint to-emerald-400' }
          ].map((feature, index) => (
            <motion.div
              key={feature.title}
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: 1 + index * 0.1, duration: 0.4 }}
              className="cartoon-card bg-white/80 backdrop-blur-sm p-4"
            >
              <div className={`w-12 h-12 mx-auto mb-2 rounded-2xl bg-gradient-to-br ${feature.color} flex items-center justify-center text-xl shadow-lg`}>
                {feature.icon}
              </div>
              <p className="text-xs font-medium text-muted-foreground">{feature.title}</p>
            </motion.div>
          ))}
        </motion.div>
      </motion.div>
    </div>
  );
}