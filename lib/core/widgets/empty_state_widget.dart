import 'package:flutter/material.dart';

/// Modern, visually engaging Empty State Screen widget.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final Color primaryColor;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.work_off_rounded,
    required this.title,
    required this.subtitle,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.primaryColor = const Color(0xFF4F46E5),
  });

  /// Factory constructor specifically tailored for "No Jobs Found".
  factory EmptyStateWidget.noJobsFound({
    String? title,
    String? subtitle,
    VoidCallback? onResetFilters,
    VoidCallback? onExploreCategories,
  }) {
    return EmptyStateWidget(
      icon: Icons.search_off_rounded,
      title: title ?? 'No Jobs Found Right Now',
      subtitle: subtitle ??
          'We couldn\'t find any openings matching your selected filters. Try resetting filters or exploring other categories.',
      primaryButtonText: 'Reset Filters',
      onPrimaryPressed: onResetFilters,
      secondaryButtonText: onExploreCategories != null ? 'Explore Categories' : null,
      onSecondaryPressed: onExploreCategories,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Glowing Icon Hub ──────────────────────────────────────
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.08),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.18),
                        primaryColor.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.15),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: primaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Title & Subtitle ─────────────────────────────────────
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            // ── Action Buttons ───────────────────────────────────────
            if (primaryButtonText != null && onPrimaryPressed != null) ...[
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 260),
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      Color.lerp(primaryColor, Colors.white, 0.15)!,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: onPrimaryPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    primaryButtonText!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],

            if (secondaryButtonText != null && onSecondaryPressed != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 260),
                height: 44,
                child: TextButton.icon(
                  onPressed: onSecondaryPressed,
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: primaryColor.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                    ),
                  ),
                  icon: Icon(
                    Icons.explore_outlined,
                    size: 18,
                    color: primaryColor,
                  ),
                  label: Text(
                    secondaryButtonText!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
