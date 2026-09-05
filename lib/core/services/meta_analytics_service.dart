import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

/// Centralized service to manage Meta (Facebook) App Events for Ads tracking,
/// attribution, conversions, and app analytics.
class MetaAnalyticsService {
  MetaAnalyticsService._internal();
  static final MetaAnalyticsService instance = MetaAnalyticsService._internal();

  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  /// Initialize Meta SDK settings
  Future<void> init() async {
    try {
      await _facebookAppEvents.setAutoLogAppEventsEnabled(true);
      await _facebookAppEvents.setAdvertiserTracking(enabled: true);
      debugPrint('✅ [MetaAnalyticsService] Initialized successfully with App ID: 1608368847684113');
    } catch (e) {
      debugPrint('⚠️ [MetaAnalyticsService] Initialization error: $e');
    }
  }

  /// Set the user identifier for user-level conversion tracking
  Future<void> setUserId(String userId) async {
    try {
      await _facebookAppEvents.setUserID(userId);
    } catch (e) {
      debugPrint('⚠️ [MetaAnalyticsService] setUserId error: $e');
    }
  }

  /// Clear the user identifier on logout
  Future<void> clearUserId() async {
    try {
      await _facebookAppEvents.clearUserID();
    } catch (e) {
      debugPrint('⚠️ [MetaAnalyticsService] clearUserId error: $e');
    }
  }

  /// 1. Registration Event (CompleteRegistration)
  Future<void> logCompleteRegistration({String registrationMethod = 'phone_otp'}) async {
    try {
      await _facebookAppEvents.logCompletedRegistration(
        registrationMethod: registrationMethod,
      );
      debugPrint('📊 [Meta Event] CompleteRegistration (method: $registrationMethod)');
    } catch (e) {
      debugPrint('⚠️ [MetaAnalyticsService] logCompleteRegistration error: $e');
    }
  }

  /// 2. View Content Event (ViewContent) - When user opens a Job, News, or Product detail
  Future<void> logViewContent({
    required String id,
    required String type,
    String? title,
    double? price,
    String currency = 'INR',
  }) async {
    try {
      await _facebookAppEvents.logViewContent(
        id: id,
        type: type,
        price: price ?? 0.0,
        currency: currency,
      );
      if (title != null && title.isNotEmpty) {
        await _facebookAppEvents.logEvent(
          name: 'fb_mobile_content_view',
          parameters: {
            'content_id': id,
            'content_type': type,
            'content_name': title,
          },
        );
      }
      debugPrint('📊 [Meta Event] ViewContent (id: $id, type: $type, title: $title)');
    } catch (e) {
      debugPrint('⚠️ [MetaAnalyticsService] logViewContent error: $e');
    }
  }

  /// 3. Submit Application Event (SubmitApplication) - When candidate applies for a job
  Future<void> logSubmitApplication({
    required int jobId,
    required String jobTitle,
    String? category,
    String? salary,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'SubmitApplication',
        parameters: {
          'content_id': jobId.toString(),
          'content_name': jobTitle,
          'content_category': category ?? 'Job',
          'salary': salary ?? '',
          'status': 'submitted',
        },
      );
      debugPrint('📊 [Meta Event] SubmitApplication (jobId: $jobId, title: $jobTitle)');
    } catch (e) {
      debugPrint('⚠️ [MetaAnalyticsService] logSubmitApplication error: $e');
    }
  }

  /// 4. Contact Event (Contact) - When user clicks Direct Call or WhatsApp Chat for a job
  Future<void> logContact({
    required String type, // 'call' or 'whatsapp'
    int? jobId,
    String? title,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'Contact',
        parameters: {
          'contact_type': type,
          if (jobId != null) 'content_id': jobId.toString(),
          if (title != null) 'content_name': title,
        },
      );
      debugPrint('📊 [Meta Event] Contact (type: $type, jobId: $jobId)');
    } catch (e) {
      debugPrint('⚠️ [MetaAnalyticsService] logContact error: $e');
    }
  }

  /// 5. Search Event (Search) - When user searches jobs, locations, or categories
  Future<void> logSearch({
    required String query,
    String? contentType,
  }) async {
    try {
      if (query.trim().isEmpty) return;
      await _facebookAppEvents.logEvent(
        name: 'Search',
        parameters: {
          'search_string': query.trim(),
          'content_type': contentType ?? 'jobs',
        },
      );
      debugPrint('📊 [Meta Event] Search (query: $query)');
    } catch (e) {
      debugPrint('⚠️ [MetaAnalyticsService] logSearch error: $e');
    }
  }

  /// Generic / Custom Event
  Future<void> logCustomEvent({
    required String name,
    Map<String, dynamic>? parameters,
    double? valueToSum,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: name,
        parameters: parameters,
        valueToSum: valueToSum,
      );
      debugPrint('📊 [Meta Event] Custom: $name ($parameters)');
    } catch (e) {
      debugPrint('⚠️ [MetaAnalyticsService] logCustomEvent error: $e');
    }
  }
}
