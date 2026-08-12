import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rojgar/features/app/app_controller.dart';
import 'package:rojgar/localization/app_localizations.dart';
import '../../domain/entities/news_category.dart';
import '../../domain/entities/news_item.dart';
import '../bindings/news_binding.dart';
import '../controller/news_controller.dart';
import 'create_news_screen.dart';
import 'news_detail_screen.dart';
import 'local_video_player_screen.dart';

// Colors constant configuration
class _NC {
  static const Color bg = Color(0xFFF4F5F9);
  static const Color navy = Color(0xFF1A1E3C);
  static const Color gold = Color(0xFFD4A017);
  static const Color accent = Color(0xFF2255DD);
  static const Color grey = Color(0xFF8A8FA3);
}

class NewsScreen extends GetView<NewsController> {
  final bool showBackButton;

  const NewsScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: _NC.bg,
      drawer: _NewsCategoryDrawer(controller: controller, hostContext: context),
      floatingActionButton: _buildCreateButton(context, l10n),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context, l10n),

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
                  color: _NC.navy,
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
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
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

  // ── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      color: _NC.navy,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          if (showBackButton) ...[
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Builder(
            builder: (innerContext) => IconButton(
              onPressed: () => Scaffold.of(innerContext).openDrawer(),
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              tooltip: l10n.text('news_categories'),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.text('news_title'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                Obx(() {
                  final category = controller.selectedCategory;
                  final state = controller.selectedState;
                  if (category == null && state == null) {
                    return const SizedBox.shrink();
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
                      color: Color(0xFFB9BFD6),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showStatePicker(context, controller, l10n),
            icon: const Icon(Icons.place_outlined, color: Colors.white),
            tooltip: l10n.text('news_select_state'),
          ),
        ],
      ),
    );
  }

  // ── Create News FAB ──────────────────────────────────────────────────────
  Widget _buildCreateButton(BuildContext context, AppLocalizations l10n) {
    return FloatingActionButton.extended(
      backgroundColor: _NC.navy,
      foregroundColor: Colors.white,
      onPressed: () {
        if (!AppController.to.isLoggedIn) {
          Get.snackbar(
            l10n.text('news_error_title'),
            l10n.text('news_login_required'),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
          return;
        }
        Get.to(() => const CreateNewsScreen(), binding: CreateNewsBinding());
      },
      icon: const Icon(Icons.add_rounded),
      label: Text(
        l10n.text('news_create'),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  // ── Tab selector capsules ────────────────────────────────────────────────
  Widget _buildTabSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Obx(() {
        return Row(
          children: [
            _buildTabBtn(context, NewsTab.all, l10n.text('news_tab_all')),
            const SizedBox(width: 10),
            _buildTabBtn(
              context,
              NewsTab.articles,
              l10n.text('news_tab_articles'),
            ),
            const SizedBox(width: 10),
            _buildTabBtn(context, NewsTab.videos, l10n.text('news_tab_videos')),
          ],
        );
      }),
    );
  }

  Widget _buildTabBtn(BuildContext context, NewsTab tab, String label) {
    final active = controller.activeTab.value == tab;
    return GestureDetector(
      onTap: () => controller.selectTab(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _NC.navy : const Color(0xFFF0F1F6),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : _NC.grey,
            fontSize: 13,
            fontWeight: FontWeight.bold,
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
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: _NC.navy),
          ),
        ),
      );
    });
  }

  // ── Text News Card ───────────────────────────────────────────────────────
  Widget _buildTextCard(BuildContext context, TextNews item) {
    final formattedDate = DateFormat('dd MMM yyyy').format(item.createdAt);
    return Card(
      color: Colors.white,
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  width: 90,
                  height: 90,
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFDEEAFF),
                        child: const Icon(
                          Icons.article_rounded,
                          color: _NC.accent,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF5B2BE0,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.categoryName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF5B2BE0),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formattedDate,
                          style: const TextStyle(color: _NC.grey, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _NC.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _NC.grey,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Video News Card ──────────────────────────────────────────────────────
  Widget _buildVideoCard(BuildContext context, VideoNews item) {
    final formattedDate = DateFormat('dd MMM yyyy').format(item.createdAt);
    final thumbnailUrl = item.thumbnailUrl;

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (thumbnailUrl.isNotEmpty)
                      Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: const Color(0xFFD8E8F0)),
                      )
                    else
                      Container(
                        color: const Color(0xFFE3E5ED),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_outline_rounded,
                            size: 64,
                            color: _NC.navy,
                          ),
                        ),
                      ),
                    Container(color: Colors.black26),
                    Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: _NC.gold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _NC.navy,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'VIDEO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: _NC.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(color: _NC.grey, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: _NC.navy,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _NC.grey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Loading Skeletons ────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (ctx, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
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
                        color: Colors.grey.shade200,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.grey.shade200,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 120,
                        height: 12,
                        color: Colors.grey.shade200,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            const Icon(Icons.cloud_off_rounded, size: 64, color: _NC.grey),
            const SizedBox(height: 16),
            Text(
              l10n.text('news_error_loading'),
              style: const TextStyle(
                color: _NC.navy,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              style: const TextStyle(color: _NC.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.bootstrap(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.text('news_retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: _NC.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox_rounded, size: 64, color: _NC.grey),
                  const SizedBox(height: 16),
                  Text(
                    l10n.text('news_empty_list'),
                    style: const TextStyle(
                      color: _NC.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
}

// ── State picker sheet ─────────────────────────────────────────────────────
void _showStatePicker(
  BuildContext context,
  NewsController controller,
  AppLocalizations l10n,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Row(
                  children: [
                    const Icon(Icons.place_outlined, color: _NC.navy),
                    const SizedBox(width: 10),
                    Text(
                      l10n.text('news_select_state'),
                      style: const TextStyle(
                        color: _NC.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: Obx(() {
                  final states = controller.states;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: states.length,
                    itemBuilder: (ctx, index) {
                      final state = states[index];
                      final selected =
                          state.id == controller.selectedStateId.value;
                      return ListTile(
                        title: Text(
                          state.name,
                          style: TextStyle(
                            color: selected ? _NC.accent : _NC.navy,
                            fontSize: 14,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                        trailing: selected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: _NC.accent,
                                size: 20,
                              )
                            : null,
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
        ),
      );
    },
  );
}

// ── Collapsible category drawer ────────────────────────────────────────────
class _NewsCategoryDrawer extends StatelessWidget {
  final NewsController controller;

  /// Context of the screen hosting the drawer; the state sheet is opened from
  /// it so it survives the drawer being dismissed.
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
              color: _NC.navy,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.text('news_title'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.text('news_categories'),
                    style: const TextStyle(
                      color: Color(0xFFB9BFD6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
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
                        style: const TextStyle(color: _NC.grey, fontSize: 13),
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
                      leading: Icon(
                        _iconFor(category),
                        color: selected ? _NC.accent : _NC.grey,
                        size: 22,
                      ),
                      title: Text(
                        category.name,
                        style: TextStyle(
                          color: selected ? _NC.accent : _NC.navy,
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      selected: selected,
                      selectedTileColor: const Color(0xFFEFF3FF),
                      onTap: () {
                        controller.selectCategory(category.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              }),
            ),
            const Divider(height: 1),
            Obx(() {
              final state = controller.selectedState;
              return ListTile(
                leading: const Icon(Icons.place_outlined, color: _NC.navy),
                title: Text(
                  l10n.text('news_state'),
                  style: const TextStyle(
                    color: _NC.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                subtitle: Text(
                  state?.name ?? '-',
                  style: const TextStyle(
                    color: _NC.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: _NC.grey,
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
