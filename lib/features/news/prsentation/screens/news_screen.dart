import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/news_item.dart';
import '../controller/news_controller.dart';
import 'news_detail_screen.dart';

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

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'Error',
        'Could not open video URL',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: _NC.bg,
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

                final List<NewsItem> currentList = _getCurrentList();
                if (currentList.isEmpty) {
                  return _buildEmptyState(l10n);
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchNews(),
                  color: _NC.navy,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: currentList.length,
                    itemBuilder: (ctx, index) {
                      final item = currentList[index];
                      return _buildNewsCard(context, item);
                    },
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          if (showBackButton) ...[
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
          ],
          Text(
            l10n.text('news_title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
        ],
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
            _buildTabBtn(context, 0, l10n.text('news_tab_all')),
            const SizedBox(width: 10),
            _buildTabBtn(context, 1, l10n.text('news_tab_articles')),
            const SizedBox(width: 10),
            _buildTabBtn(context, 2, l10n.text('news_tab_videos')),
          ],
        );
      }),
    );
  }

  Widget _buildTabBtn(BuildContext context, int index, String label) {
    final active = controller.activeTab.value == index;
    return GestureDetector(
      onTap: () => controller.activeTab.value = index,
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
      YoutubeNews youtubeNews => _buildVideoCard(context, youtubeNews),
    };
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5B2BE0).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.category.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF5B2BE0),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: _NC.grey,
                            fontSize: 10,
                          ),
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

  // ── Video News Card (Both Direct Upload and YouTube) ─────────────────────
  Widget _buildVideoCard(BuildContext context, NewsItem item) {
    String title = '';
    String description = '';
    String? thumbnailUrl;
    String mediaUrl = '';
    bool isYoutube = false;
    final formattedDate = DateFormat('dd MMM yyyy').format(item.createdAt);

    if (item is YoutubeNews) {
      title = item.title;
      description = item.description;
      thumbnailUrl = item.thumbnailUrl;
      mediaUrl = item.youtubeUrl;
      isYoutube = true;
    } else if (item is VideoNews) {
      title = item.title;
      description = item.subject;
      mediaUrl = item.videoUrl;
      isYoutube = false;
    }

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumbnailUrl != null)
                    Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFD8E8F0)),
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
                    child: GestureDetector(
                      onTap: () => _launchUrl(mediaUrl),
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
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isYoutube ? Colors.red : _NC.navy,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isYoutube ? 'YOUTUBE' : 'VIDEO',
                        style: const TextStyle(
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
                    const Icon(Icons.access_time_rounded, size: 13, color: _NC.grey),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: _NC.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: _NC.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
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
    );
  }

  // ── Helper state selectors ───────────────────────────────────────────────
  List<NewsItem> _getCurrentList() {
    return switch (controller.activeTab.value) {
      0 => controller.allNews,
      1 => controller.textNews,
      2 => controller.videoNews,
      _ => controller.allNews,
    };
  }

  // ── Loading Skeletons ────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (ctx, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      Container(width: 60, height: 12, color: Colors.grey.shade200),
                      const SizedBox(height: 8),
                      Container(width: double.infinity, height: 16, color: Colors.grey.shade200),
                      const SizedBox(height: 6),
                      Container(width: 120, height: 12, color: Colors.grey.shade200),
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
              onPressed: () => controller.fetchNews(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _NC.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty View ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
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
    );
  }
}
