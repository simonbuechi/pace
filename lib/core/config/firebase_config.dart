import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized configuration for Firebase Web Backend.
/// Reads credentials securely from .env (which is excluded from version control).
class FirebaseConfig {
  static String _get(String key) {
    if (!dotenv.isInitialized) return '';
    return dotenv.maybeGet(key) ?? '';
  }

  static String get apiKey => _get('FIREBASE_API_KEY');
  static String get authDomain => _get('FIREBASE_AUTH_DOMAIN');
  static String get projectId => _get('FIREBASE_PROJECT_ID');
  static String get storageBucket => _get('FIREBASE_STORAGE_BUCKET');
  static String get messagingSenderId => _get('FIREBASE_MESSAGING_SENDER_ID');
  static String get appId => _get('FIREBASE_APP_ID');
  static String get measurementId => _get('FIREBASE_MEASUREMENT_ID');

  /// Whether valid Firebase configuration has been supplied via environment variables
  static bool get isConfigured =>
      apiKey.isNotEmpty && projectId.isNotEmpty && appId.isNotEmpty;

  /// Returns the configuration as a map matching the Firebase JS SDK Web Options
  static Map<String, String> toMap() => {
        'apiKey': apiKey,
        'authDomain': authDomain,
        'projectId': projectId,
        'storageBucket': storageBucket,
        'messagingSenderId': messagingSenderId,
        'appId': appId,
        'measurementId': measurementId,
      };
}
