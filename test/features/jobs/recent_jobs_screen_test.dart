import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rojgar/features/jobs/presentation/screens/recent_jobs_screen.dart';
import 'package:rojgar/localization/app_localizations.dart';

void main() {
  testWidgets('RecentJobsScreen builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecentJobsScreen(),
          );
        },
      ),
    );
    
    // Pump a few frames to run the layout
    await tester.pump();
    
    // Advance the mock time by 900ms to let the _loadRecentJobs timer finish
    await tester.pump(const Duration(milliseconds: 900));
    
    // Pump again to render the loaded state
    await tester.pump();
    
    expect(find.byType(RecentJobsScreen), findsOneWidget);
  });
}
