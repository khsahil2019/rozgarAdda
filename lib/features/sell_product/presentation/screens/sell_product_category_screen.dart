import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../localization/app_localizations.dart';
import '../bindings/sell_product_binding.dart';
import '../controller/sell_product_controller.dart';
import '../widgets/sell_product_step_indicator.dart';
import 'sell_product_subcategory_screen.dart';

class _C {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color greyText = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);
}

class SellProductCategoryScreen extends GetView<SellProductController> {
  const SellProductCategoryScreen({super.key});

  @override
  SellProductController get controller {
    if (!Get.isRegistered<SellProductController>()) {
      SellProductBinding().dependencies();
    }
    return Get.find<SellProductController>();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SellProductController>()) {
      SellProductBinding().dependencies();
    }
    // Refresh categories when this screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCategories();
    });

    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
        backgroundColor: _C.scaffoldBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: AppBackButton(
              onPressed: () => Navigator.maybePop(context),
              tooltip: 'Back',
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
              tooltip: 'Cancel',
              icon: const Icon(Icons.close_rounded, color: _C.greyText, size: 22),
              onPressed: () => Navigator.maybePop(context),
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
            const SellProductStepIndicator(currentStep: 1),
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
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFEF4444),
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.text('sell_error_categories'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _C.darkText,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _C.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onPressed: () => controller.fetchCategories(),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(
                              l10n.text('sell_retry'),
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: _C.greyText.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          l10n.text('sell_no_categories'),
                          style: const TextStyle(color: _C.greyText, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  itemCount: controller.categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.text('sell_choose_category'),
                              style: const TextStyle(
                                color: _C.darkText,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Select the category that best matches your product',
                              style: TextStyle(
                                color: _C.greyText,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final itemIndex = index - 1;
                    final category = controller.categories[itemIndex];

                    return Obx(() {
                      final isSelected = controller.selectedCategoryIndex.value == itemIndex;

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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1400FF).withValues(alpha: 0.04)
                                : _C.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? _C.primaryBlue : _C.borderGrey,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: isSelected ? 0.06 : 0.02),
                                blurRadius: isSelected ? 12 : 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF1400FF).withValues(alpha: 0.12)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: category.imageUrl.isNotEmpty
                                    ? Image.network(
                                        category.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.category_rounded,
                                          color: isSelected ? _C.primaryBlue : _C.greyText,
                                          size: 24,
                                        ),
                                      )
                                    : Icon(
                                        Icons.category_rounded,
                                        color: isSelected ? _C.primaryBlue : _C.greyText,
                                        size: 24,
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    color: isSelected ? _C.primaryBlue : _C.darkText,
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? _C.primaryBlue : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? _C.primaryBlue : _C.borderGrey,
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                    : const Icon(Icons.chevron_right_rounded, color: _C.greyText, size: 18),
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
          return Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).padding.bottom + 14,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: _C.borderGrey, width: 1),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSelection ? _C.primaryBlue : const Color(0xFFCBD5E1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: hasSelection && controller.categories.isNotEmpty
                    ? () => Get.to(() => const SellProductSubCategoryScreen())
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.text('sell_next'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
