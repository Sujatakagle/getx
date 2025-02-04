
import 'package:flutter/foundation.dart';

class chargerdetails {
  static const String prodBaseUrl = 'http://192.168.1.32:4444';
  static const String devBaseUrl = 'http://192.168.1.32:4444';
  static const String testingBaseUrl = 'http://192.168.1.32:4444';

  // Dynamically select the base URL based on the environment
  static final String baseUrl = _getBaseUrl();

  // Private method to determine the base URL
  static String _getBaseUrl() {
    if (kDebugMode) {
      // Debug mode
      return testingBaseUrl;
    } else if (kProfileMode) {
      // Profile mode
      return devBaseUrl;
    } else if (kReleaseMode) {
      // Release mode
      return prodBaseUrl;
    }
    return prodBaseUrl; // Default to production URL as a fallback
  }
}
