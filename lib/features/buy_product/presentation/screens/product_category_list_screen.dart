import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/widgets/network_image_service.dart';
import 'package:rojgar/features/app/app_controller.dart';
import '../../domain/entities/buy_product_entities.dart';
import '../bindings/buy_product_binding.dart';
import '../controller/buy_product_controller.dart';
import '../theme/buy_product_theme.dart';
import 'product_list_screen.dart';
import 'product_subcategory_selection_screen.dart';

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
      body: Obx(() {
        if (controller.isLoadingCategories.value && controller.categories.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: BuyProductTheme.primaryMaroon),
          );
        }

        if (controller.categoriesError.value != null && controller.categories.isEmpty) {
          return _buildErrorState(
            controller.categoriesError.value!,
            controller.fetchCategories,
          );
        }

        final filteredCategories = controller.categories.where((cat) {
          return cat.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return RefreshIndicator(
          onRefresh: controller.fetchCategories,
          color: BuyProductTheme.primaryMaroon,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header Area Styled Like Reference Image ──
              SliverToBoxAdapter(
                child: _buildHeaderSection(context),
              ),

              // ── Search Bar Positioned Over Header / Body ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: _buildSearchBar(),
                ),
              ),

              // ── If Search Query is active, show Direct Product Search Option ──
              if (_searchQuery.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: _buildDirectProductSearchAction(),
                  ),
                ),

              // ── Safety Tips Banner (Matching Reference Image) ──
              if (_searchQuery.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
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
                      const Text(
                        'Popular Categories',
                        style: TextStyle(
                          color: BuyProductTheme.darkText,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: BuyProductTheme.chipMaroonBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${filteredCategories.length} Categories',
                          style: const TextStyle(
                            color: BuyProductTheme.primaryMaroon,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Categories Grid (EXACTLY 3 ITEMS PER ROW) ──
              if (filteredCategories.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 48, color: BuyProductTheme.lightGreyText),
                          const SizedBox(height: 10),
                          Text(
                            'No categories matching "$_searchQuery"',
                            style: const TextStyle(color: BuyProductTheme.greyText, fontSize: 13.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // EXACTLY 3 ITEMS PER ROW
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.82,
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
            ],
          ),
        );
      }),
    );
  }

  // ── Header Section with Dark Maroon Gradient & Old Qart badge ──
  Widget _buildHeaderSection(BuildContext context) {
    final locationName = AppController.to.selectedStateName ?? 'Madhoganj';

    return Container(
      decoration: const BoxDecoration(
        gradient: BuyProductTheme.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Back button, Old Qart logo badge, notification icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                  // OLD QART Brand Badge
                  Container(
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
                        Text(
                          'OLD QART',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Right: Notification Bell button
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Greeting row (e.g. 🌙 Good Night)
          Row(
            children: [
              Icon(
                _getTimeIcon(),
                color: BuyProductTheme.goldAccent,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                _getTimeGreeting(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Location Row (📍 Madhoganj ⌵)
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                locationName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white70,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Working Search Bar with Maroon Border & Rounded Corners ──
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: BuyProductTheme.borderMaroon,
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: BuyProductTheme.primaryMaroon.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val.trim()),
        onSubmitted: (query) {
          if (query.trim().isNotEmpty) {
            Get.to(() => ProductListScreen(
                  title: 'Search: "${query.trim()}"',
                  initialSearchQuery: query.trim(),
                ));
          }
        },
        style: const TextStyle(
          color: BuyProductTheme.darkText,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Search cars, phones, property, goods...',
          hintStyle: const TextStyle(
            color: BuyProductTheme.lightGreyText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: BuyProductTheme.primaryMaroon,
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: BuyProductTheme.greyText, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        ),
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
          Row(
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
// CATEGORY GRID ITEM (3 PER ROW WITH MAROON BORDER)
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
          borderRadius: BorderRadius.circular(16),
          // User requested: "use the product in boder of same color"
          border: Border.all(
            color: BuyProductTheme.borderMaroon,
            width: 1.25,
          ),
          boxShadow: [
            BoxShadow(
              color: BuyProductTheme.primaryMaroon.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Icon / Image Area
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
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
            ),

            // Category Title Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
              ),
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: BuyProductTheme.darkText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
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
          size: 28,
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
