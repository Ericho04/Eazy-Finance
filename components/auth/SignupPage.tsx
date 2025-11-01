import { useState } from 'react';
import { motion } from 'motion/react';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '../ui/card';
import { Eye, EyeOff, Mail, Lock, User, ArrowLeft, Loader2, Sparkles } from 'lucide-react';
import { signUp, demoLogin } from '../../utils/auth';

interface SignupPageProps {
  onNavigate: (destination: string) => void;
}

export function SignupPage({ onNavigate }: SignupPageProps) {
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    password: '',
    confirmPassword: ''
  });
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [demoLoading, setDemoLoading] = useState(false);

  const handleInputChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (formData.password !== formData.confirmPassword) {
      return;
    }

    if (!formData.fullName.trim() || !formData.email.trim() || !formData.password.trim()) {
      return;
    }

    setLoading(true);
    try {
      const { user, error } = await signUp(formData.email.trim(), formData.password, formData.fullName.trim());
      if (user && !error) {
        // Navigate back to settings after successful signup
        onNavigate('settings');
      }
    } catch (error) {
      console.error('Signup error:', error);
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

  const passwordsMatch = formData.password === formData.confirmPassword;
  const isFormValid = formData.fullName.trim() && 
                     formData.email.trim() && 
                     formData.password.trim() && 
                     passwordsMatch;

  return (
    <div className="min-h-screen bg-gradient-to-br from-cartoon-purple/20 via-cartoon-pink/20 to-cartoon-orange/20 flex items-center justify-center p-4">
      {/* Floating Background Elements */}
      <div className="absolute inset-0 overflow-hidden">
        {[...Array(6)].map((_, i) => (
          <motion.div
            key={i}
            className="absolute w-24 h-24 rounded-full opacity-10"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              background: `linear-gradient(45deg, var(--cartoon-${['purple', 'pink', 'orange', 'yellow', 'mint', 'cyan'][i]}))`
            }}
            animate={{
              x: [0, -30, 0],
              y: [0, 40, 0],
              scale: [1, 1.1, 1],
            }}
            transition={{
              duration: 10 + i * 2,
              repeat: Infinity,
              ease: "easeInOut",
              delay: i * 1.8
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
        {/* Back Button */}
        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.4 }}
          className="mb-6"
        >
          <Button
            variant="ghost"
            onClick={() => onNavigate('login')}
            className="cartoon-button bg-white/80 backdrop-blur-sm"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Login
          </Button>
        </motion.div>

        {/* Signup Card */}
        <Card className="cartoon-card border-0 bg-white/95 backdrop-blur-sm shadow-2xl">
          <CardHeader className="text-center pb-6">
            <CardTitle className="text-2xl">Join SFMS! 🚀</CardTitle>
            <CardDescription>
              Create your account and start your financial journey
            </CardDescription>
          </CardHeader>

          <CardContent className="space-y-6">
            <form onSubmit={handleSignup} className="space-y-4">
              {/* Full Name Input */}
              <div className="space-y-2">
                <Label htmlFor="fullName" className="text-sm font-medium">
                  Full Name
                </Label>
                <div className="relative">
                  <User className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                  <Input
                    id="fullName"
                    type="text"
                    value={formData.fullName}
                    onChange={(e) => handleInputChange('fullName', e.target.value)}
                    placeholder="Enter your full name"
                    className="pl-10 cartoon-button border-2 focus:border-primary/50"
                    required
                  />
                </div>
              </div>

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
                    value={formData.email}
                    onChange={(e) => handleInputChange('email', e.target.value)}
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
                    value={formData.password}
                    onChange={(e) => handleInputChange('password', e.target.value)}
                    placeholder="Create a password"
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

              {/* Confirm Password Input */}
              <div className="space-y-2">
                <Label htmlFor="confirmPassword" className="text-sm font-medium">
                  Confirm Password
                </Label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                  <Input
                    id="confirmPassword"
                    type={showConfirmPassword ? "text" : "password"}
                    value={formData.confirmPassword}
                    onChange={(e) => handleInputChange('confirmPassword', e.target.value)}
                    placeholder="Confirm your password"
                    className={`pl-10 pr-10 cartoon-button border-2 focus:border-primary/50 ${
                      formData.confirmPassword && !passwordsMatch ? 'border-red-300 focus:border-red-500' : ''
                    }`}
                    required
                  />
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    className="absolute right-2 top-1/2 transform -translate-y-1/2 h-6 w-6 p-0"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                  >
                    {showConfirmPassword ? (
                      <EyeOff className="w-4 h-4" />
                    ) : (
                      <Eye className="w-4 h-4" />
                    )}
                  </Button>
                </div>
                {formData.confirmPassword && !passwordsMatch && (
                  <p className="text-sm text-red-500">Passwords do not match</p>
                )}
              </div>

              {/* Signup Button */}
              <Button
                type="submit"
                className="w-full cartoon-button bg-gradient-to-r from-cartoon-purple to-cartoon-pink hover:from-cartoon-purple/90 hover:to-cartoon-pink/90 text-white"
                disabled={loading || !isFormValid}
              >
                {loading ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Creating Account...
                  </>
                ) : (
                  <>
                    <User className="mr-2 w-4 h-4" />
                    Create Account
                  </>
                )}
              </Button>
            </form>

            {/* Divider */}
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <span className="w-full border-t border-muted" />
              </div>
              <div className="relative flex justify-center text-xs uppercase">
                <span className="bg-white px-2 text-muted-foreground">Or try demo</span>
              </div>
            </div>

            {/* Demo Login Button */}
            <Button
              type="button"
              variant="outline"
              className="w-full cartoon-button border-2 border-cartoon-cyan/50 text-cartoon-cyan hover:bg-cartoon-cyan/10"
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
          </CardContent>

          <CardFooter className="pt-0">
            <div className="text-center text-sm text-muted-foreground w-full">
              Already have an account?{' '}
              <Button
                variant="link"
                className="text-cartoon-purple hover:text-cartoon-purple/80 p-0 h-auto font-medium"
                onClick={() => onNavigate('login')}
              >
                Sign in here
              </Button>
            </div>
          </CardFooter>
        </Card>

        {/* Privacy Notice */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6, duration: 0.6 }}
          className="mt-6 text-center"
        >
          <p className="text-xs text-muted-foreground bg-white/80 rounded-xl p-3 cartoon-card">
            🔒 Your data is secure and encrypted. We never share your personal information.
          </p>
        </motion.div>
      </motion.div>
    </div>
  );
}