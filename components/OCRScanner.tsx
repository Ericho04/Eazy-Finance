import { useState, useRef, useCallback } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { 
  ArrowLeft,
  Camera,
  RotateCcw,
  Check,
  X,
  Scan,
  FileText,
  DollarSign,
  Tag,
  Calendar,
  Sparkles,
  Upload
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

interface OCRScannerProps {
  onBack: () => void;
  onScanComplete: (data: {
    amount: string;
    description: string;
    category: string;
    date: string;
    merchant?: string;
  }) => void;
}

interface ScanResult {
  amount: string;
  description: string;
  category: string;
  date: string;
  merchant?: string;
  confidence: number;
}

export function OCRScanner({ onBack, onScanComplete }: OCRScannerProps) {
  const [currentStep, setCurrentStep] = useState<'camera' | 'processing' | 'review'>('camera');
  const [capturedImage, setCapturedImage] = useState<string | null>(null);
  const [scanResult, setScanResult] = useState<ScanResult | null>(null);
  const [isProcessing, setIsProcessing] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [stream, setStream] = useState<MediaStream | null>(null);

  // Initialize camera
  const initCamera = useCallback(async () => {
    try {
      const mediaStream = await navigator.mediaDevices.getUserMedia({
        video: { 
          facingMode: 'environment', // Use back camera
          width: { ideal: 1920 },
          height: { ideal: 1080 }
        }
      });
      
      if (videoRef.current) {
        videoRef.current.srcObject = mediaStream;
        setStream(mediaStream);
      }
    } catch (error) {
      console.error('Error accessing camera:', error);
      alert('Unable to access camera. Please check permissions and try again.');
    }
  }, []);

  // Stop camera
  const stopCamera = useCallback(() => {
    if (stream) {
      stream.getTracks().forEach(track => track.stop());
      setStream(null);
    }
  }, [stream]);

  // Initialize camera on component mount
  useState(() => {
    if (currentStep === 'camera') {
      initCamera();
    }
    
    return () => {
      stopCamera();
    };
  });

  // Capture photo from camera
  const capturePhoto = () => {
    if (videoRef.current && canvasRef.current) {
      const canvas = canvasRef.current;
      const video = videoRef.current;
      const context = canvas.getContext('2d');
      
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
      
      if (context) {
        context.drawImage(video, 0, 0);
        const imageData = canvas.toDataURL('image/jpeg', 0.8);
        setCapturedImage(imageData);
        processReceipt(imageData);
        stopCamera();
      }
    }
  };

  // Handle file upload
  const handleFileUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const imageData = e.target?.result as string;
        setCapturedImage(imageData);
        processReceipt(imageData);
        stopCamera();
      };
      reader.readAsDataURL(file);
    }
  };

  // Process receipt with mock OCR (in real app, this would call OCR API)
  const processReceipt = async (imageData: string) => {
    setCurrentStep('processing');
    setIsProcessing(true);
    
    // Simulate OCR processing
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    // Mock OCR results - in real app, this would come from OCR service
    const mockResults: ScanResult[] = [
      {
        amount: '25.50',
        description: 'Lunch at Cafe Delights',
        category: 'Food & Dining',
        date: new Date().toISOString().split('T')[0],
        merchant: 'Cafe Delights',
        confidence: 0.92
      },
      {
        amount: '15.75',
        description: 'Coffee and pastry',
        category: 'Coffee & Tea',
        date: new Date().toISOString().split('T')[0],
        merchant: 'Starbucks',
        confidence: 0.88
      },
      {
        amount: '45.20',
        description: 'Grocery shopping',
        category: 'Groceries',
        date: new Date().toISOString().split('T')[0],
        merchant: 'SuperMart',
        confidence: 0.85
      }
    ];
    
    // Randomly select one result for demo
    const randomResult = mockResults[Math.floor(Math.random() * mockResults.length)];
    setScanResult(randomResult);
    setIsProcessing(false);
    setCurrentStep('review');
  };

  // Retry scanning
  const retryScanning = () => {
    setCapturedImage(null);
    setScanResult(null);
    setCurrentStep('camera');
    initCamera();
  };

  // Confirm and use scan result
  const confirmResult = () => {
    if (scanResult) {
      onScanComplete({
        amount: scanResult.amount,
        description: scanResult.description,
        category: scanResult.category,
        date: scanResult.date,
        merchant: scanResult.merchant
      });
    }
  };

  // Camera view
  if (currentStep === 'camera') {
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
            <h1 className="text-lg font-bold text-white">Scan Receipt</h1>
            <p className="text-sm text-white/80">Position receipt in the frame</p>
          </div>
          
          <div className="w-16" />
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
            {/* Scanning frame */}
            <div className="absolute inset-0 flex items-center justify-center p-8">
              <div className="relative w-full max-w-sm aspect-[3/4] border-2 border-white/80 rounded-2xl">
                {/* Corner indicators */}
                <div className="absolute -top-1 -left-1 w-6 h-6 border-l-4 border-t-4 border-white rounded-tl-lg" />
                <div className="absolute -top-1 -right-1 w-6 h-6 border-r-4 border-t-4 border-white rounded-tr-lg" />
                <div className="absolute -bottom-1 -left-1 w-6 h-6 border-l-4 border-b-4 border-white rounded-bl-lg" />
                <div className="absolute -bottom-1 -right-1 w-6 h-6 border-r-4 border-b-4 border-white rounded-br-lg" />
                
                {/* Scanning line animation */}
                <motion.div
                  animate={{ y: ['0%', '100%'] }}
                  transition={{ duration: 2, repeat: Infinity, ease: 'linear' }}
                  className="absolute w-full h-0.5 bg-gradient-to-r from-transparent via-white to-transparent"
                />
                
                {/* Instructions */}
                <div className="absolute -bottom-16 left-1/2 transform -translate-x-1/2 text-center">
                  <p className="text-white text-sm font-medium">
                    Align receipt within the frame
                  </p>
                  <p className="text-white/70 text-xs mt-1">
                    Make sure text is clear and readable
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Bottom controls */}
          <div className="absolute bottom-8 left-0 right-0 flex items-center justify-center gap-6 px-8">
            <Button
              onClick={() => fileInputRef.current?.click()}
              className="cartoon-button bg-white/20 backdrop-blur-sm text-white border-white/30 h-14 w-14 rounded-full"
            >
              <Upload className="w-6 h-6" />
            </Button>
            
            <motion.button
              whileTap={{ scale: 0.9 }}
              onClick={capturePhoto}
              className="w-20 h-20 bg-white rounded-full flex items-center justify-center shadow-lg"
            >
              <div className="w-16 h-16 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full flex items-center justify-center">
                <Camera className="w-8 h-8 text-white" />
              </div>
            </motion.button>
            
            <Button
              onClick={retryScanning}
              className="cartoon-button bg-white/20 backdrop-blur-sm text-white border-white/30 h-14 w-14 rounded-full"
            >
              <RotateCcw className="w-6 h-6" />
            </Button>
          </div>
        </div>

        {/* Hidden file input */}
        <input
          ref={fileInputRef}
          type="file"
          accept="image/*"
          onChange={handleFileUpload}
          className="hidden"
        />
        
        {/* Hidden canvas for photo capture */}
        <canvas ref={canvasRef} className="hidden" />
      </div>
    );
  }

  // Processing view
  if (currentStep === 'processing') {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 flex items-center justify-center px-4">
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="text-center"
        >
          <motion.div
            animate={{ rotate: 360 }}
            transition={{ duration: 2, repeat: Infinity, ease: 'linear' }}
            className="w-20 h-20 mx-auto mb-8 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full flex items-center justify-center"
          >
            <Scan className="w-10 h-10 text-white" />
          </motion.div>
          
          <h2 className="text-2xl font-bold text-gray-800 mb-4">
            Processing Receipt...
          </h2>
          
          <div className="space-y-2 mb-8">
            <motion.p
              animate={{ opacity: [0.5, 1, 0.5] }}
              transition={{ duration: 1.5, repeat: Infinity }}
              className="text-gray-600"
            >
              🔍 Analyzing image quality...
            </motion.p>
            <motion.p
              animate={{ opacity: [0.5, 1, 0.5] }}
              transition={{ duration: 1.5, repeat: Infinity, delay: 0.5 }}
              className="text-gray-600"
            >
              📝 Extracting text data...
            </motion.p>
            <motion.p
              animate={{ opacity: [0.5, 1, 0.5] }}
              transition={{ duration: 1.5, repeat: Infinity, delay: 1 }}
              className="text-gray-600"
            >
              🤖 AI categorizing expense...
            </motion.p>
          </div>
          
          {capturedImage && (
            <div className="w-32 h-40 mx-auto rounded-2xl overflow-hidden shadow-lg">
              <img 
                src={capturedImage} 
                alt="Captured receipt" 
                className="w-full h-full object-cover"
              />
            </div>
          )}
        </motion.div>
      </div>
    );
  }

  // Review results view
  if (currentStep === 'review' && scanResult) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50">
        {/* Header */}
        <div className="flex items-center justify-between p-4 pb-2">
          <Button
            onClick={retryScanning}
            variant="ghost"
            className="cartoon-button bg-white/80 backdrop-blur-sm"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Rescan
          </Button>
          
          <div className="text-center">
            <h1 className="font-bold text-gray-800">Review & Confirm</h1>
            <div className="flex items-center gap-1 mt-1">
              <Sparkles className="w-3 h-3 text-green-500" />
              <span className="text-xs text-green-600 font-medium">
                {Math.round(scanResult.confidence * 100)}% confidence
              </span>
            </div>
          </div>
          
          <div className="w-16" />
        </div>

        <div className="px-4 space-y-6">
          {/* Captured Image Preview */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <Card className="cartoon-card bg-white border-0">
              <CardContent className="p-4">
                <div className="flex items-center gap-4">
                  {capturedImage && (
                    <div className="w-20 h-24 rounded-lg overflow-hidden shadow-md flex-shrink-0">
                      <img 
                        src={capturedImage} 
                        alt="Receipt" 
                        className="w-full h-full object-cover"
                      />
                    </div>
                  )}
                  
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <FileText className="w-4 h-4 text-purple-500" />
                      <span className="font-medium text-gray-800">Receipt Scanned</span>
                      <Badge className="bg-green-100 text-green-800">
                        Processed
                      </Badge>
                    </div>
                    
                    {scanResult.merchant && (
                      <p className="text-sm text-gray-600">
                        From: <span className="font-medium">{scanResult.merchant}</span>
                      </p>
                    )}
                    
                    <p className="text-xs text-gray-500 mt-1">
                      AI extracted the following data automatically
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>

          {/* Extracted Data */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="space-y-3"
          >
            <h2 className="text-lg font-bold text-gray-800 flex items-center gap-2">
              <Sparkles className="w-5 h-5 text-purple-500" />
              Extracted Data
            </h2>
            
            {/* Amount */}
            <Card className="cartoon-card bg-gradient-to-r from-green-50 to-teal-50 border-0">
              <CardContent className="p-4">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gradient-to-r from-green-400 to-teal-400 rounded-full flex items-center justify-center">
                    <DollarSign className="w-5 h-5 text-white" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Amount</p>
                    <p className="text-2xl font-bold text-gray-800">RM {scanResult.amount}</p>
                  </div>
                </div>
              </CardContent>
            </Card>
            
            {/* Description */}
            <Card className="cartoon-card bg-gradient-to-r from-purple-50 to-pink-50 border-0">
              <CardContent className="p-4">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gradient-to-r from-purple-400 to-pink-400 rounded-full flex items-center justify-center">
                    <FileText className="w-5 h-5 text-white" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Description</p>
                    <p className="font-medium text-gray-800">{scanResult.description}</p>
                  </div>
                </div>
              </CardContent>
            </Card>
            
            {/* Category */}
            <Card className="cartoon-card bg-gradient-to-r from-blue-50 to-cyan-50 border-0">
              <CardContent className="p-4">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gradient-to-r from-blue-400 to-cyan-400 rounded-full flex items-center justify-center">
                    <Tag className="w-5 h-5 text-white" />
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Category</p>
                    <p className="font-medium text-gray-800">{scanResult.category}</p>
                  </div>
                </div>
              </CardContent>
            </Card>
            
            {/* Date */}
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
          </motion.div>

          {/* Action Buttons */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="flex gap-3 pt-4"
          >
            <Button
              onClick={retryScanning}
              variant="outline"
              className="flex-1 h-14 cartoon-button"
            >
              <X className="w-5 h-5 mr-2" />
              Rescan
            </Button>
            
            <Button
              onClick={confirmResult}
              className="flex-1 h-14 cartoon-button bg-gradient-to-r from-green-500 to-teal-500 text-white"
            >
              <Check className="w-5 h-5 mr-2" />
              Use This Data
            </Button>
          </motion.div>
        </div>
      </div>
    );
  }

  return null;
}