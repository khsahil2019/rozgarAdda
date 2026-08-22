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
  static const Color primaryLight = Color(0xFF4F46E5);
  static const Color darkText = Color(0xFF0F172A);
  static const Color mediumText = Color(0xFF334155);
  static const Color greyText = Color(0xFF64748B);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color fieldBg = Color(0xFFF8FAFC);
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
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
                    decoration: BoxDecoration(
                      color: _NC.fieldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _NC.borderGrey),
                    ),
                    child: IconButton(
                      onPressed: () => Scaffold.of(innerContext).openDrawer(),
                      icon: const Icon(Icons.menu_rounded, color: _NC.darkText, size: 20),
                      tooltip: l10n.text('news_categories'),
                      splashRadius: 20,
                      constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.text('news_title'),
                style: const TextStyle(
                  color: _NC.darkText,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.4,
                ),
              ),
              Obx(() {
                final category = controller.selectedCategory;
                final state = controller.selectedState;
                if (category == null && state == null) {
                  return const Text(
                    'Latest Updates & Announcements',
                    style: TextStyle(
                      color: _NC.greyText,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }
                final label = [
                  if (category != null) category.name,
                  if (state != null) state.name,
                ].join(' • ');
                return Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _NC.primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }),
            ],
          ),
          actions: [
            if (showBackButton)
              Builder(
                builder: (innerContext) => IconButton(
                  onPressed: () => Scaffold.of(innerContext).openDrawer(),
                  icon: const Icon(Icons.tune_rounded, color: _NC.primary, size: 22),
                  tooltip: l10n.text('news_categories'),
                ),
              ),
            const SizedBox(width: 4),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _NC.borderGrey),
          ),
        ),
        body: Column(
          children: [
            // Tab Selector
            _buildTabSelector(context),

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
                      ? _buildEmptyState(l10n)
                      : NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification.metrics.pixels >=
                                notification.metrics.maxScrollExtent - 240) {
                              controller.loadMore();
                            }
                            return false;
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
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

  // ── Create News FAB ──────────────────────────────────────────────────────
  Widget _buildCreateButton(BuildContext context, AppLocalizations l10n) {
    return FloatingActionButton.extended(
      backgroundColor: _NC.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () {
        if (!AppController.to.isLoggedIn) {
          Get.snackbar(
            l10n.text('news_error_title'),
            l10n.text('news_login_required'),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withValues(alpha: 0.9),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
          return;
        }
        Get.to(() => const CreateNewsScreen(), binding: CreateNewsBinding());
      },
      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
      label: Text(
        l10n.text('news_create'),
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
      ),
    );
  }

  // ── Tab selector capsules ────────────────────────────────────────────────
  Widget _buildTabSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Obx(() {
        return Row(
          children: [
            _buildTabBtn(context, NewsTab.all, l10n.text('news_tab_all'), Icons.grid_view_rounded),
            const SizedBox(width: 8),
            _buildTabBtn(
              context,
              NewsTab.articles,
              l10n.text('news_tab_articles'),
              Icons.article_outlined,
            ),
            const SizedBox(width: 8),
            _buildTabBtn(
              context,
              NewsTab.videos,
              l10n.text('news_tab_videos'),
              Icons.play_circle_outline_rounded,
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
  ) {
    final active = controller.activeTab.value == tab;
    return Expanded(
      child: InkWell(
        onTap: () => controller.selectTab(tab),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? _NC.primary : _NC.fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? _NC.primary : _NC.borderGrey,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: active ? Colors.white : _NC.greyText,
                size: 15,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : _NC.mediumText,
                  fontSize: 12.5,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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

  // ── Text News Card ───────────────────────────────────────────────────────
  Widget _buildTextCard(BuildContext context, TextNews item) {
    final formattedDate = DateFormat('dd MMM yyyy').format(item.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _NC.borderGrey),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
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
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 92,
                    height: 92,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: _NC.primary.withValues(alpha: 0.08),
                          child: const Icon(
                            Icons.article_rounded,
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
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: _NC.primary.withValues(alpha: 0.08),
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
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            formattedDate,
                            style: const TextStyle(color: _NC.greyText, fontSize: 11, fontWeight: FontWeight.w500),
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

  // ── Video News Card ──────────────────────────────────────────────────────
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
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
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
                      Container(color: Colors.black26),
                      Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _NC.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _NC.primary.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
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

  // ── Empty View ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 300.0;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: height,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _NC.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.newspaper_rounded, size: 48, color: _NC.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.text('news_empty_list'),
                    style: const TextStyle(
                      color: _NC.darkText,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
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
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.72,
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
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _NC.borderGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.place_outlined, color: _NC.primary, size: 20),
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
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w900
                              : FontWeight.w600,
                        ),
                      ),
                      trailing: selected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: _NC.primary,
                              size: 20,
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
    'business': Icons.business_center_rounded,
    'crime': Icons.gavel_rounded,
    'international-news': Icons.public_rounded,
    'national-news': Icons.flag_rounded,
    'politics': Icons.account_balance_rounded,
    'sports': Icons.sports_cricket_rounded,
    'technology': Icons.memory_rounded,
  };

  IconData _iconFor(NewsCategory category) =>
      _categoryIcons[category.slug] ?? Icons.article_rounded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_NC.primary, _NC.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.text('news_title'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.text('news_categories'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _showStatePicker(
                        hostContext,
                        controller,
                        AppLocalizations.of(hostContext),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.place_outlined, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Obx(() {
                            final state = controller.selectedState;
                            return Text(
                              state?.name ?? l10n.text('news_select_state'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                        style: const TextStyle(color: _NC.greyText, fontSize: 13),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: categories.length,
                  itemBuilder: (ctx, index) {
                    final category = categories[index];
                    final selected =
                        category.id == controller.selectedCategoryId.value;
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: selected
                              ? _NC.primary.withValues(alpha: 0.1)
                              : _NC.fieldBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _iconFor(category),
                          color: selected ? _NC.primary : _NC.greyText,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: TextStyle(
                          color: selected ? _NC.primary : _NC.darkText,
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w900
                              : FontWeight.w600,
                        ),
                      ),
                      selected: selected,
                      onTap: () {
                        controller.selectCategory(category.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              }),
            ),
            const Divider(height: 1, color: _NC.borderGrey),
            Obx(() {
              final state = controller.selectedState;
              return ListTile(
                leading: const Icon(Icons.place_outlined, color: _NC.primary),
                title: Text(
                  l10n.text('news_state'),
                  style: const TextStyle(
                    color: _NC.greyText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  state?.name ?? '-',
                  style: const TextStyle(
                    color: _NC.darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                trailing: const Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: _NC.greyText,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showStatePicker(
                    hostContext,
                    controller,
                    AppLocalizations.of(hostContext),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
