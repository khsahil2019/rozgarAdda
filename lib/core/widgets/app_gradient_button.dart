import 'package:flutter/material.dart';

/// Reusable Gradient Button enforcing the unified Rozgar Blue Gradient
class AppGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final bool isEnabled;
  final Gradient? gradient;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  static const Gradient defaultBlueGradient = LinearGradient(
    colors: [Color(0xFF1400FF), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  const AppGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width,
    this.height = 50,
    this.borderRadius = 14,
    this.isLoading = false,
    this.isEnabled = true,
    this.gradient,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = isEnabled && !isLoading && onPressed != null;
    final effectiveGradient = gradient ?? defaultBlueGradient;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: effectiveEnabled ? effectiveGradient : null,
        color: effectiveEnabled ? null : const Color(0xFFCBD5E1),
        boxShadow: effectiveEnabled
            ? [
                BoxShadow(
                  color: const Color(0xFF1400FF).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: effectiveEnabled ? onPressed : null,
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            text,
                            style: textStyle ??
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
