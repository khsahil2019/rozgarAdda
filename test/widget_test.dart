// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:get/get.dart';
import 'package:rojgar/main.dart';
import 'package:rojgar/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App builds with English locale', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    Get.put(StorageService(prefs), permanent: true);
    await tester.pumpWidget(
      const MyApp(
        initialLocale: Locale('en'),
        isCandidateLoggedIn: false,
        isEmployerLoggedIn: false,
      ),
    );
    // Verify that we rendered a GetMaterialApp
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
