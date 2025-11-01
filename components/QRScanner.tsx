import { useState, useRef, useCallback, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { 
  ArrowLeft,
  QrCode,
  CheckCircle,
  AlertCircle,
  RotateCcw,
  Flashlight,
  FlashlightOff,
  Smartphone,
  Receipt,
  DollarSign,
  Calendar
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

interface QRScannerProps {
  onBack: () => void;
  onScanComplete: (data: {
    amount: string;
    description: string;
    category: string;
    date: string;
    merchant?: string;
    reference?: string;
  }) => void;
}

interface QRResult {
  type: 'expense' | 'payment' | 'invoice' | 'unknown';
  amount?: string;
  description?: string;
  category?: string;
  date?: string;
  merchant?: string;
  reference?: string;
  rawData: string;
}

export function QRScanner({ onBack, onScanComplete }: QRScannerProps) {
  const [isScanning, setIsScanning] = useState(true);
  const [scanResult, setScanResult] = useState<QRResult | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [flashEnabled, setFlashEnabled] = useState(false);
  const [stream, setStream] = useState<MediaStream | null>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);

  // Initialize camera
  const initCamera = useCallback(async () => {
    try {
      const mediaStream = await navigator.mediaDevices.getUserMedia({
        video: { 
          facingMode: 'environment',
          width: { ideal: 1920 },
          height: { ideal: 1080 }
        }
      });
      
      if (videoRef.current) {
        videoRef.current.srcObject = mediaStream;
        setStream(mediaStream);
        setError(null);
      }
    } catch (error) {
      console.error('Error accessing camera:', error);
      setError('Unable to access camera. Please check permissions and try again.');
    }
  }, []);

  // Stop camera
  const stopCamera = useCallback(() => {
    if (stream) {
      stream.getTracks().forEach(track => track.stop());
      setStream(null);
    }
  }, [stream]);

  // Toggle flashlight
  const toggleFlashlight = async () => {
    if (stream) {
      const videoTrack = stream.getVideoTracks()[0];
      if (videoTrack && 'torch' in videoTrack.getCapabilities()) {
        try {
          await videoTrack.applyConstraints({
            // @ts-ignore - torch constraint
            advanced: [{ torch: !flashEnabled }]
          });
          setFlashEnabled(!flashEnabled);
        } catch (err) {
          console.error('Error toggling flashlight:', err);
        }
      }
    }
  };

  // Mock QR code detection (in real app, use a QR library like qr-scanner)
  const scanForQR = useCallback(() => {
    if (!isScanning || scanResult) return;

    // Simulate QR code detection after 3 seconds
    const timer = setTimeout(() => {
      if (isScanning) {
        // Mock QR code data - simulate different types of payment QR codes
        const mockQRData = [
          {
            type: 'expense' as const,
            rawData: 'PAY:GRAB:FOOD:25.50:2024-01-15:Grab Food Order #GF123456',
            amount: '25.50',
            description: 'Grab Food Order #GF123456',
            category: 'Food & Dining',
            date: new Date().toISOString().split('T')[0],
            merchant: 'Grab Food',
            reference: 'GF123456'
          },
          {
            type: 'payment' as const,
            rawData: 'PAY:TNG:15.75:2024-01-15:Touch n Go Payment',
            amount: '15.75',
            description: 'Touch n Go Payment',
            category: 'Transportation',
            date: new Date().toISOString().split('T')[0],
            merchant: 'Touch n Go',
            reference: 'TNG' + Date.now()
          },
          {
            type: 'invoice' as const,
            rawData: 'INV:STARBUCKS:12.90:2024-01-15:Caffe Latte',
            amount: '12.90',
            description: 'Caffe Latte',
            category: 'Coffee & Tea',
            date: new Date().toISOString().split('T')[0],
            merchant: 'Starbucks',
            reference: 'SB' + Date.now()
          }
        ];

        const randomData = mockQRData[Math.floor(Math.random() * mockQRData.length)];
        setScanResult(randomData);
        setIsScanning(false);
        stopCamera();
      }
    }, 3000);

    return () => clearTimeout(timer);
  }, [isScanning, scanResult, stopCamera]);

  // Initialize camera on mount
  useEffect(() => {
    if (isScanning) {
      initCamera();
      const cleanup = scanForQR();
      return cleanup;
    }
  }, [initCamera, scanForQR, isScanning]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      stopCamera();
    };
  }, [stopCamera]);

  // Retry scanning
  const retryScanning = () => {
    setScanResult(null);
    setError(null);
    setIsScanning(true);
  };

  // Parse QR result to expense data
  const parseQRToExpense = (result: QRResult) => {
    return {
      amount: result.amount || '',
      description: result.description || 'QR Payment',
      category: result.category || 'Others',
      date: result.date || new Date().toISOString().split('T')[0],
      merchant: result.merchant,
      reference: result.reference
    };
  };

  // Confirm QR result
  const confirmResult = () => {
    if (scanResult) {
      const expenseData = parseQRToExpense(scanResult);
      onScanComplete(expenseData);
    }
  };

  // Error view
  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-red-50 via-orange-50 to-yellow-50 flex items-center justify-center px-4">
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="text-center"
        >
          <div className="w-20 h-20 mx-auto mb-6 bg-gradient-to-r from-red-400 to-orange-400 rounded-full flex items-center justify-center">
            <AlertCircle className="w-10 h-10 text-white" />
          </div>
          
          <h2 className="text-2xl font-bold text-gray-800 mb-4">Camera Access Required</h2>
          <p className="text-gray-600 mb-8 max-w-sm mx-auto">{error}</p>
          
          <div className="flex gap-3">
            <Button
              onClick={onBack}
              variant="outline"
              className="flex-1"
            >
              Go Back
            </Button>
            <Button
              onClick={retryScanning}
              className="flex-1 bg-gradient-to-r from-red-500 to-orange-500 text-white"
            >
              Try Again
            </Button>
          </div>
        </motion.div>
      </div>
    );
  }

  // Success view with QR result
  if (scanResult) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-teal-50 to-blue-50">
        {/* Header */}
        <div className="flex items-center justify-between p-4 pb-2">
          <Button
            onClick={retryScanning}
            variant="ghost"
            className="cartoon-button bg-white/80 backdrop-blur-sm"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Scan Again
          </Button>
          
          <div className="text-center">
            <h1 className="font-bold text-gray-800">QR Code Detected</h1>
            <div className="flex items-center gap-1 mt-1">
              <CheckCircle className="w-3 h-3 text-green-500" />
              <span className="text-xs text-green-600 font-medium">
                Successfully scanned
              </span>
            </div>
          </div>
          
          <div className="w-16" />
        </div>

        <div className="px-4 space-y-6">
          {/* Success Animation */}
          <motion.div
            initial={{ opacity: 0, scale: 0.5 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ type: 'spring', damping: 15, stiffness: 200 }}
            className="text-center py-8"
          >
            <motion.div
              animate={{ scale: [1, 1.1, 1] }}
              transition={{ duration: 2, repeat: Infinity }}
              className="w-24 h-24 mx-auto mb-4 bg-gradient-to-r from-green-400 to-teal-400 rounded-full flex items-center justify-center"
            >
              <QrCode className="w-12 h-12 text-white" />
            </motion.div>
            
            <h2 className="text-xl font-bold text-gray-800 mb-2">QR Code Scanned!</h2>
            <p className="text-gray-600">Payment information extracted successfully</p>
          </motion.div>

          {/* QR Data Type */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
          >
            <Card className="cartoon-card bg-white border-0">
              <CardContent className="p-4">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gradient-to-r from-purple-400 to-pink-400 rounded-full flex items-center justify-center">
                    {scanResult.type === 'expense' && <Receipt className="w-5 h-5 text-white" />}
                    {scanResult.type === 'payment' && <Smartphone className="w-5 h-5 text-white" />}
                    {scanResult.type === 'invoice' && <Receipt className="w-5 h-5 text-white" />}
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Payment Type</p>
                    <div className="flex items-center gap-2">
                      <p className="font-medium text-gray-800 capitalize">{scanResult.type}</p>
                      <Badge className={`text-xs ${
                        scanResult.type === 'expense' ? 'bg-red-100 text-red-800' :
                        scanResult.type === 'payment' ? 'bg-blue-100 text-blue-800' :
                        'bg-green-100 text-green-800'
                      }`}>
                        {scanResult.type.toUpperCase()}
                      </Badge>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* Extracted Information */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="space-y-3"
          >
            <h3 className="font-bold text-gray-800">Payment Details</h3>
            
            {/* Amount */}
            {scanResult.amount && (
              <Card className="cartoon-card bg-gradient-to-r from-green-50 to-teal-50 border-0">
                <CardContent className="p-4">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-gradient-to-r from-green-400 to-teal-400 rounded-full flex items-center justify-center">
                      <DollarSign className="w-5 h-5 text-white" />
                    </div>
                    <div>
                      <p className="text-sm text-gray-600">Amount</p>
                      <p className="text-xl font-bold text-gray-800">RM {scanResult.amount}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            )}
            
            {/* Description */}
            {scanResult.description && (
              <Card className="cartoon-card bg-gradient-to-r from-blue-50 to-cyan-50 border-0">
                <CardContent className="p-4">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-gradient-to-r from-blue-400 to-cyan-400 rounded-full flex items-center justify-center">
                      <Receipt className="w-5 h-5 text-white" />
                    </div>
                    <div>
                      <p className="text-sm text-gray-600">Description</p>
                      <p className="font-medium text-gray-800">{scanResult.description}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            )}
            
            {/* Merchant */}
            {scanResult.merchant && (
              <Card className="cartoon-card bg-gradient-to-r from-purple-50 to-pink-50 border-0">
                <CardContent className="p-4">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-gradient-to-r from-purple-400 to-pink-400 rounded-full flex items-center justify-center">
                      <Smartphone className="w-5 h-5 text-white" />
                    </div>
                    <div>
                      <p className="text-sm text-gray-600">Merchant</p>
                      <p className="font-medium text-gray-800">{scanResult.merchant}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            )}
            
            {/* Date */}
            {scanResult.date && (
              <Card className="cartoon-card bg-gradient-to-r from-orange-50 to-yellow-50 border-0">
                <CardContent className="p-4">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-gradient-to-r from-orange-400 to-yellow-400 rounded-full flex items-center justify-center">
                      <Calendar className="w-5 h-5 text-white" />
                    </div>
                    <div>
                      <p className="text-sm text-gray-600">Date</p>
                      <p className="font-medium text-gray-800">
                        {new Date(scanResult.date).toLocaleDateString()}
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            )}
            
            {/* Reference */}
            {scanResult.reference && (
              <Card className="cartoon-card bg-gradient-to-r from-gray-50 to-slate-50 border-0">
                <CardContent className="p-4">
                  <p className="text-sm text-gray-600">Reference: <span className="font-mono font-medium">{scanResult.reference}</span></p>
                </CardContent>
              </Card>
            )}
          </motion.div>

          {/* Action Buttons */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="flex gap-3 pt-4"
          >
            <Button
              onClick={retryScanning}
              variant="outline"
              className="flex-1 h-14 cartoon-button"
            >
              <QrCode className="w-5 h-5 mr-2" />
              Scan Again
            </Button>
            
            <Button
              onClick={confirmResult}
              className="flex-1 h-14 cartoon-button bg-gradient-to-r from-green-500 to-teal-500 text-white"
            >
              <CheckCircle className="w-5 h-5 mr-2" />
              Add Expense
            </Button>
          </motion.div>
        </div>
      </div>
    );
  }

  // Scanning view
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 to-black">
      {/* Header */}
      <div className="relative z-10 flex items-center justify-between p-4 bg-gradient-to-b from-black/50 to-transparent">
        <Button
          onClick={onBack}
          variant="ghost"
          className="cartoon-button bg-white/20 backdrop-blur-sm text-white border-white/30"
        >
          <ArrowLeft className="w-4 h-4 mr-2" />
          Back
        </Button>
        
        <div className="text-center">
          <h1 className="text-lg font-bold text-white">Scan QR Code</h1>
          <p className="text-sm text-white/80">Point camera at QR code</p>
        </div>
        
        <Button
          onClick={toggleFlashlight}
          variant="ghost"
          className="cartoon-button bg-white/20 backdrop-blur-sm text-white border-white/30 w-12 h-12 p-0"
        >
          {flashEnabled ? (
            <FlashlightOff className="w-5 h-5" />
          ) : (
            <Flashlight className="w-5 h-5" />
          )}
        </Button>
      </div>

      {/* Camera View */}
      <div className="relative h-screen">
        <video
          ref={videoRef}
          autoPlay
          playsInline
          muted
          className="absolute inset-0 w-full h-full object-cover"
        />
        
        {/* Overlay with scanning frame */}
        <div className="absolute inset-0 bg-black/30">
          {/* QR Code scanning frame */}
          <div className="absolute inset-0 flex items-center justify-center p-8">
            <div className="relative w-64 h-64 border-2 border-white/80 rounded-2xl">
              {/* Corner indicators */}
              <div className="absolute -top-1 -left-1 w-8 h-8 border-l-4 border-t-4 border-white rounded-tl-lg" />
              <div className="absolute -top-1 -right-1 w-8 h-8 border-r-4 border-t-4 border-white rounded-tr-lg" />
              <div className="absolute -bottom-1 -left-1 w-8 h-8 border-l-4 border-b-4 border-white rounded-bl-lg" />
              <div className="absolute -bottom-1 -right-1 w-8 h-8 border-r-4 border-b-4 border-white rounded-br-lg" />
              
              {/* Center QR icon */}
              <div className="absolute inset-0 flex items-center justify-center">
                <motion.div
                  animate={{ scale: [1, 1.1, 1] }}
                  transition={{ duration: 2, repeat: Infinity }}
                  className="w-16 h-16 bg-white/20 rounded-lg flex items-center justify-center"
                >
                  <QrCode className="w-8 h-8 text-white" />
                </motion.div>
              </div>
              
              {/* Scanning animation */}
              <motion.div
                animate={{ y: ['0%', '100%'] }}
                transition={{ duration: 2, repeat: Infinity, ease: 'easeInOut' }}
                className="absolute w-full h-1 bg-gradient-to-r from-transparent via-green-400 to-transparent opacity-80"
              />
              
              {/* Instructions */}
              <div className="absolute -bottom-20 left-1/2 transform -translate-x-1/2 text-center">
                <p className="text-white text-sm font-medium">
                  Position QR code within the frame
                </p>
                <p className="text-white/70 text-xs mt-1">
                  Scanning will happen automatically
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Scanning indicator */}
        <div className="absolute top-32 left-0 right-0 flex justify-center">
          <motion.div
            animate={{ opacity: [0.5, 1, 0.5] }}
            transition={{ duration: 1.5, repeat: Infinity }}
            className="bg-white/20 backdrop-blur-sm rounded-full px-4 py-2 flex items-center gap-2"
          >
            <motion.div
              animate={{ rotate: 360 }}
              transition={{ duration: 2, repeat: Infinity, ease: 'linear' }}
              className="w-4 h-4 border-2 border-white border-t-transparent rounded-full"
            />
            <span className="text-white text-sm font-medium">Scanning...</span>
          </motion.div>
        </div>
      </div>

      {/* Hidden canvas for processing */}
      <canvas ref={canvasRef} className="hidden" />
    </div>
  );
}