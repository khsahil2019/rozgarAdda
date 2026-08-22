import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../localization/app_localizations.dart';
import '../controller/sell_product_controller.dart';
import '../widgets/sell_product_step_indicator.dart';
import 'sell_product_form_screen.dart';

class _C {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color greyText = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);
}

class SellProductSubCategoryScreen extends GetView<SellProductController> {
  const SellProductSubCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => Get.back(),
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
            const SellProductStepIndicator(currentStep: 2),
            Expanded(
              child: Obx(() {
                if (controller.selectedCategoryIndex.value == null) {
                  return Center(
                    child: Text(
                      l10n.text('sell_error_categories'),
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                    ),
                  );
                }

                final category = controller.categories[controller.selectedCategoryIndex.value!];

                if (controller.isLoadingSubCategories.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: _C.primaryBlue),
                  );
                }

                if (controller.subCategoriesError.value != null) {
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
                            l10n.text('sell_error_subcategories'),
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
                            onPressed: () => controller.fetchSubCategories(category.id),
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

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selected category banner card
                      _SelectedCategoryBanner(
                        categoryName: category.name,
                        onChangeTap: () => Get.back(),
                      ),
                      const SizedBox(height: 20),

                      // Section Title
                      Text(
                        l10n.text('sell_select_subcategory'),
                        style: const TextStyle(
                          color: _C.darkText,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.text('sell_subcategory_hint').replaceAll('\\n', ' '),
                        style: const TextStyle(
                          color: _C.greyText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Grid of subcategories
                      if (controller.subCategories.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.subCategories.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.95,
                          ),
                          itemBuilder: (context, i) {
                            final subCat = controller.subCategories[i];
                            return Obx(() {
                              final isSelected = controller.selectedSubCategoryIndex.value == i;

                              return GestureDetector(
                                onTap: () {
                                  controller.selectSubCategory(i);
                                  Future.delayed(const Duration(milliseconds: 180), () {
                                    if (context.mounted) {
                                      Get.to(() => const SellProductFormScreen());
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
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
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              subCat.imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                color: const Color(0xFFF1F5F9),
                                                child: const Icon(
                                                  Icons.image_outlined,
                                                  color: Color(0xFF94A3B8),
                                                  size: 36,
                                                ),
                                              ),
                                              loadingBuilder: (_, child, progress) {
                                                if (progress == null) return child;
                                                return Container(
                                                  color: const Color(0xFFF1F5F9),
                                                  child: const Center(
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: _C.primaryBlue,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            if (isSelected)
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: const BoxDecoration(
                                                    color: _C.primaryBlue,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.check_rounded,
                                                    color: Colors.white,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                                          border: Border(
                                            top: BorderSide(
                                              color: isSelected
                                                  ? _C.primaryBlue.withValues(alpha: 0.2)
                                                  : _C.borderGrey,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          subCat.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isSelected ? _C.primaryBlue : _C.darkText,
                                            fontSize: 13.5,
                                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                          },
                        ),

                      if (controller.subCategories.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _C.borderGrey),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.category_outlined, size: 42, color: _C.greyText.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              Text(
                                l10n.text('sell_no_subcategories'),
                                style: const TextStyle(
                                  color: _C.greyText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
        bottomSheet: Obx(() {
          final hasSelection = controller.selectedSubCategoryIndex.value != null;
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
                onPressed: hasSelection
                    ? () => Get.to(() => const SellProductFormScreen())
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

class _SelectedCategoryBanner extends StatelessWidget {
  final String categoryName;
  final VoidCallback onChangeTap;

  const _SelectedCategoryBanner({
    required this.categoryName,
    required this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1400FF).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1400FF).withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1400FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.folder_outlined, color: Color(0xFF1400FF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.text('sell_category'),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  categoryName,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onChangeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.text('sell_change'),
                    style: const TextStyle(
                      color: Color(0xFF1400FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit_rounded, color: Color(0xFF1400FF), size: 13),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
