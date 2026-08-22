import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../floating_navbar.dart';
import '../../../../localization/app_localizations.dart';
import '../../../profile/presentation/screens/my_products_screen.dart';
import '../widgets/sell_product_step_indicator.dart';

class _C {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color mediumText = Color(0xFF334155);
  static const Color greyText = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color warningOrange = Color(0xFFF59E0B);
}

class SellProductReviewScreen extends StatelessWidget {
  const SellProductReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.offAll(() => const FloatingNavbarScreen());
      },
      child: Scaffold(
        backgroundColor: _C.scaffoldBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: AppBackButton(
              onPressed: () => Get.offAll(() => const FloatingNavbarScreen()),
              tooltip: 'Home',
            ),
          ),
          title: Text(
            l10n.text('sell_post_ad'),
            style: const TextStyle(
              color: _C.darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              tooltip: 'Home',
              icon: const Icon(Icons.home_outlined, color: _C.darkText, size: 22),
              onPressed: () => Get.offAll(() => const FloatingNavbarScreen()),
            ),
            const SizedBox(width: 4),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: _C.borderGrey),
          ),
        ),
        body: Column(
          children: [
            const SellProductStepIndicator(currentStep: 3),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Success Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _C.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _C.borderGrey),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Glowing Hero Icon Badge
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [_C.primaryBlue, Color(0xFF4F46E5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _C.primaryBlue.withValues(alpha: 0.28),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.hourglass_top_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Under Review Status Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _C.warningOrange.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: _C.warningOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'PENDING APPROVAL',
                                  style: TextStyle(
                                    color: _C.warningOrange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Title
                          Text(
                            l10n.text('sell_review_title'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _C.darkText,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Description
                          Text(
                            l10n.text('sell_review_desc'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _C.greyText,
                              fontSize: 13.5,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Divider(color: _C.borderGrey, height: 1),
                          const SizedBox(height: 16),

                          // Information Checklist
                          _buildInfoRow(
                            icon: Icons.timer_outlined,
                            text: 'Review typically completes within 24 business hours',
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow(
                            icon: Icons.notifications_active_outlined,
                            text: 'You will receive a notification when your ad is live',
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow(
                            icon: Icons.inventory_2_outlined,
                            text: 'You can manage all your listed items from My Products',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Primary Action: View My Products
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Get.off(() => const MyProductsScreen());
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'VIEW MY PRODUCTS',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Secondary Action: Go to Dashboard
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _C.darkText,
                          side: const BorderSide(color: _C.borderGrey, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Get.offAll(() => const FloatingNavbarScreen());
                        },
                        child: Text(
                          l10n.text('sell_go_dashboard'),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _C.primaryBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: _C.mediumText,
              fontSize: 12.5,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
