class ApiRoutes {
  static const String baseUrl = 'https://rozgaradda.com/api';

  // Helper method to build url
  static String _buildUrl(String path) => '$baseUrl/$path';

  //endpoints
  static String get login => _buildUrl('candidate/login');
  static String get register => _buildUrl('candidate/register');
  static String get forgotPassword => _buildUrl('candidate/forgot-password');
  static String get resetPassword => _buildUrl('candidate/reset-password');
  static String get verifyEmail => _buildUrl('candidate/verify-email');

  // OTP
  static String get sendOtp => _buildUrl('send-otp');
  static String get verifyOtp => _buildUrl('verify-otp');

  // News
  static String get textNews => _buildUrl('text-news');
  static String get videoNews => _buildUrl('video-news');
  static String get videosNews => _buildUrl('videos-news');

  // Sell Product
  static String get categories => _buildUrl('categories');
  static String get subcategories => _buildUrl('subcategories');
  static String get addProduct => _buildUrl('sell/add');
}
