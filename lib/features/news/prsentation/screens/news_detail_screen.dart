import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/news_item.dart';

class NewsDetailScreen extends StatelessWidget {
  final TextNews article;

  const NewsDetailScreen({super.key, required this.article});

  static const Color primary = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color mediumText = Color(0xFF334155);
  static const Color greyText = Color(0xFF64748B);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color borderGrey = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(article.createdAt);
    final wordCount = article.description.split(RegExp(r'\s+')).length;
    final readTimeMinutes = (wordCount / 180).ceil().clamp(1, 10);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
        backgroundColor: lightBg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Image Sliver AppBar
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: primary,
              leading: Center(
                child: AppBackButton(
                  isDark: true,
                  margin: const EdgeInsets.only(left: 12),
                  onPressed: () => Navigator.maybePop(context),
                  tooltip: 'Back',
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    tooltip: 'Share News',
                    onPressed: () {
                      Share.share(
                        '${article.title}\n\n${article.description}\n\nRead more on Rozgar Adda App!',
                        subject: article.title,
                      );
                    },
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      article.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: primary.withValues(alpha: 0.12),
                          child: const Icon(
                            Icons.newspaper_rounded,
                            size: 64,
                            color: primary,
                          ),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.black.withValues(alpha: 0.75),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Article Content Body
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Read Time Tags Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: primary.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            article.categoryName.toUpperCase(),
                            style: const TextStyle(
                              color: primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined, size: 13, color: greyText),
                              const SizedBox(width: 4),
                              Text(
                                '$readTimeMinutes min read',
                                style: const TextStyle(
                                  color: greyText,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.access_time_rounded, size: 14, color: greyText),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: greyText,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Article Title
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Verified Bulletin Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderGrey),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Verified Citizen & Employment News Update',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: darkText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1, color: borderGrey),
                    const SizedBox(height: 16),

                    // Main Article Body
                    Text(
                      article.description,
                      style: const TextStyle(
                        color: mediumText,
                        fontSize: 15,
                        height: 1.7,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.1,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Share Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderGrey),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.share_rounded, color: primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Share this update',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                    color: darkText,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Help others stay informed on Rozgar Adda',
                                  style: TextStyle(fontSize: 11.5, color: greyText),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Share.share(
                                '${article.title}\n\n${article.description}\n\nRead more on Rozgar Adda App!',
                                subject: article.title,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            child: const Text('Share', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
