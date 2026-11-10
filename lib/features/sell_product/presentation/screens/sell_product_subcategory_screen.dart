import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../localization/app_localizations.dart';
import '../controller/sell_product_controller.dart';
import '../widgets/sell_product_step_indicator.dart';
import 'sell_product_form_screen.dart';

class _C {
  static const Color primaryBlue = Color(0xFF801438);
  static const Color primaryLight = Color(0xFF9E1B46);
  static const Color darkText = Color(0xFF0F172A);
  static const Color greyText = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);
}

class SellProductSubCategoryScreen extends StatefulWidget {
  const SellProductSubCategoryScreen({super.key});

  @override
  State<SellProductSubCategoryScreen> createState() => _SellProductSubCategoryScreenState();
}

class _SellProductSubCategoryScreenState extends State<SellProductSubCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  SellProductController get controller => Get.find<SellProductController>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

                if (controller.isLoadingSubCategories.value && controller.subCategories.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: _C.primaryBlue),
                  );
                }

                if (controller.subCategoriesError.value != null && controller.subCategories.isEmpty) {
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

                final filteredSubCats = controller.subCategories.where((sub) {
                  return sub.name.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selected category banner card
                      _SelectedCategoryBanner(
                        categoryName: category.name,
                        onChangeTap: () => Get.back(),
                      ),
                      const SizedBox(height: 14),

                      // 🔍 Live Search Bar for Subcategories
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _C.primaryBlue, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: _C.primaryBlue.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val.trim()),
                          style: const TextStyle(fontSize: 13.5, color: _C.darkText, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'Search subcategories...',
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                            prefixIcon: const Icon(Icons.search_rounded, color: _C.primaryBlue, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, color: _C.greyText, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Section Title
                      Text(
                        l10n.text('sell_select_subcategory'),
                        style: const TextStyle(
                          color: _C.darkText,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select subcategory for ${category.name} (${filteredSubCats.length} options)',
                        style: const TextStyle(
                          color: _C.greyText,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Grid of subcategories
                      if (filteredSubCats.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? 'No subcategories matching "$_searchQuery"'
                                  : 'No subcategories found for this category.',
                              style: const TextStyle(
                                color: _C.greyText,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredSubCats.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.95,
                          ),
                          itemBuilder: (context, i) {
                            final subCat = filteredSubCats[i];
                            final originalIndex = controller.subCategories.indexOf(subCat);

                            return Obx(() {
                              final isSelected = controller.selectedSubCategoryIndex.value == originalIndex;

                              return GestureDetector(
                                onTap: () {
                                  controller.selectSubCategory(originalIndex);
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
                                        ? _C.primaryBlue.withValues(alpha: 0.04)
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
                                        child: Container(
                                          color: isSelected
                                              ? _C.primaryBlue.withValues(alpha: 0.08)
                                              : const Color(0xFFF8FAFC),
                                          child: subCat.imageUrl.isNotEmpty
                                              ? Image.network(
                                                  subCat.imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => Center(
                                                    child: Icon(
                                                      Icons.category_rounded,
                                                      color: isSelected ? _C.primaryBlue : _C.greyText,
                                                      size: 32,
                                                    ),
                                                  ),
                                                )
                                              : Center(
                                                  child: Icon(
                                                    Icons.category_rounded,
                                                    color: isSelected ? _C.primaryBlue : _C.greyText,
                                                    size: 32,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                        color: isSelected
                                            ? _C.primaryBlue.withValues(alpha: 0.06)
                                            : Colors.white,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                subCat.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isSelected ? _C.primaryBlue : _C.darkText,
                                                  fontSize: 13,
                                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(
                                                Icons.check_circle_rounded,
                                                color: _C.primaryBlue,
                                                size: 16,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _C.primaryBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.primaryBlue.withValues(alpha: 0.25), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _C.primaryBlue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: _C.primaryBlue, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CATEGORY',
                  style: TextStyle(
                    color: _C.greyText,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  categoryName,
                  style: const TextStyle(
                    color: _C.darkText,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChangeTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Change',
              style: TextStyle(
                color: _C.primaryBlue,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
