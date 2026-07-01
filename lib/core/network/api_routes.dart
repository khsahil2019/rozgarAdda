class ApiRoutes {
  static const String baseUrl = 'https://rozgaradda.com/api';

  // Helper method to build url
  static String _buildUrl(String path) => '$baseUrl/$path';

  //endpoints
  static String get login => _buildUrl('candidate/login');
  static String get register => _buildUrl('candidate/register');
  static String get employerLogin => _buildUrl('emp/login');
  static String get employerRegister => _buildUrl('emp/register');
  static String get employerJobs => _buildUrl('emp/jobs');
  static String get postJob => _buildUrl('emp/post-job');
  static String get employerStatus => _buildUrl('emp/status');
  static String employerApplications(int jobId) =>
      _buildUrl('emp/applications/$jobId');
  static String employerApplicationDetails(int applicationId) =>
      _buildUrl('emp/get-details/$applicationId');
  static String employerExportApplications(int jobId) =>
      _buildUrl('emp/jobs/$jobId/applications/export');
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
  static String get getProducts => _buildUrl('get-products');
  static String productDetails(int productId) =>
      _buildUrl('product-details/$productId');

  // Jobs
  static String get dashboard => _buildUrl('candidate/dashboard');
  static String get jobRoles => _buildUrl('candidate/job-roles');
  static String availableJobs(int roleId) =>
      _buildUrl('candidate/available-jobs/$roleId');
  static String applyJob(int jobId) => _buildUrl('apply-job/$jobId');
  static String callAndChatApply(int jobId) =>
      _buildUrl('call-and-chat-apply/$jobId');
  static String get latestJobs => _buildUrl('latest-jobs');

  // Chat
  static String get startChat => _buildUrl('chat/start');
  static String get myEnquiries => _buildUrl('chat/my-enquiries');
  static String chatMessages(int chatId) => _buildUrl('chat/$chatId/messages');
  static String sendMessage(int chatId) => _buildUrl('chat/$chatId/send');

  // Missing Person
  static String get missingPersons => _buildUrl('missing-person');

  // Profile
  static String get myApplications => _buildUrl('my-applications');
  static String get editProfile => _buildUrl('candidate/edit-profile');
  static String get changePassword => _buildUrl('candidate/change-password');
  static String get inquiry => _buildUrl('candidate/inquiry');
}
