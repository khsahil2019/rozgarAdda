import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/buy_product_controller.dart';
import '../theme/buy_product_theme.dart';
import '../widgets/marketplace_product_card.dart';
import '../widgets/marketplace_search_bar.dart';
import '../../../../core/widgets/fast_loader.dart';
import '../../../wishlist/presentation/controller/wishlist_controller.dart';
import '../../../wishlist/presentation/screens/wishlist_screen.dart';

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class ProductListScreen extends StatefulWidget {
  final String? title;
  final int? categoryId;
  final int? subcategoryId;
  final String? initialSearchQuery;

  const ProductListScreen({
    super.key,
    this.title,
    this.categoryId,
    this.subcategoryId,
    this.initialSearchQuery,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final BuyProductController controller = Get.find<BuyProductController>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
      _searchController.text = widget.initialSearchQuery!;
      _searchQuery = widget.initialSearchQuery!.trim().toLowerCase();
    }

    _searchController.addListener(() {
      final text = _searchController.text.trim().toLowerCase();
      if (text != _searchQuery) {
        setState(() => _searchQuery = text);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize filter state and fetch products + subcategories
      controller.selectedSubCategoryId.value = widget.subcategoryId;
      controller.fetchProducts(widget.categoryId, widget.subcategoryId);
      if (widget.categoryId != null) {
        controller.fetchSubCategories(widget.categoryId!);
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
    return Scaffold(
      backgroundColor: BuyProductTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 58,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 7, bottom: 7),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: BuyProductTheme.scaffoldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BuyProductTheme.subtleBorder, width: 1),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: BuyProductTheme.darkText,
                  size: 17,
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title ?? 'Buy Products',
              style: const TextStyle(
                color: BuyProductTheme.darkText,
                fontWeight: FontWeight.w800,
                fontSize: 17,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Obx(() => Text(
                  '${controller.products.length} Products Available',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: BuyProductTheme.greyText,
                  ),
                )),
          ],
        ),
        actions: [
          Obx(() {
            final count = WishlistController.to.itemCount;
            return IconButton(
              tooltip: 'Wishlist',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WishlistScreen()),
                );
              },
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BuyProductTheme.scaffoldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: BuyProductTheme.subtleBorder, width: 1),
                    ),
                    child: const Icon(
                      Icons.favorite_outline_rounded,
                      color: BuyProductTheme.primaryMaroon,
                      size: 18,
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: BuyProductTheme.subtleBorder, height: 1),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Interactive Search Bar (Wine-Maroon theme styled)
          _buildSearchBar(),

          // 🎛️ Subcategory Filter Chips
          if (widget.categoryId != null) _buildFilterChips(),

          // 📦 Main Feed (3 Items Per Row Grid with Maroon Border)
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: MarketplaceSearchBar(
        controller: _searchController,
        hintText: 'Search in ${widget.title ?? "cars, phones, items"}...',
        searchQuery: _searchQuery,
        onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
        onClear: () {
          _searchController.clear();
          setState(() => _searchQuery = '');
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() {
      if (controller.isLoadingSubCategories.value && controller.subCategories.isEmpty) {
        return const SizedBox(
          height: 46,
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: BuyProductTheme.primaryMaroon),
            ),
          ),
        );
      }

      if (controller.subCategories.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        color: Colors.white,
        height: 46,
        padding: const EdgeInsets.only(bottom: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: controller.subCategories.length + 1,
          itemBuilder: (context, index) {
            final isAll = index == 0;
            final isSelected = isAll
                ? controller.selectedSubCategoryId.value == null
                : controller.selectedSubCategoryId.value ==
                    controller.subCategories[index - 1].id;

            final label = isAll ? 'All' : controller.subCategories[index - 1].name;
            final subId = isAll ? null : controller.subCategories[index - 1].id;

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(label),
                selected: isSelected,
                labelStyle: TextStyle(
                  color: isSelected ? BuyProductTheme.primaryMaroon : const Color(0xFF334155),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 11.5,
                ),
                selectedColor: BuyProductTheme.chipMaroonBg,
                backgroundColor: BuyProductTheme.scaffoldBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? BuyProductTheme.borderMaroon : BuyProductTheme.subtleBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                onSelected: (selected) {
                  if (selected) {
                    controller.selectSubCategoryFilter(widget.categoryId, subId);
                  }
                },
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoadingProducts.value) {
        return const Padding(
          padding: EdgeInsets.all(12.0),
          child: FastGridSkeleton(itemCount: 9),
        );
      }

      if (controller.productsError.value != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 52,
                  color: BuyProductTheme.lightGreyText,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.productsError.value!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: BuyProductTheme.greyText, fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => controller.fetchProducts(
                    widget.categoryId,
                    controller.selectedSubCategoryId.value,
                  ),
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

      if (controller.products.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 52, color: BuyProductTheme.lightGreyText),
                SizedBox(height: 12),
                Text(
                  'No products available in this category.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: BuyProductTheme.greyText, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }

      // Filter products based on active search query
      final filteredList = controller.products.where((p) {
        if (_searchQuery.isEmpty) return true;
        final q = _searchQuery.toLowerCase();
        final titleMatch = p.title.toLowerCase().contains(q);
        final descMatch = p.description.toLowerCase().contains(q);
        final featuresMatch = p.features.toLowerCase().contains(q);
        final priceMatch = p.price.toString().contains(q) || p.totalCost.toString().contains(q);
        return titleMatch || descMatch || featuresMatch || priceMatch;
      }).toList();

      if (filteredList.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off_rounded, size: 52, color: BuyProductTheme.lightGreyText),
                const SizedBox(height: 12),
                Text(
                  'No products matching "$_searchQuery"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: BuyProductTheme.greyText, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: const Icon(Icons.refresh_rounded, color: BuyProductTheme.primaryMaroon),
                  label: const Text(
                    'Clear Search',
                    style: TextStyle(color: BuyProductTheme.primaryMaroon, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        color: BuyProductTheme.primaryMaroon,
        onRefresh: () => controller.fetchProducts(
          widget.categoryId,
          controller.selectedSubCategoryId.value,
        ),
        child: Column(
          children: [
            if (_searchQuery.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                color: BuyProductTheme.lightMaroonBg,
                child: Text(
                  'Showing ${filteredList.length} results for "$_searchQuery"',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: BuyProductTheme.primaryMaroon,
                  ),
                ),
              ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
                itemCount: filteredList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (widget.title?.toLowerCase().contains('recommended') == true) ? 2 : 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: (widget.title?.toLowerCase().contains('recommended') == true) ? 0.72 : 0.58,
                ),
                itemBuilder: (context, i) =>
                    MarketplaceProductCard(product: filteredList[i]),
              ),
            ),
          ],
        ),
      );
    });
  }
}
