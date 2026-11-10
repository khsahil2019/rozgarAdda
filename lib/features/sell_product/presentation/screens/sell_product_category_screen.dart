import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../localization/app_localizations.dart';
import '../bindings/sell_product_binding.dart';
import '../controller/sell_product_controller.dart';
import '../widgets/sell_product_step_indicator.dart';
import 'sell_product_subcategory_screen.dart';

class _C {
  static const Color primaryBlue = Color(0xFF801438); // Aligned with marketplace theme
  static const Color primaryLight = Color(0xFF9E1B46);
  static const Color darkText = Color(0xFF0F172A);
  static const Color greyText = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);
}

class SellProductCategoryScreen extends StatefulWidget {
  const SellProductCategoryScreen({super.key});

  @override
  State<SellProductCategoryScreen> createState() => _SellProductCategoryScreenState();
}

class _SellProductCategoryScreenState extends State<SellProductCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  SellProductController get controller {
    if (!Get.isRegistered<SellProductController>()) {
      SellProductBinding().dependencies();
    }
    return Get.find<SellProductController>();
  }

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SellProductController>()) {
      SellProductBinding().dependencies();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.categories.isEmpty && !controller.isLoadingCategories.value) {
        controller.fetchCategories();
      }
    });
  }

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

            // 🔍 Live Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
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
                    hintText: 'Search categories (e.g. Mobile, Cars)...',
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
            ),

            Expanded(
              child: Obx(() {
                if (controller.isLoadingCategories.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: _C.primaryBlue),
                  );
                }

                if (controller.categoriesError.value != null && controller.categories.isEmpty) {
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

                final filteredList = controller.categories.where((cat) {
                  return cat.name.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: _C.greyText.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No categories matching "$_searchQuery"'
                              : l10n.text('sell_no_categories'),
                          style: const TextStyle(color: _C.greyText, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: filteredList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.text('sell_choose_category'),
                              style: const TextStyle(
                                color: _C.darkText,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Select the category that best matches your product (${filteredList.length} options)',
                              style: const TextStyle(
                                color: _C.greyText,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final catItem = filteredList[index - 1];
                    final originalIndex = controller.categories.indexOf(catItem);

                    return Obx(() {
                      final isSelected = controller.selectedCategoryIndex.value == originalIndex;

                      return GestureDetector(
                        onTap: () {
                          controller.selectCategory(originalIndex);
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
                                ? _C.primaryBlue.withValues(alpha: 0.05)
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
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _C.primaryBlue.withValues(alpha: 0.12)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: catItem.imageUrl.isNotEmpty
                                    ? Image.network(
                                        catItem.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.category_rounded,
                                          color: isSelected ? _C.primaryBlue : _C.greyText,
                                          size: 22,
                                        ),
                                      )
                                    : Icon(
                                        Icons.category_rounded,
                                        color: isSelected ? _C.primaryBlue : _C.greyText,
                                        size: 22,
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  catItem.name,
                                  style: TextStyle(
                                    color: isSelected ? _C.primaryBlue : _C.darkText,
                                    fontSize: 14.5,
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
      ),
    );
  }
}
