/// Environment configuration
///
/// To configure, create a `.env` file in the project root:
/// ```
/// SUPABASE_URL=https://your-project.supabase.co
/// SUPABASE_ANON_KEY=your-anon-key
/// ```
class EnvConfig {
  // These should be loaded from environment variables or build configuration
  // For development, you can hardcode them here temporarily

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '', // Add your Supabase URL here for development
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '', // Add your Supabase anon key here for development
  );

  /// Check if environment is configured
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
}
