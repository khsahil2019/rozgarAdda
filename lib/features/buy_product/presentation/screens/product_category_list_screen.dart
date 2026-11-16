import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/widgets/network_image_service.dart';
import 'package:rojgar/features/app/app_controller.dart';
import '../../domain/entities/buy_product_entities.dart';
import '../bindings/buy_product_binding.dart';
import '../controller/buy_product_controller.dart';
import '../theme/buy_product_theme.dart';
import '../widgets/marketplace_product_card.dart';
import '../widgets/marketplace_search_bar.dart';
import 'product_list_screen.dart';
import 'product_subcategory_selection_screen.dart';
import '../../../sell_product/presentation/screens/sell_product_category_screen.dart';

class ProductCategoryListScreen extends StatefulWidget {
  const ProductCategoryListScreen({super.key});

  @override
  State<ProductCategoryListScreen> createState() => _ProductCategoryListScreenState();
}

class _ProductCategoryListScreenState extends State<ProductCategoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  BuyProductController get controller {
    if (!Get.isRegistered<BuyProductController>()) {
      BuyProductBinding().dependencies();
    }
    return Get.find<BuyProductController>();
  }

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<BuyProductController>()) {
      BuyProductBinding().dependencies();
    }
    controller.fetchCategories();
    controller.fetchRecommendedProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  IconData _getTimeIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 18) {
      return Icons.wb_sunny_rounded;
    }
    return Icons.nights_stay_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BuyProductTheme.scaffoldBg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: BuyProductTheme.primaryMaroon,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        onPressed: () => Get.to(() => const SellProductCategoryScreen()),
        icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Sell Product',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingCategories.value && controller.categories.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: BuyProductTheme.primaryMaroon),
          );
        }

        if (controller.categoriesError.value != null && controller.categories.isEmpty) {
          return _buildErrorState(
            controller.categoriesError.value!,
            () {
              controller.fetchCategories();
              controller.fetchRecommendedProducts(forceRefresh: true);
            },
          );
        }

        final q = _searchQuery.toLowerCase();
        final filteredCategories = controller.categories.where((cat) {
          return cat.name.toLowerCase().contains(q);
        }).toList();

        final filteredRecommended = controller.recommendedProducts.where((p) {
          if (q.isEmpty) return true;
          return p.title.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q) ||
              p.features.toLowerCase().contains(q) ||
              p.price.toString().contains(q) ||
              p.totalCost.toString().contains(q);
        }).toList();

        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              controller.fetchCategories(),
              controller.fetchRecommendedProducts(forceRefresh: true),
            ]);
          },
          color: BuyProductTheme.primaryMaroon,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header Area Styled Like Reference Image ──
              SliverToBoxAdapter(
                child: _buildHeaderSection(context),
              ),

              // ── Search Bar with Uniform 4-Side Reddish Maroon Border ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: MarketplaceSearchBar(
                    controller: _searchController,
                    hintText: 'Search cars, phones, property, goods...',
                    searchQuery: _searchQuery,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    onSubmitted: (query) {
                      if (query.trim().isNotEmpty) {
                        Get.to(() => ProductListScreen(
                              title: 'Search: "${query.trim()}"',
                              initialSearchQuery: query.trim(),
                            ));
                      }
                    },
                    onClear: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                ),
              ),

              // ── If Search Query is active, show Direct Product Search Option ──
              if (_searchQuery.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _buildDirectProductSearchAction(),
                  ),
                ),

              // ── Safety Tips Banner (Matching Reference Image) ──
              if (_searchQuery.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
                    child: _buildSafetyTipsBanner(),
                  ),
                ),

              // ── Section Title: Popular Categories ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Popular Categories',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
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
                          '${filteredCategories.length} Categories',
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
              ),

              // ── Compact Categories Grid (4 Columns, Smaller Size) ──
              if (filteredCategories.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 36, color: BuyProductTheme.lightGreyText),
                          const SizedBox(height: 8),
                          Text(
                            'No categories matching "$_searchQuery"',
                            style: const TextStyle(color: BuyProductTheme.greyText, fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 82,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = filteredCategories[index];
                        return _CategoryGridItem(
                          category: category,
                          onTap: () {
                            Get.to(
                              () => ProductSubCategorySelectionScreen(
                                categoryName: category.name,
                                categoryId: category.id,
                              ),
                            );
                          },
                        );
                      },
                      childCount: filteredCategories.length,
                    ),
                  ),
                ),

              // ── Section Title: Recommended Items (Right Below Categories) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Recommended Items',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: BuyProductTheme.darkText,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Get.to(
                          () => ProductListScreen(
                            title: 'Recommended Items',
                            initialSearchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: BuyProductTheme.chipMaroonBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: BuyProductTheme.borderMaroon.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                filteredRecommended.isNotEmpty
                                    ? 'See All (${filteredRecommended.length})'
                                    : 'See All',
                                style: const TextStyle(
                                  color: BuyProductTheme.primaryMaroon,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: BuyProductTheme.primaryMaroon,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Recommended Items Grid (2 Items Per Row, Bold Borders) ──
              if (controller.isLoadingRecommended.value && filteredRecommended.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: BuyProductTheme.primaryMaroon,
                        ),
                      ),
                    ),
                  ),
                )
              else if (filteredRecommended.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: BuyProductTheme.borderMaroon.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 32,
                            color: BuyProductTheme.lightGreyText,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No recommended items matching "$_searchQuery"'
                                : 'No recommended items available right now.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: BuyProductTheme.greyText,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => MarketplaceProductCard(
                        product: filteredRecommended[index],
                      ),
                      childCount: filteredRecommended.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  // ── Header Section with Dark Maroon Gradient & Rozgar Adda badge ──
  Widget _buildHeaderSection(BuildContext context) {
    final locationName = AppController.to.selectedStateName ?? 'Madhoganj';

    return Container(
      decoration: const BoxDecoration(
        gradient: BuyProductTheme.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Back button & Rozgar Adda logo badge (Notification bell removed)
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                ),
                onPressed: () => Navigator.maybePop(context),
              ),
              const SizedBox(width: 12),
              // Rozgar Adda Brand Badge
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: BuyProductTheme.primaryMaroon,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 14),
                      SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'ROZGAR ADDA',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Greeting row (e.g. 🌙 Good Morning)
          Row(
            children: [
              Icon(
                _getTimeIcon(),
                color: BuyProductTheme.goldAccent,
                size: 15,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _getTimeGreeting(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),

          // Location Row (📍 Madhoganj)
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  locationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white70,
                size: 19,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Direct Product Search Action Tile ──
  Widget _buildDirectProductSearchAction() {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductListScreen(
              title: 'Search: "$_searchQuery"',
              initialSearchQuery: _searchQuery,
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: BuyProductTheme.chipMaroonBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BuyProductTheme.borderMaroon, width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.travel_explore_rounded, color: BuyProductTheme.primaryMaroon, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Search all products for "$_searchQuery"',
                style: const TextStyle(
                  color: BuyProductTheme.primaryMaroon,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: BuyProductTheme.primaryMaroon, size: 16),
          ],
        ),
      ),
    );
  }

  // ── Safety Tips Banner (STAY SAFE! from Reference Image) ──
  Widget _buildSafetyTipsBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B1726), Color(0xFF330913)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'STAY ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(Icons.verified_user_rounded, color: Color(0xFF60A5FA), size: 17),
                Text(
                  ' SAFE!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Safety Tips for Marketplace Users',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTipCard(
                  icon: Icons.people_outline_rounded,
                  title: '1. MEET IN PUBLIC',
                  desc: 'Choose busy, well-lit public places.',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTipCard(
                  icon: Icons.find_in_page_outlined,
                  title: '2. INSPECT ITEM',
                  desc: 'Check item thoroughly before paying.',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTipCard(
                  icon: Icons.money_off_rounded,
                  title: '3. NO ADVANCE',
                  desc: 'Never send deposits before meeting.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: BuyProductTheme.primaryMaroon, size: 18),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: BuyProductTheme.darkText,
              fontWeight: FontWeight.w800,
              fontSize: 8.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: BuyProductTheme.greyText,
              fontSize: 7.5,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: BuyProductTheme.lightGreyText),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: BuyProductTheme.greyText, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: BuyProductTheme.primaryMaroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// COMPACT CATEGORY GRID ITEM (4 PER ROW WITH BOLD MAROON BORDER)
// ─────────────────────────────────────────────
class _CategoryGridItem extends StatelessWidget {
  final BuyProductCategory category;
  final VoidCallback onTap;

  const _CategoryGridItem({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: BuyProductTheme.primaryMaroon.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: BuyProductTheme.borderMaroon,
            width: 1.8,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Compact Category Image Area
            Expanded(
              child: Container(
                color: BuyProductTheme.lightMaroonBg,
                child: category.imageUrl.isNotEmpty
                    ? NetworkImageService(
                        imageUrl: ApiRoutes.absoluteUrl(category.imageUrl),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: _buildCategoryIconFallback(),
                      )
                    : _buildCategoryIconFallback(),
              ),
            ),

            // Compact Category Title Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              color: Colors.white,
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: BuyProductTheme.darkText,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIconFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: BuyProductTheme.categoryCardGradient,
      ),
      child: Center(
        child: Icon(
          _guessCategoryIcon(category.name),
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
