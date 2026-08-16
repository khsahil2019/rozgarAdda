import 'package:flutter/material.dart';

import 'app_colors.dart';


extension ThemeExtensions on BuildContext {
  /// Get the AppColors extension from the current theme
  NewAppColors get colors => Theme.of(this).extension<NewAppColors>()!;
}
