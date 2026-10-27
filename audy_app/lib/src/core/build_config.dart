import 'package:flutter/foundation.dart';

/// Public build configuration. Never put server credentials in Dart defines.
abstract final class BuildConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zltkubxggxprdjnspbfk.supabase.co',
  );
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_oMatucQUNC7OFMhiC1SsaA_PzHzj-2z',
  );
  static const enableDebugAccounts =
      !kIsWeb ||
      bool.fromEnvironment('ENABLE_DEBUG_ACCOUNTS', defaultValue: false);
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
}
