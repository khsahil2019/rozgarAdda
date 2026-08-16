import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rojgar/core/theme/app_colors.dart';

import 'app_theme_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      extensions: <ThemeExtension<dynamic>>[NewAppColors.light],
      primaryColor: NewAppColors.light.brandColor,
      scaffoldBackgroundColor: NewAppColors.light.background,
      colorScheme: ColorScheme.light(
        primary: NewAppColors.light.brandColor,
        secondary: NewAppColors.light.brandColor,
        surface: NewAppColors.light.surface,
        error: NewAppColors.light.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: NewAppColors.light.textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: NewAppColors.light.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: NewAppColors.light.textPrimary,
          size: AppSizes.iconSizeM,
        ),
        titleTextStyle: TextStyle(
          color: NewAppColors.light.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      textTheme: _buildTextTheme(NewAppColors.light),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NewAppColors.light.brandColor,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NewAppColors.light.brandColor,
          side: BorderSide(color: NewAppColors.light.brandColor, width: 1.5),
          minimumSize: Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NewAppColors.light.brandColor,
          textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NewAppColors.light.fieldBg,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: NewAppColors.light.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: NewAppColors.light.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(
            color: NewAppColors.light.brandColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: NewAppColors.light.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: NewAppColors.light.error, width: 2),
        ),
        hintStyle: TextStyle(
          color: NewAppColors.light.textSecondary,
          fontSize: 14.sp,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: NewAppColors.light.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: NewAppColors.light.divider,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(
        color: NewAppColors.light.textPrimary,
        size: AppSizes.iconSizeM,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: NewAppColors.light.surface,
        selectedItemColor: NewAppColors.light.brandColor,
        unselectedItemColor: NewAppColors.light.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      extensions: <ThemeExtension<dynamic>>[NewAppColors.dark],
      primaryColor: NewAppColors.dark.brandColor,
      scaffoldBackgroundColor: NewAppColors.dark.background,
      colorScheme: ColorScheme.dark(
        primary: NewAppColors.dark.brandColor,
        secondary: NewAppColors.dark.brandColor,
        surface: NewAppColors.dark.surface,
        error: NewAppColors.dark.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: NewAppColors.dark.textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: NewAppColors.dark.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: NewAppColors.dark.textPrimary,
          size: AppSizes.iconSizeM,
        ),
        titleTextStyle: TextStyle(
          color: NewAppColors.dark.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      textTheme: _buildTextTheme(NewAppColors.dark),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NewAppColors.dark.brandColor,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NewAppColors.dark.brandColor,
          side: BorderSide(color: NewAppColors.dark.brandColor, width: 1.5),
          minimumSize: Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NewAppColors.dark.brandColor,
          textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NewAppColors.dark.fieldBg,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: NewAppColors.dark.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: NewAppColors.dark.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: NewAppColors.dark.brandColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: NewAppColors.dark.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: NewAppColors.dark.error, width: 2),
        ),
        hintStyle: TextStyle(
          color: NewAppColors.dark.textSecondary,
          fontSize: 14.sp,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: NewAppColors.dark.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: NewAppColors.dark.divider,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(
        color: NewAppColors.dark.textPrimary,
        size: AppSizes.iconSizeM,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: NewAppColors.dark.surface,
        selectedItemColor: NewAppColors.dark.brandColor,
        unselectedItemColor: NewAppColors.dark.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(NewAppColors colors) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: colors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: colors.textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: colors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      labelSmall: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        color: colors.textSecondary,
      ),
    );
  }
}
