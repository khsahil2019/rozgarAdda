import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSizes {
  // Spacing (Generous spacing for breathable UI)
  static double get paddingXS => 6.w; // Increased from 4
  static double get paddingS => 10.w; // Increased from 8
  static double get paddingM => 16.w; // Increased from 12
  static double get paddingL => 20.w; // Increased from 16
  static double get paddingXL => 28.w; // Increased from 24
  static double get padding2XL => 36.w; // Increased from 32

  // Border Radius (Smoother, more modern)
  static double get radiusS => 6.r; // Increased from 4
  static double get radiusM => 10.r; // Increased from 6
  static double get radiusL => 14.r; // Increased from 8
  static double get radiusXL => 18.r; // Increased from 12
  static double get radiusXXL => 24.r; // Increased from 16

  // Icon Sizes (Better visual hierarchy)
  static double get iconSizeS => 18.w; // Increased from 16
  static double get iconSizeM => 22.w; // Increased from 20
  static double get iconSizeL => 26.w; // Increased from 24
  static double get iconSizeXL => 32.w; // Increased from 28
  static double get iconSizeXXL => 0.3.sw; // Increased from 32

  // Component Heights (More comfortable touch targets)
  static double get buttonHeight => 52.h; // Increased from 48
  static double get inputHeight => 52.h; // Increased from 48

  // Card spacing
  static double get cardSpacing => 16.w; // Consistent card gaps
  static double get sectionSpacing => 24.h; // Space between sections
}
