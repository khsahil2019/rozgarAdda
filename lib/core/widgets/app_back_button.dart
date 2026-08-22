import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool isDark;
  final double size;
  final double iconSize;
  final EdgeInsetsGeometry? margin;
  final String? tooltip;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.isDark = false,
    this.size = 38,
    this.iconSize = 19,
    this.margin,
    this.tooltip = 'Back',
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBg = backgroundColor ??
        (isDark
            ? Colors.black.withValues(alpha: 0.35)
            : const Color(0xFFF8FAFC));

    final Color effectiveBorder = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.25)
            : const Color(0xFFE2E8F0));

    final Color effectiveIconColor = iconColor ??
        (isDark ? Colors.white : const Color(0xFF0F172A));

    Widget button = Container(
      width: size,
      height: size,
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: effectiveBorder, width: 1.0),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ??
              () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).maybePop();
                } else {
                  Get.back();
                }
              },
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Icon(
              Icons.arrow_back_rounded,
              color: effectiveIconColor,
              size: iconSize,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
