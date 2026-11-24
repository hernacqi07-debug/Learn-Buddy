/// Runtime configuration injected via `--dart-define` with safe defaults for Learn Buddy.
class AppConfig {
  const AppConfig._();

  static const String _defaultUrl = 'https://reoqmeygowfqubicsywl.supabase.co';
  static const String _defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJlb3FtZXlnb3dmcXViaWNzeXdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ0NTI1MDgsImV4cCI6MjExMDAyODUwOH0.XomVI2hQJGf5iNFMo5YCgzXIpmm1m_PugELmdamP9Pc';

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _defaultUrl,
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: _defaultAnonKey,
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
