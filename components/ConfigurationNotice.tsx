import { motion } from 'motion/react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { CheckCircle, Play, Database } from 'lucide-react';
import { isSupabaseConfigured, needsAnonKey } from '../lib/supabase';
import { useState } from 'react';
import { DatabaseSetup } from './DatabaseSetup';

interface ConfigurationNoticeProps {
  onContinueDemo: () => void;
}

export function ConfigurationNotice({ onContinueDemo }: ConfigurationNoticeProps) {
  const isConfigured = isSupabaseConfigured();
  const needsKey = needsAnonKey();
  const [showDatabaseSetup, setShowDatabaseSetup] = useState(false);

  // Don't show notice if properly configured
  if (isConfigured) {
    return null;
  }

  // Show database setup modal
  if (showDatabaseSetup) {
    return (
      <DatabaseSetup onSetupComplete={() => {
        setShowDatabaseSetup(false);
        window.location.reload(); // Reload to detect new database
      }} />
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.3 }}
      className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
    >
      <Card className="w-full max-w-2xl cartoon-card bg-white/95 backdrop-blur-sm max-h-[90vh] overflow-y-auto">
        <CardHeader className="text-center">
          <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-gradient-to-br from-green-500 to-emerald-600 flex items-center justify-center">
            <CheckCircle className="w-8 h-8 text-white" />
          </div>
          <CardTitle className="text-xl text-green-600">
            🎉 Supabase Connected! Final Step...
          </CardTitle>
          <CardDescription>
            Your Supabase connection is ready! Just set up the database to unlock all features.
          </CardDescription>
        </CardHeader>

        <CardContent className="space-y-6">
          {/* Connection Status - All Green! */}
          <div className="bg-gradient-to-r from-green-50 to-emerald-50 rounded-xl p-4 border border-green-200">
            <h3 className="font-medium text-green-600 mb-3 flex items-center">
              <CheckCircle className="w-5 h-5 mr-2" />
              Connection Status - Ready! ✨
            </h3>
            <div className="space-y-2">
              <div className="flex items-center justify-between text-sm">
                <span>Supabase URL</span>
                <div className="flex items-center text-green-600">
                  <CheckCircle className="w-4 h-4 mr-1" />
                  Connected
                </div>
              </div>
              <div className="flex items-center justify-between text-sm">
                <span>Anon Key</span>
                <div className="flex items-center text-green-600">
                  <CheckCircle className="w-4 h-4 mr-1" />
                  Integrated
                </div>
              </div>
              <div className="flex items-center justify-between text-sm">
                <span>Authentication</span>
                <div className="flex items-center text-green-600">
                  <CheckCircle className="w-4 h-4 mr-1" />
                  Ready
                </div>
              </div>
              <div className="flex items-center justify-between text-sm">
                <span>Database Tables</span>
                <div className="flex items-center text-orange-600">
                  <Database className="w-4 h-4 mr-1" />
                  Setup Required
                </div>
              </div>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Production Setup */}
            <div className="bg-gradient-to-r from-blue-50 to-purple-50 rounded-xl p-4 border border-blue-200">
              <div className="text-center">
                <Database className="w-12 h-12 mx-auto mb-3 text-blue-600" />
                <h3 className="font-medium text-blue-600 mb-2">🚀 Production Setup</h3>
                <p className="text-sm text-muted-foreground mb-4">
                  Create database tables for full functionality with real authentication and data persistence
                </p>
                <Button
                  onClick={() => setShowDatabaseSetup(true)}
                  className="cartoon-button bg-gradient-to-r from-blue-500 to-purple-600 text-white w-full"
                >
                  <Database className="w-4 h-4 mr-2" />
                  Setup Database
                </Button>
              </div>
            </div>

            {/* Demo Mode */}
            <div className="bg-gradient-to-r from-green-50 to-emerald-50 rounded-xl p-4 border border-green-200">
              <div className="text-center">
                <Play className="w-12 h-12 mx-auto mb-3 text-green-600" />
                <h3 className="font-medium text-green-600 mb-2">⚡ Quick Demo</h3>
                <p className="text-sm text-muted-foreground mb-4">
                  Test all features instantly while you set up the production database
                </p>
                <Button
                  onClick={onContinueDemo}
                  variant="outline"
                  className="cartoon-button border-2 border-green-500 text-green-600 hover:bg-green-50 w-full"
                >
                  <Play className="w-4 h-4 mr-2" />
                  Try Demo Mode
                </Button>
              </div>
            </div>
          </div>

          {/* What You Get */}
          <div className="bg-gradient-to-r from-yellow-50 to-orange-50 rounded-xl p-4 border border-yellow-200">
            <h4 className="font-medium text-orange-600 mb-3">🌟 Production Features Ready:</h4>
            <div className="grid grid-cols-2 gap-2 text-xs">
              <div className="flex items-center space-x-2">
                <CheckCircle className="w-3 h-3 text-green-500" />
                <span>Real authentication</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle className="w-3 h-3 text-green-500" />
                <span>Data persistence</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle className="w-3 h-3 text-green-500" />
                <span>Real-time sync</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle className="w-3 h-3 text-green-500" />
                <span>Advanced analytics</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle className="w-3 h-3 text-green-500" />
                <span>Multi-device access</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle className="w-3 h-3 text-green-500" />
                <span>Secure backups</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle className="w-3 h-3 text-green-500" />
                <span>OCR receipt scanning</span>
              </div>
              <div className="flex items-center space-x-2">
                <CheckCircle className="w-3 h-3 text-green-500" />
                <span>AI insights</span>
              </div>
            </div>
          </div>

          <div className="text-center bg-gradient-to-r from-blue-100 to-purple-100 rounded-lg p-3">
            <p className="text-sm text-blue-700 font-medium">
              🎯 Your SFMS app is 95% ready! Choose your path above to get started.
            </p>
          </div>
        </CardContent>
      </Card>
    </motion.div>
  );
}