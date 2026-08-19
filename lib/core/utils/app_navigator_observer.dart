import 'package:flutter/material.dart';

/// Lightweight NavigatorObserver that prints 1 concise line per screen change.
/// Eliminates console buffer overhead and maintains high frame performance.
class AppNavigatorObserver extends NavigatorObserver {
  void _log(Route<dynamic>? route, String action) {
    if (route == null) return;
    if (route is ModalRoute && route.barrierDismissible && route.settings.name == null) return;

    final String screenName = route.settings.name ?? route.runtimeType.toString();
    debugPrint('🚀 [NAV $action] ➜ Screen: $screenName');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log(route, 'PUSH');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _log(previousRoute, 'POP');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _log(newRoute, 'REPLACE');
    }
  }
}
