import 'package:flutter/material.dart';

class NewAppColors extends ThemeExtension<NewAppColors> {
  final Color brandColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color textHint;
  final Color textPlaceholder;
  final Color textLink;
  final Color textInverse;
  final Color textOnBrand;
  final Color background;
  final Color surface;
  final Color divider;
  final Color border;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;
  final Color iconPrimary;
  final Color gradientOne;
  final Color gradientTwo;
  final Color badgeAttendance;
  final Color badgePoints;
  final Color badgeRank;
  final Color fieldBg;

  // Dashboard Card Colors
  final Color blueIconBg;
  final Color blueIcon;
  final Color yellowIconBg;
  final Color yellowIcon;
  final Color orangeCardBg;
  final Color orangeIconBg;
  final Color orangeIcon;
  final Color purpleIcon;
  final Color purpleIconBg;

  // Support Tag Colors
  final Color purpleTagBg;
  final Color orangeTagBg;
  final Color greenTagBg;
  final Color blueTagBg;
  final Color highPriority;
  final Color mediumPriority;
  final Color lowPriority;

  // Attendance Status Colors
  final Color attendancePresent;
  final Color attendancePresentBg;
  final Color attendanceAbsent;
  final Color attendanceAbsentBg;
  final Color attendanceLate;
  final Color attendanceLateBg;
  final Color attendanceCancelled;
  final Color attendanceCancelledBg;
  final Color attendanceTrial;
  final Color attendanceTrialBg;

  final Color mintGreen = const Color(0xFF00CFA4);
  final Color brandGradientOne = const Color(0xFF3FC2A3);
  final Color brandGradientTwo = const Color(0xFF0A5B47);

  final Color secondarygradient1 = const Color.fromARGB(255, 250, 221, 208);
  final Color secondarygradient2 = const Color.fromARGB(255, 221, 246, 255);
  final Color organgeIconLight = const Color(0xFFFF6B36);
  final Color organgeIconbg = const Color(0xFFFFF0EB);

  const NewAppColors({
    required this.brandColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textHint,
    required this.textPlaceholder,
    required this.textLink,
    required this.textInverse,
    required this.textOnBrand,
    required this.background,
    required this.surface,
    required this.divider,
    required this.border,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    this.iconPrimary = const Color(0xFF1A1A1A),
    required this.gradientOne,
    required this.gradientTwo,
    required this.badgeAttendance,
    required this.badgePoints,
    required this.badgeRank,
    required this.fieldBg,
    required this.blueIconBg,
    required this.blueIcon,
    required this.yellowIconBg,
    required this.yellowIcon,
    required this.orangeCardBg,
    required this.orangeIconBg,
    required this.orangeIcon,
    required this.attendancePresent,
    required this.attendancePresentBg,
    required this.attendanceAbsent,
    required this.attendanceAbsentBg,
    required this.attendanceLate,
    required this.attendanceLateBg,
    required this.attendanceCancelled,
    required this.attendanceCancelledBg,
    required this.attendanceTrial,
    required this.attendanceTrialBg,
    required this.purpleIcon,
    required this.purpleIconBg,
    required this.purpleTagBg,
    required this.orangeTagBg,
    required this.greenTagBg,
    required this.blueTagBg,
    required this.highPriority,
    required this.mediumPriority,
    required this.lowPriority,
  });

  static const dark = NewAppColors(
    brandColor: Color(0xFF3FC2A3),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB0B0B0),
    textTertiary: Color(0xFF808080),
    textDisabled: Color(0xFF606060),
    textHint: Color(0xFF707070),
    textPlaceholder: Color(0xFF888888),
    textLink: Color(0xFF5ED4B8),
    textInverse: Color(0xFF121212),
    textOnBrand: Color(0xFFFFFFFF),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    divider: Color(0xFF2C2C2C),
    border: Color(0xFFB0B0B0),
    error: Color(0xFFEF5350),
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFA726),
    info: Color(0xFF42A5F5),
    iconPrimary: Color(0xFFFFFFFF),
    gradientOne: Color(0xFF3FC2A3),
    gradientTwo: Color(0xFF5ED4B8),
    badgeAttendance: Color(0xFF42A5F5),
    badgePoints: Color(0xFFEF5350),
    badgeRank: Color(0xFFFDD835),
    fieldBg: Color(0xFF1E1E1E), // Dark input background
    blueIconBg: Color(0xFF0091EA),
    blueIcon: Color(0xFFFFFFFF),
    yellowIconBg: Color(0xFFFFF9C4),
    yellowIcon: Color(0xFFFBC02D),
    orangeCardBg: Color(0xFFFFCCBC),
    orangeIconBg: Color(0xFFFF7043),
    orangeIcon: Color(0xFFFFFFFF),
    attendancePresent: Color(0xFF66BB6A),
    attendancePresentBg: Color(0xFF1B5E20),
    attendanceAbsent: Color(0xFFEF5350),
    attendanceAbsentBg: Color(0xFFB71C1C),
    attendanceLate: Color(0xFFFFCA28),
    attendanceLateBg: Color(0xFFF57F17),
    attendanceCancelled: Color(0xFFFFA726),
    attendanceCancelledBg: Color(0xFFE65100),
    attendanceTrial: Color(0xFF42A5F5),
    attendanceTrialBg: Color(0xFF0D47A1),
    purpleIcon: Color(0xFFE1BEE7),
    purpleIconBg: Color(0xFF4A148C),
    purpleTagBg: Color(0xFFEDE7F6), // Light Purple
    orangeTagBg: Color(0xFFFFF3E0), // Light Orange
    greenTagBg: Color(0xFFE8F5E9), // Light Green
    blueTagBg: Color(0xFFE3F2FD), // Light Blue
    highPriority: Color(0xFFEF5350), // Red
    mediumPriority: Color(0xFFFFA726), // Orange
    lowPriority: Color(0xFF66BB6A), // Green
  );

  static const light = NewAppColors(
    brandColor: Color(0xFF1400FF),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    textTertiary: Color(0xFF94A3B8),
    textDisabled: Color(0xFFCBD5E1),
    textHint: Color(0xFF94A3B8),
    textPlaceholder: Color(0xFF94A3B8),
    textLink: Color(0xFF1400FF),
    textInverse: Color(0xFFFFFFFF),
    textOnBrand: Color(0xFFFFFFFF),
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    divider: Color(0xFFE2E8F0),
    border: Color(0xFFE2E8F0),
    error: Color(0xFFEF4444),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF1400FF),
    iconPrimary: Color(0xFF0F172A),
    gradientOne: Color(0xFF1400FF),
    gradientTwo: Color(0xFF4F46E5),
    badgeAttendance: Color(0xFF1400FF),
    badgePoints: Color(0xFFF59E0B),
    badgeRank: Color(0xFFF59E0B),
    fieldBg: Color(0xFFF8FAFC),
    blueIconBg: Color(0xFFEEF2FF),
    blueIcon: Color(0xFF1400FF),
    yellowIconBg: Color(0xFFFEF3C7),
    yellowIcon: Color(0xFFF59E0B),
    orangeCardBg: Color(0xFFFFF7ED),
    orangeIconBg: Color(0xFFFFEDD5),
    orangeIcon: Color(0xFFEA580C),
    attendancePresent: Color(0xFF10B981),
    attendancePresentBg: Color(0xFFECFDF5),
    attendanceAbsent: Color(0xFFEF4444),
    attendanceAbsentBg: Color(0xFFFEF2F2),
    attendanceLate: Color(0xFFF59E0B),
    attendanceLateBg: Color(0xFFFFFBEB),
    attendanceCancelled: Color(0xFFF97316),
    attendanceCancelledBg: Color(0xFFFFF7ED),
    attendanceTrial: Color(0xFF1400FF),
    attendanceTrialBg: Color(0xFFEEF2FF),
    purpleIcon: Color(0xFF8B5CF6),
    purpleIconBg: Color(0xFFF5F3FF),
    purpleTagBg: Color(0xFFF5F3FF),
    orangeTagBg: Color(0xFFFFF7ED),
    greenTagBg: Color(0xFFECFDF5),
    blueTagBg: Color(0xFFEEF2FF),
    highPriority: Color(0xFFEF4444),
    mediumPriority: Color(0xFFF59E0B),
    lowPriority: Color(0xFF10B981),
  );

  @override
  ThemeExtension<NewAppColors> copyWith({
    Color? brandColor,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textHint,
    Color? textPlaceholder,
    Color? textLink,
    Color? textInverse,
    Color? textOnBrand,
    Color? background,
    Color? surface,
    Color? divider,
    Color? border,
    Color? error,
    Color? success,
    Color? warning,
    Color? info,
    Color? iconPrimary,
    Color? gradientOne,
    Color? gradientTwo,
    Color? badgeAttendance,
    Color? badgePoints,
    Color? badgeRank,
    Color? fieldBg,
    Color? blueIconBg,
    Color? blueIcon,
    Color? yellowIconBg,
    Color? yellowIcon,
    Color? orangeCardBg,
    Color? orangeIconBg,
    Color? orangeIcon,
    Color? attendancePresent,
    Color? attendancePresentBg,
    Color? attendanceAbsent,
    Color? attendanceAbsentBg,
    Color? attendanceLate,
    Color? attendanceLateBg,
    Color? attendanceCancelled,
    Color? attendanceCancelledBg,
    Color? attendanceTrial,
    Color? attendanceTrialBg,
    Color? purpleIcon,
    Color? purpleIconBg,
    Color? purpleTagBg,
    Color? orangeTagBg,
    Color? greenTagBg,
    Color? blueTagBg,
    Color? highPriority,
    Color? mediumPriority,
    Color? lowPriority,
  }) {
    return NewAppColors(
      brandColor: brandColor ?? this.brandColor,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      textHint: textHint ?? this.textHint,
      textPlaceholder: textPlaceholder ?? this.textPlaceholder,
      textLink: textLink ?? this.textLink,
      textInverse: textInverse ?? this.textInverse,
      textOnBrand: textOnBrand ?? this.textOnBrand,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      divider: divider ?? this.divider,
      border: border ?? this.border,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      iconPrimary: iconPrimary ?? this.iconPrimary,
      gradientOne: gradientOne ?? this.gradientOne,
      gradientTwo: gradientTwo ?? this.gradientTwo,
      badgeAttendance: badgeAttendance ?? this.badgeAttendance,
      badgePoints: badgePoints ?? this.badgePoints,
      badgeRank: badgeRank ?? this.badgeRank,
      fieldBg: fieldBg ?? this.fieldBg,
      blueIconBg: blueIconBg ?? this.blueIconBg,
      blueIcon: blueIcon ?? this.blueIcon,
      yellowIconBg: yellowIconBg ?? this.yellowIconBg,
      yellowIcon: yellowIcon ?? this.yellowIcon,
      orangeCardBg: orangeCardBg ?? this.orangeCardBg,
      orangeIconBg: orangeIconBg ?? this.orangeIconBg,
      orangeIcon: orangeIcon ?? this.orangeIcon,
      attendancePresent: attendancePresent ?? this.attendancePresent,
      attendancePresentBg: attendancePresentBg ?? this.attendancePresentBg,
      attendanceAbsent: attendanceAbsent ?? this.attendanceAbsent,
      attendanceAbsentBg: attendanceAbsentBg ?? this.attendanceAbsentBg,
      attendanceLate: attendanceLate ?? this.attendanceLate,
      attendanceLateBg: attendanceLateBg ?? this.attendanceLateBg,
      attendanceCancelled: attendanceCancelled ?? this.attendanceCancelled,
      attendanceCancelledBg:
          attendanceCancelledBg ?? this.attendanceCancelledBg,
      attendanceTrial: attendanceTrial ?? this.attendanceTrial,
      attendanceTrialBg: attendanceTrialBg ?? this.attendanceTrialBg,
      purpleIcon: purpleIcon ?? this.purpleIcon,
      purpleIconBg: purpleIconBg ?? this.purpleIconBg,
      purpleTagBg: purpleTagBg ?? this.purpleTagBg,
      orangeTagBg: orangeTagBg ?? this.orangeTagBg,
      greenTagBg: greenTagBg ?? this.greenTagBg,
      blueTagBg: blueTagBg ?? this.blueTagBg,
      highPriority: highPriority ?? this.highPriority,
      mediumPriority: mediumPriority ?? this.mediumPriority,
      lowPriority: lowPriority ?? this.lowPriority,
    );
  }

  @override
  ThemeExtension<NewAppColors> lerp(
    ThemeExtension<NewAppColors>? other,
    double t,
  ) {
    if (other is! NewAppColors) return this;
    return NewAppColors(
      brandColor: Color.lerp(brandColor, other.brandColor, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      textPlaceholder: Color.lerp(textPlaceholder, other.textPlaceholder, t)!,
      textLink: Color.lerp(textLink, other.textLink, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      textOnBrand: Color.lerp(textOnBrand, other.textOnBrand, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      border: Color.lerp(border, other.border, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      iconPrimary: Color.lerp(iconPrimary, other.iconPrimary, t)!,
      gradientOne: Color.lerp(gradientOne, other.gradientOne, t)!,
      gradientTwo: Color.lerp(gradientTwo, other.gradientTwo, t)!,
      badgeAttendance: Color.lerp(badgeAttendance, other.badgeAttendance, t)!,
      badgePoints: Color.lerp(badgePoints, other.badgePoints, t)!,
      badgeRank: Color.lerp(badgeRank, other.badgeRank, t)!,
      fieldBg: Color.lerp(fieldBg, other.fieldBg, t)!,
      blueIconBg: Color.lerp(blueIconBg, other.blueIconBg, t)!,
      blueIcon: Color.lerp(blueIcon, other.blueIcon, t)!,
      yellowIconBg: Color.lerp(yellowIconBg, other.yellowIconBg, t)!,
      yellowIcon: Color.lerp(yellowIcon, other.yellowIcon, t)!,
      orangeCardBg: Color.lerp(orangeCardBg, other.orangeCardBg, t)!,
      orangeIconBg: Color.lerp(orangeIconBg, other.orangeIconBg, t)!,
      orangeIcon: Color.lerp(orangeIcon, other.orangeIcon, t)!,
      attendancePresent: Color.lerp(
        attendancePresent,
        other.attendancePresent,
        t,
      )!,
      attendancePresentBg: Color.lerp(
        attendancePresentBg,
        other.attendancePresentBg,
        t,
      )!,
      attendanceAbsent: Color.lerp(
        attendanceAbsent,
        other.attendanceAbsent,
        t,
      )!,
      attendanceAbsentBg: Color.lerp(
        attendanceAbsentBg,
        other.attendanceAbsentBg,
        t,
      )!,
      attendanceLate: Color.lerp(attendanceLate, other.attendanceLate, t)!,
      attendanceLateBg: Color.lerp(
        attendanceLateBg,
        other.attendanceLateBg,
        t,
      )!,
      attendanceCancelled: Color.lerp(
        attendanceCancelled,
        other.attendanceCancelled,
        t,
      )!,
      attendanceCancelledBg: Color.lerp(
        attendanceCancelledBg,
        other.attendanceCancelledBg,
        t,
      )!,
      attendanceTrial: Color.lerp(attendanceTrial, other.attendanceTrial, t)!,
      attendanceTrialBg: Color.lerp(
        attendanceTrialBg,
        other.attendanceTrialBg,
        t,
      )!,
      purpleIcon: Color.lerp(purpleIcon, other.purpleIcon, t)!,
      purpleIconBg: Color.lerp(purpleIconBg, other.purpleIconBg, t)!,
      purpleTagBg: Color.lerp(purpleTagBg, other.purpleTagBg, t)!,
      orangeTagBg: Color.lerp(orangeTagBg, other.orangeTagBg, t)!,
      greenTagBg: Color.lerp(greenTagBg, other.greenTagBg, t)!,
      blueTagBg: Color.lerp(blueTagBg, other.blueTagBg, t)!,
      highPriority: Color.lerp(highPriority, other.highPriority, t)!,
      mediumPriority: Color.lerp(mediumPriority, other.mediumPriority, t)!,
      lowPriority: Color.lerp(lowPriority, other.lowPriority, t)!,
    );
  }
}
