class ApiRoutes {
  static const String baseUrl = 'https://rozgaradda.com/api';

  // Helper method to build url
  static String _buildUrl(String path) => '$baseUrl/$path';

  //endpoints
  static String get login => _buildUrl("candidate/login");
  static String get register => _buildUrl("candidate/register");
  static String get forgotPassword => _buildUrl("candidate/forgot-password");
  static String get resetPassword => _buildUrl("candidate/reset-password");
  static String get verifyEmail => _buildUrl("candidate/verify-email");

  // static String get getAllCountries => _buildUrl("countries");
  // static String get getAllStates => _buildUrl("states");
  // static String get getAllCities => _buildUrl("cities");
}
