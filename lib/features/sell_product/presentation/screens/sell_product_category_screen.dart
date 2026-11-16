import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/network_image_service.dart';
import '../../../../localization/app_localizations.dart';
import '../../../buy_product/presentation/theme/buy_product_theme.dart';
import '../../../buy_product/presentation/widgets/marketplace_search_bar.dart';
import '../bindings/sell_product_binding.dart';
import '../controller/sell_product_controller.dart';
import '../widgets/sell_product_step_indicator.dart';
import 'sell_product_subcategory_screen.dart';

class _C {
  static const Color primaryBlue = Color(0xFF801438); // Aligned with marketplace theme
  static const Color darkText = Color(0xFF0F172A);
  static const Color greyText = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color scaffoldBg = Color(0xFFF8FAFC);
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

            // 🔍 Live Search Bar with 4-Side Reddish Border
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: MarketplaceSearchBar(
                controller: _searchController,
                hintText: 'Search categories (e.g. Mobile, Cars)...',
                searchQuery: _searchQuery,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                onClear: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
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

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Category Header: Choose Category & Count Chip ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              l10n.text('sell_choose_category'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: BuyProductTheme.darkText,
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: BuyProductTheme.chipMaroonBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${filteredList.length} Categories',
                              style: const TextStyle(
                                color: BuyProductTheme.primaryMaroon,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Category Grid (Matching Buy Product Style) ──
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                        itemCount: filteredList.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          mainAxisExtent: 84,
                        ),
                        itemBuilder: (context, index) {
                          final catItem = filteredList[index];
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
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: BuyProductTheme.primaryMaroon.withValues(alpha: isSelected ? 0.16 : 0.08),
                                      blurRadius: isSelected ? 8 : 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                foregroundDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? BuyProductTheme.primaryMaroon
                                        : BuyProductTheme.borderMaroon,
                                    width: isSelected ? 2.2 : 1.8,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Category Image
                                        Expanded(
                                          child: Container(
                                            color: BuyProductTheme.lightMaroonBg,
                                            child: catItem.imageUrl.isNotEmpty
                                                ? NetworkImageService(
                                                    imageUrl: ApiRoutes.absoluteUrl(catItem.imageUrl),
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorWidget: _buildCategoryIconFallback(catItem.name),
                                                  )
                                                : _buildCategoryIconFallback(catItem.name),
                                          ),
                                        ),

                                        // Category Title
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                          color: isSelected ? BuyProductTheme.chipMaroonBg : Colors.white,
                                          child: Text(
                                            catItem.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? BuyProductTheme.primaryMaroon
                                                  : BuyProductTheme.darkText,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Container(
                                          padding: const EdgeInsets.all(2.5),
                                          decoration: const BoxDecoration(
                                            color: BuyProductTheme.primaryMaroon,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 10,
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
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIconFallback(String name) {
    return Container(
      decoration: const BoxDecoration(
        gradient: BuyProductTheme.categoryCardGradient,
      ),
      child: Center(
        child: Icon(
          _guessCategoryIcon(name),
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  IconData _guessCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('car') || lower.contains('vehicle') || lower.contains('auto')) {
      return Icons.directions_car_rounded;
    }
    if (lower.contains('phone') || lower.contains('mobile')) {
      return Icons.phone_android_rounded;
    }
    if (lower.contains('cloth') || lower.contains('fashion')) {
      return Icons.checkroom_rounded;
    }
    if (lower.contains('electronic') || lower.contains('gadget')) {
      return Icons.headphones_rounded;
    }
    if (lower.contains('furnitur') || lower.contains('home')) {
      return Icons.chair_rounded;
    }
    if (lower.contains('propert') || lower.contains('real') || lower.contains('house')) {
      return Icons.apartment_rounded;
    }
    if (lower.contains('job')) {
      return Icons.business_center_rounded;
    }
    if (lower.contains('health') || lower.contains('beauty')) {
      return Icons.healing_rounded;
    }
    if (lower.contains('book') || lower.contains('stationery')) {
      return Icons.menu_book_rounded;
    }
    if (lower.contains('pet') || lower.contains('animal')) {
      return Icons.pets_rounded;
    }
    return Icons.category_rounded;
  }
}
