import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "../ui/card";
import { Button } from "../ui/button";
import { Input } from "../ui/input";
import { Label } from "../ui/label";
import { Alert, AlertDescription } from "../ui/alert";
import { ArrowLeft, Mail, CheckCircle } from "lucide-react";
import { motion } from "motion/react";

interface ForgotPasswordPageProps {
  onNavigate: (page: string) => void;
}

export function ForgotPasswordPage({ onNavigate }: ForgotPasswordPageProps) {
  const [email, setEmail] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1500));
    
    setIsLoading(false);
    setIsSuccess(true);
  };

  if (isSuccess) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-[color:var(--sfms-success)] to-[color:var(--sfms-success)]/80 flex items-center justify-center p-4">
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.3 }}
          className="w-full max-w-md"
        >
          <Card className="border-0 shadow-2xl bg-white/95 backdrop-blur-sm">
            <CardContent className="text-center p-8">
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ duration: 0.5, delay: 0.2 }}
                className="w-16 h-16 mx-auto mb-6 rounded-full bg-[color:var(--sfms-success-light)] flex items-center justify-center"
              >
                <CheckCircle className="w-8 h-8 text-[color:var(--sfms-success)]" />
              </motion.div>
              
              <h2 className="text-xl font-semibold mb-3 text-[color:var(--sfms-success)]">
                Check Your Email
              </h2>
              
              <p className="text-muted-foreground mb-6">
                We've sent a password reset link to <strong>{email}</strong>
              </p>
              
              <div className="space-y-3">
                <Button
                  onClick={() => onNavigate('login')}
                  className="w-full gradient-success text-white"
                >
                  Back to Login
                </Button>
                
                <Button
                  variant="outline"
                  onClick={() => setIsSuccess(false)}
                  className="w-full"
                >
                  Resend Email
                </Button>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-[color:var(--sfms-success)] to-[color:var(--sfms-success)]/80 flex items-center justify-center p-4">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3 }}
        className="w-full max-w-md"
      >
        {/* Header */}
        <div className="flex items-center mb-6">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => onNavigate('login')}
            className="text-white hover:bg-white/10 p-2"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <h1 className="text-xl font-semibold text-white ml-3">Reset Password</h1>
        </div>

        {/* Reset Card */}
        <Card className="border-0 shadow-2xl bg-white/95 backdrop-blur-sm">
          <CardHeader className="text-center pb-4">
            <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-[color:var(--sfms-success-light)] flex items-center justify-center">
              <Mail className="w-8 h-8 text-[color:var(--sfms-success)]" />
            </div>
            <CardTitle className="text-xl text-[color:var(--sfms-success)]">Forgot Password?</CardTitle>
            <p className="text-muted-foreground text-sm">
              Enter your email address and we'll send you a link to reset your password
            </p>
          </CardHeader>
          
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="space-y-2">
                <Label htmlFor="email">Email Address</Label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                  <Input
                    id="email"
                    type="email"
                    placeholder="Enter your email address"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="pl-10 h-12 bg-[color:var(--sfms-neutral-light)] border-[color:var(--sfms-neutral-medium)]"
                    required
                  />
                </div>
              </div>

              <Alert className="bg-[color:var(--sfms-warning-light)] border-[color:var(--sfms-warning)]">
                <AlertDescription className="text-[color:var(--sfms-warning-foreground)]">
                  Make sure to check your spam folder if you don't receive the email within a few minutes.
                </AlertDescription>
              </Alert>

              <motion.div
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                <Button
                  type="submit"
                  className="w-full h-12 gradient-success text-white shadow-lg"
                  disabled={isLoading}
                >
                  {isLoading ? (
                    <div className="flex items-center gap-2">
                      <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                      Sending Reset Link...
                    </div>
                  ) : (
                    'Send Reset Link'
                  )}
                </Button>
              </motion.div>
            </form>

            <div className="text-center mt-6">
              <span className="text-muted-foreground text-sm">Remember your password? </span>
              <Button
                variant="link"
                className="text-[color:var(--sfms-success)] p-0 h-auto text-sm font-medium"
                onClick={() => onNavigate('login')}
              >
                Sign In
              </Button>
            </div>
          </CardContent>
        </Card>
      </motion.div>
    </div>
  );
}