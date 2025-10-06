class AppConstants {
  AppConstants._();

  static const String nutritionBaseUrl = 'https://www.themealdb.com/api.php';
  static const String workoutsBaseUrl = 'https://www.exercisedb.dev';
  static const Duration defaultTimeout = Duration(seconds: 12);

  static const Map<String, String> defaultHeaders = <String, String>{
    'Content-Type': 'application/json',
  };
}
