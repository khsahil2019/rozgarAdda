import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../localization/app_localizations.dart';
import '../controller/sell_product_controller.dart';
import 'sell_product_subcategory_screen.dart';

class _C {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color scaffoldBg = Color(0xFFF5F6FA);
  static const Color cardBg = Color(0xFFFFFFFF);
}

class SellProductCategoryScreen extends GetView<SellProductController> {
  const SellProductCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Refresh categories when this screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCategories();
    });

    return Scaffold(
      backgroundColor: _C.scaffoldBg,
      body: Column(
        children: [
          const _TopBar(),
          const _StepIndicator(currentStep: 1),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingCategories.value) {
                return const Center(
                  child: CircularProgressIndicator(color: _C.primaryBlue),
                );
              }

              if (controller.categoriesError.value != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.l10n.text('sell_error_categories'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => controller.fetchCategories(),
                          icon: const Icon(Icons.refresh),
                          label: Text(context.l10n.text('sell_retry')),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.categories.isEmpty) {
                return Center(
                  child: Text(
                    context.l10n.text('sell_no_categories'),
                    style: const TextStyle(color: _C.greyText, fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                itemCount: controller.categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: _SectionTitle(),
                    );
                  }

                  final itemIndex = index - 1;
                  final category = controller.categories[itemIndex];

                  return Obx(() {
                    final isSelected =
                        controller.selectedCategoryIndex.value == itemIndex;

                    return GestureDetector(
                      onTap: () {
                        controller.selectCategory(itemIndex);
                        Future.delayed(const Duration(milliseconds: 180), () {
                          if (context.mounted) {
                            Get.to(() => const SellProductSubCategoryScreen());
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: _C.cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? _C.primaryBlue
                                : Colors.transparent,
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE8EAFF)
                                    : const Color(0xFFEEEEF8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: category.imageUrl.isNotEmpty
                                  ? Image.network(
                                      category.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.category,
                                        color: isSelected
                                            ? _C.primaryBlue
                                            : const Color(0xFF5A6070),
                                        size: 24,
                                      ),
                                    )
                                  : Icon(
                                      Icons.category,
                                      color: isSelected
                                          ? _C.primaryBlue
                                          : const Color(0xFF5A6070),
                                      size: 24,
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  color: _C.darkText,
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: isSelected ? _C.primaryBlue : _C.greyText,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
      bottomSheet: Obx(() {
        final hasSelection = controller.selectedCategoryIndex.value != null;
        return _NextButton(
          enabled: hasSelection && controller.categories.isNotEmpty,
          onTap: hasSelection && controller.categories.isNotEmpty
              ? () => Get.to(() => const SellProductSubCategoryScreen())
              : null,
        );
      }),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.primaryBlue,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
          ),
          Expanded(
            child: Text(
              context.l10n.text('sell_post_ad'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.close, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          _StepCircle(
            number: 1,
            label: context.l10n.text('sell_category'),
            active: currentStep >= 1,
          ),
          _StepLine(active: currentStep >= 2),
          _StepCircle(
            number: 2,
            label: context.l10n.text('sell_sub_category'),
            active: currentStep >= 2,
          ),
          _StepLine(active: currentStep >= 3),
          _StepCircle(
            number: 3,
            label: context.l10n.text('sell_details'),
            active: currentStep >= 3,
          ),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int number;
  final String label;
  final bool active;

  const _StepCircle({
    required this.number,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? _C.primaryBlue : const Color(0xFFE8E8F0),
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              color: active ? Colors.white : _C.greyText,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? _C.primaryBlue : _C.greyText,
            fontSize: 9,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.only(bottom: 18),
        color: active ? _C.primaryBlue : const Color(0xFFDDDDEE),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.text('sell_choose_category'),
          style: const TextStyle(
            color: _C.primaryBlue,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: _C.yellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;

  const _NextButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        22,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: enabled
                ? _C.primaryBlue
                : const Color.fromARGB(255, 169, 161, 252),
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            context.l10n.text('sell_next'),
            style: const TextStyle(
              color: _C.cardBg,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
