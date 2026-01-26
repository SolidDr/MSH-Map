/// Application-wide constants
abstract class AppConstants {
  // API Configuration
  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String merchantsCollection = 'merchants';
  static const String dishesCollection = 'dishes';
  static const String menusCollection = 'menus';

  // Pagination
  static const int defaultPageSize = 20;

  // Image Configuration
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int imageQuality = 85;

  // Cache Duration
  static const Duration cacheDuration = Duration(minutes: 15);
}
