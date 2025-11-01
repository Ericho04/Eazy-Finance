import { useState, useRef, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "../ui/card";
import { Button } from "../ui/button";
import { Input } from "../ui/input";
import { ArrowLeft, Smartphone, RotateCcw } from "lucide-react";
import { motion } from "motion/react";

interface OTPPageProps {
  onNavigate: (page: string) => void;
  phoneNumber?: string;
}

export function OTPPage({ onNavigate, phoneNumber = "+60 12-345 6789" }: OTPPageProps) {
  const [otp, setOtp] = useState(['', '', '', '', '', '']);
  const [isLoading, setIsLoading] = useState(false);
  const [timeLeft, setTimeLeft] = useState(60);
  const [canResend, setCanResend] = useState(false);
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

  // Countdown timer
  useEffect(() => {
    if (timeLeft > 0) {
      const timer = setTimeout(() => setTimeLeft(timeLeft - 1), 1000);
      return () => clearTimeout(timer);
    } else {
      setCanResend(true);
    }
  }, [timeLeft]);

  const handleOtpChange = (index: number, value: string) => {
    if (value.length > 1) return;
    
    const newOtp = [...otp];
    newOtp[index] = value;
    setOtp(newOtp);

    // Auto-focus next input
    if (value && index < 5) {
      inputRefs.current[index + 1]?.focus();
    }
  };

  const handleKeyDown = (index: number, e: React.KeyboardEvent) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      inputRefs.current[index - 1]?.focus();
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const otpCode = otp.join('');
    
    if (otpCode.length !== 6) return;
    
    setIsLoading(true);
    
    // Simulate OTP verification
    await new Promise(resolve => setTimeout(resolve, 1500));
    
    setIsLoading(false);
    onNavigate('settings');
  };

  const handleResend = async () => {
    setCanResend(false);
    setTimeLeft(60);
    
    // Simulate resend API call
    await new Promise(resolve => setTimeout(resolve, 1000));
    console.log('OTP resent');
  };

  const isComplete = otp.every(digit => digit !== '');

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
          <h1 className="text-xl font-semibold text-white ml-3">Verify Phone</h1>
        </div>

        {/* OTP Card */}
        <Card className="border-0 shadow-2xl bg-white/95 backdrop-blur-sm">
          <CardHeader className="text-center pb-4">
            <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-[color:var(--sfms-success-light)] flex items-center justify-center">
              <Smartphone className="w-8 h-8 text-[color:var(--sfms-success)]" />
            </div>
            <CardTitle className="text-xl text-[color:var(--sfms-success)]">Enter Verification Code</CardTitle>
            <p className="text-muted-foreground text-sm">
              We've sent a 6-digit code to<br />
              <strong>{phoneNumber}</strong>
            </p>
          </CardHeader>
          
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-6">
              {/* OTP Input */}
              <div className="flex gap-3 justify-center">
                {otp.map((digit, index) => (
                  <motion.div
                    key={index}
                    initial={{ scale: 0.8, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    transition={{ duration: 0.2, delay: index * 0.1 }}
                  >
                    <Input
                      ref={(el) => { inputRefs.current[index] = el; }}
                      type="text"
                      inputMode="numeric"
                      maxLength={1}
                      value={digit}
                      onChange={(e) => handleOtpChange(index, e.target.value)}
                      onKeyDown={(e) => handleKeyDown(index, e)}
                      className={`w-12 h-14 text-center text-lg font-semibold border-2 ${
                        digit 
                          ? 'border-[color:var(--sfms-success)] bg-[color:var(--sfms-success-light)]' 
                          : 'border-[color:var(--sfms-neutral-medium)] bg-[color:var(--sfms-neutral-light)]'
                      }`}
                    />
                  </motion.div>
                ))}
              </div>

              {/* Timer */}
              <div className="text-center">
                {!canResend ? (
                  <p className="text-muted-foreground text-sm">
                    Resend code in <span className="font-medium text-[color:var(--sfms-success)]">
                      00:{timeLeft.toString().padStart(2, '0')}
                    </span>
                  </p>
                ) : (
                  <Button
                    type="button"
                    variant="link"
                    onClick={handleResend}
                    className="text-[color:var(--sfms-success)] p-0 h-auto text-sm font-medium"
                  >
                    <RotateCcw className="w-4 h-4 mr-2" />
                    Resend Code
                  </Button>
                )}
              </div>

              {/* Verify Button */}
              <motion.div
                whileHover={{ scale: isComplete ? 1.02 : 1 }}
                whileTap={{ scale: isComplete ? 0.98 : 1 }}
              >
                <Button
                  type="submit"
                  className="w-full h-12 gradient-success text-white shadow-lg"
                  disabled={!isComplete || isLoading}
                >
                  {isLoading ? (
                    <div className="flex items-center gap-2">
                      <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                      Verifying...
                    </div>
                  ) : (
                    'Verify Code'
                  )}
                </Button>
              </motion.div>
            </form>

            {/* Help Text */}
            <div className="text-center mt-6">
              <p className="text-muted-foreground text-xs">
                Didn't receive the code? Check your SMS or try resending.
              </p>
            </div>
          </CardContent>
        </Card>
      </motion.div>
    </div>
  );
}