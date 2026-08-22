import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import 'package:rojgar/features/app/app_controller.dart';
import 'package:rojgar/localization/app_localizations.dart';
import '../../domain/entities/news_category.dart';
import '../../domain/entities/news_item.dart';
import '../bindings/news_binding.dart';
import '../controller/news_controller.dart';
import 'create_news_screen.dart';
import 'news_detail_screen.dart';
import 'local_video_player_screen.dart';

// Unified Rozgar Brand Color Palette
class _NC {
  static const Color primary = Color(0xFF1400FF);
  static const Color primarySoft = Color(0xFFEEF2FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color mediumText = Color(0xFF334155);
  static const Color greyText = Color(0xFF64748B);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color fieldBg = Color(0xFFF1F5F9);
  static const Color borderGrey = Color(0xFFE2E8F0);
}

class NewsScreen extends GetView<NewsController> {
  final bool showBackButton;

  const NewsScreen({super.key, this.showBackButton = true});

  @override
  NewsController get controller {
    if (!Get.isRegistered<NewsController>()) {
      NewsBinding().dependencies();
    }
    return Get.find<NewsController>();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NewsController>()) {
      NewsBinding().dependencies();
    }
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
        backgroundColor: _NC.bg,
        drawer: _NewsCategoryDrawer(controller: controller, hostContext: context),
        floatingActionButton: _buildCreateButton(context, l10n),
        appBar: _buildAppBar(context, l10n),
        body: Column(
          children: [
            // Feed Format Tabs (All News / Articles / Videos)
            _buildTabSelector(context, l10n),

            // Quick Category Horizontal Scroll Bar
            _buildQuickCategoryBar(context),

            // News Feed List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoadingState();
                }

                if (controller.errorMessage.isNotEmpty) {
                  return _buildErrorState(l10n);
                }

                final List<NewsItem> currentList = controller.currentList;

                return RefreshIndicator(
                  onRefresh: () => controller.fetchNews(),
                  color: _NC.primary,
                  child: currentList.isEmpty
                      ? _buildEmptyState(context, l10n)
                      : NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification.metrics.pixels >=
                                notification.metrics.maxScrollExtent - 240) {
                              controller.loadMore();
                            }
                            return false;
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 95),
                            itemCount: currentList.length + 1,
                            itemBuilder: (ctx, index) {
                              if (index == currentList.length) {
                                return _buildListFooter();
                              }
                              return _buildNewsCard(
                                context,
                                currentList[index],
                              );
                            },
                          ),
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Professional App Bar (Fully Overflow Protected) ─────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: showBackButton ? 0 : 16,
      leading: showBackButton
          ? Center(
              child: AppBackButton(
                onPressed: () => Navigator.maybePop(context),
                tooltip: 'Back',
              ),
            )
          : Builder(
              builder: (innerContext) => Container(
                margin: const EdgeInsets.only(left: 12),
                child: IconButton(
                  onPressed: () => Scaffold.of(innerContext).openDrawer(),
                  icon: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: _NC.fieldBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _NC.borderGrey),
                    ),
                    child: const Icon(Icons.menu_rounded, color: _NC.darkText, size: 20),
                  ),
                  tooltip: l10n.text('news_categories'),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Rozgar ',
                        style: TextStyle(
                          color: _NC.darkText,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: -0.4,
                        ),
                      ),
                      TextSpan(
                        text: 'News',
                        style: TextStyle(
                          color: _NC.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 2.5, backgroundColor: Color(0xFFEF4444)),
                    SizedBox(width: 3),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          const Text(
            'Daily Updates & Headlines',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _NC.greyText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        // State Selector Action Pill
        Builder(
          builder: (innerContext) => Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Material(
              color: _NC.primarySoft,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => _showStatePicker(context, controller, l10n),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.place_rounded, color: _NC.primary, size: 14),
                      const SizedBox(width: 3),
                      Obx(() {
                        final state = controller.selectedState;
                        return ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 80),
                          child: Text(
                            state?.name ?? l10n.text('news_state'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _NC.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: _NC.primary, size: 14),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Filter / Category Drawer Open Button
        Builder(
          builder: (innerContext) => Container(
            margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            child: Material(
              color: _NC.primary,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => Scaffold.of(innerContext).openDrawer(),
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune_rounded, color: Colors.white, size: 15),
                      SizedBox(width: 3),
                      Text(
                        'Filter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _NC.borderGrey),
      ),
    );
  }

  // ── Create News Floating Action Button ───────────────────────────────────
  Widget _buildCreateButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: EdgeInsets.only(bottom: showBackButton ? 8 : 82),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _NC.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        backgroundColor: _NC.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onPressed: () {
          if (!AppController.to.isLoggedIn) {
            Get.snackbar(
              l10n.text('news_error_title'),
              l10n.text('news_login_required'),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange.withValues(alpha: 0.95),
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
              borderRadius: 12,
            );
            return;
          }
          Get.to(() => const CreateNewsScreen(), binding: CreateNewsBinding());
        },
        icon: const Icon(Icons.edit_square, color: Colors.white, size: 18),
        label: Text(
          l10n.text('news_create'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Colors.white),
        ),
      ),
    );
  }

  // ── Tab selector capsules ────────────────────────────────────────────────
  Widget _buildTabSelector(BuildContext context, AppLocalizations l10n) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Obx(() {
        final active = controller.activeTab.value;
        final allCount = controller.allNews.length;
        final textCount = controller.textNews.length;
        final videoCount = controller.videoNews.length;

        return Row(
          children: [
            _buildTabBtn(
              context,
              NewsTab.all,
              l10n.text('news_tab_all'),
              Icons.grid_view_rounded,
              active == NewsTab.all,
              allCount,
            ),
            const SizedBox(width: 8),
            _buildTabBtn(
              context,
              NewsTab.articles,
              l10n.text('news_tab_articles'),
              Icons.article_rounded,
              active == NewsTab.articles,
              textCount,
            ),
            const SizedBox(width: 8),
            _buildTabBtn(
              context,
              NewsTab.videos,
              l10n.text('news_tab_videos'),
              Icons.play_circle_fill_rounded,
              active == NewsTab.videos,
              videoCount,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTabBtn(
    BuildContext context,
    NewsTab tab,
    String label,
    IconData icon,
    bool isActive,
    int count,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.selectTab(tab),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: isActive ? _NC.primary : _NC.fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? _NC.primary : _NC.borderGrey,
                width: 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: _NC.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : _NC.greyText,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isActive ? Colors.white : _NC.mediumText,
                      fontSize: 11.5,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.25)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: isActive ? Colors.white : _NC.mediumText,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Quick Category Horizontal Scroll Bar ─────────────────────────────────
  Widget _buildQuickCategoryBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Obx(() {
            final categories = controller.categories;
            if (categories.isEmpty) return const SizedBox.shrink();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: categories.map((cat) {
                  final isSelected = cat.id == controller.selectedCategoryId.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: isSelected ? _NC.primary : _NC.fieldBg,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () => controller.selectCategory(cat.id),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? _NC.primary : _NC.borderGrey,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            cat.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : _NC.darkText,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
          const SizedBox(height: 8),
          Container(height: 1, color: _NC.borderGrey),
        ],
      ),
    );
  }

  // ── News Card Renderer ───────────────────────────────────────────────────
  Widget _buildNewsCard(BuildContext context, NewsItem item) {
    return switch (item) {
      TextNews textNews => _buildTextCard(context, textNews),
      VideoNews videoNews => _buildVideoCard(context, videoNews),
    };
  }

  // ── Infinite scroll footer ───────────────────────────────────────────────
  Widget _buildListFooter() {
    return Obx(() {
      if (!controller.isLoadingMore.value) return const SizedBox(height: 8);
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: _NC.primary),
          ),
        ),
      );
    });
  }

  // ── Text News Card (Modern Elevated Layout) ──────────────────────────────
  Widget _buildTextCard(BuildContext context, TextNews item) {
    final formattedDate = DateFormat('dd MMM yyyy').format(item.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _NC.borderGrey, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsDetailScreen(article: item),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: _NC.primarySoft,
                          child: const Icon(
                            Icons.newspaper_rounded,
                            color: _NC.primary,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: _NC.primarySoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.categoryName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _NC.primary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 12, color: _NC.greyText),
                              const SizedBox(width: 3),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  color: _NC.greyText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _NC.darkText,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _NC.greyText,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Video News Card (Cinematic 16:9 Layout) ──────────────────────────────
  Widget _buildVideoCard(BuildContext context, VideoNews item) {
    final formattedDate = DateFormat('dd MMM yyyy').format(item.createdAt);
    final thumbnailUrl = item.thumbnailUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _NC.borderGrey),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocalVideoPlayerScreen(news: item),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (thumbnailUrl.isNotEmpty)
                        Image.network(
                          thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: _NC.fieldBg),
                        )
                      else
                        Container(
                          color: _NC.fieldBg,
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_outline_rounded,
                              size: 56,
                              color: _NC.primary,
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _NC.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _NC.primary.withValues(alpha: 0.5),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.categoryName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: _NC.darkText,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _NC.greyText,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Loading Skeletons ────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (ctx, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _NC.borderGrey),
          ),
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Error View ───────────────────────────────────────────────────────────
  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.red),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.text('news_error_loading'),
              style: const TextStyle(
                color: _NC.darkText,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              style: const TextStyle(color: _NC.greyText, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.bootstrap(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.text('news_retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: _NC.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty View (Clean, Perfectly Centered & Overflow-Protected) ─────────
  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite && constraints.maxHeight > 250
            ? constraints.maxHeight
            : 380.0;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: SizedBox(
            height: height,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _NC.primarySoft,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _NC.primary.withValues(alpha: 0.1),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.newspaper_rounded,
                          size: 40,
                          color: _NC.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.text('news_empty_list'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _NC.darkText,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: const Text(
                        'No news stories available for this category or region right now. Try switching to a different state or category.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _NC.greyText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    // Perfectly Centered "Select Different State" Action Container
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      elevation: 0,
                      child: InkWell(
                        onTap: () => _showStatePicker(context, controller, l10n),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _NC.primary, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: _NC.primary.withValues(alpha: 0.12),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: _NC.primarySoft,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.place_rounded,
                                  size: 16,
                                  color: _NC.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Select Different State',
                                style: TextStyle(
                                  color: _NC.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
                                color: _NC.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── State picker sheet ─────────────────────────────────────────────────────
void _showStatePicker(
  BuildContext context,
  NewsController controller,
  AppLocalizations l10n,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4.5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _NC.borderGrey,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _NC.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.place_rounded, color: _NC.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.text('news_select_state'),
                  style: const TextStyle(
                    color: _NC.darkText,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: _NC.greyText),
                  onPressed: () => Navigator.pop(sheetContext),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: _NC.borderGrey),
            Flexible(
              child: Obx(() {
                final states = controller.states;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: states.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: _NC.borderGrey),
                  itemBuilder: (ctx, index) {
                    final state = states[index];
                    final selected =
                        state.id == controller.selectedStateId.value;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      title: Text(
                        state.name,
                        style: TextStyle(
                          color: selected ? _NC.primary : _NC.darkText,
                          fontSize: 14.5,
                          fontWeight: selected
                              ? FontWeight.w900
                              : FontWeight.w600,
                        ),
                      ),
                      trailing: selected
                          ? Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: _NC.primarySoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: _NC.primary,
                                size: 16,
                              ),
                            )
                          : const Icon(
                              Icons.chevron_right_rounded,
                              color: _NC.greyText,
                              size: 18,
                            ),
                      onTap: () {
                        controller.selectState(state.id);
                        Navigator.pop(sheetContext);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      );
    },
  );
}

// ── Collapsible category drawer ────────────────────────────────────────────
class _NewsCategoryDrawer extends StatelessWidget {
  final NewsController controller;
  final BuildContext hostContext;

  const _NewsCategoryDrawer({
    required this.controller,
    required this.hostContext,
  });

  static const Map<String, IconData> _categoryIcons = {
    'business': Icons.trending_up_rounded,
    'crime': Icons.security_rounded,
    'international-news': Icons.public_rounded,
    'national-news': Icons.flag_rounded,
    'politics': Icons.account_balance_rounded,
    'sports': Icons.sports_cricket_rounded,
    'technology': Icons.memory_rounded,
    'education': Icons.school_rounded,
    'jobs': Icons.work_rounded,
    'entertainment': Icons.movie_filter_rounded,
  };

  static const Map<String, Color> _categoryColors = {
    'business': Color(0xFF0284C7),
    'crime': Color(0xFFDC2626),
    'international-news': Color(0xFF059669),
    'national-news': Color(0xFFD97706),
    'politics': Color(0xFF7C3AED),
    'sports': Color(0xFFEA580C),
    'technology': Color(0xFF1400FF),
    'education': Color(0xFF0D9488),
    'jobs': Color(0xFF2563EB),
    'entertainment': Color(0xFFDB2777),
  };

  IconData _iconFor(NewsCategory category) =>
      _categoryIcons[category.slug] ?? Icons.newspaper_rounded;

  Color _colorFor(NewsCategory category) =>
      _categoryColors[category.slug] ?? const Color(0xFF1400FF);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Drawer(
      backgroundColor: const Color(0xFFF8FAFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Premium Hero Header ─────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1400FF), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.2,
                            ),
                          ),
                          child: const Icon(
                            Icons.newspaper_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.text('news_title'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.text('news_categories'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Selected State & Location Card ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 0,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _showStatePicker(
                    hostContext,
                    controller,
                    AppLocalizations.of(hostContext),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.place_rounded,
                          color: Color(0xFF1400FF),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.text('news_state').toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Obx(() {
                              final state = controller.selectedState;
                              return Text(
                                state?.name ?? l10n.text('news_select_state'),
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            }),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Change',
                          style: TextStyle(
                            color: Color(0xFF1400FF),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Feed Format Tab Selector ────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(() {
              final active = controller.activeTab.value;
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _buildTabPill(
                      label: l10n.text('news_tab_all'),
                      icon: Icons.dynamic_feed_rounded,
                      isActive: active == NewsTab.all,
                      onTap: () {
                        controller.selectTab(NewsTab.all);
                        Navigator.pop(context);
                      },
                    ),
                    _buildTabPill(
                      label: l10n.text('news_tab_articles'),
                      icon: Icons.article_rounded,
                      isActive: active == NewsTab.articles,
                      onTap: () {
                        controller.selectTab(NewsTab.articles);
                        Navigator.pop(context);
                      },
                    ),
                    _buildTabPill(
                      label: l10n.text('news_tab_videos'),
                      icon: Icons.play_circle_fill_rounded,
                      isActive: active == NewsTab.videos,
                      onTap: () {
                        controller.selectTab(NewsTab.videos);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            }),
          ),

          // ── Category List Header ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.text('news_categories').toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                Obx(() {
                  final count = controller.categories.length;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Color(0xFF1400FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // ── Category Cards List ─────────────────────────────────────
          Expanded(
            child: Obx(() {
              final categories = controller.categories;
              if (categories.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.text('news_filters_error'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }
              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final category = categories[index];
                  final selected =
                      category.id == controller.selectedCategoryId.value;
                  final categoryColor = _colorFor(category);

                  return Material(
                    color: selected ? const Color(0xFFEEF2FF) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 0,
                    child: InkWell(
                      onTap: () {
                        controller.selectCategory(category.id);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF1400FF)
                                : const Color(0xFFE2E8F0),
                            width: selected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF1400FF)
                                    : categoryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _iconFor(category),
                                color: selected ? Colors.white : categoryColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  color: selected
                                      ? const Color(0xFF1400FF)
                                      : const Color(0xFF0F172A),
                                  fontSize: 14,
                                  fontWeight: selected
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (selected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF1400FF),
                                size: 20,
                              )
                            else
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF94A3B8),
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // ── Bottom Action Footer ────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(
                          () => const CreateNewsScreen(),
                          binding: CreateNewsBinding(),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1400FF), Color(0xFF3B82F6)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1400FF).withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_circle_outline_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.text('news_create'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF1400FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF1400FF).withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isActive ? Colors.white : const Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
