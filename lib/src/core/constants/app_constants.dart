/// App-wide constants that aren't strictly "theme" or "API".
class AppConstants {
  AppConstants._();

  static const String appName = 'Music Wave';

  /// Minimum number of artists a person must pick during onboarding
  /// before recommendations can be personalized.
  static const int minSingersToSelect = 3;

  static const int defaultPageLimit = 20;
  static const int homeSectionLimit = 12;
  static const int maxRecentSearches = 10;

  static const Duration searchDebounce = Duration(milliseconds: 450);
}
