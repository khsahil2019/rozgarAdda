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
  static const Color primaryLight = Color(0xFF4F46E5);
  static const Color darkText = Color(0xFF0F172A);
  static const Color mediumText = Color(0xFF334155);
  static const Color greyText = Color(0xFF64748B);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color borderGrey = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(article.createdAt);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
        backgroundColor: lightBg,
        body: CustomScrollView(
          slivers: [
            // Sleek Header image app bar
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: primary,
              leading: Center(
                child: AppBackButton(
                  isDark: true,
                  margin: const EdgeInsets.only(left: 12),
                  onPressed: () => Navigator.maybePop(context),
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
                    onPressed: () {
                      Share.share(
                        '${article.title}\n\nRead more on Rozgar Adda App!',
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
                          color: primary.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.article_rounded,
                            size: 72,
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
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Article Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category tag and Date
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
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
                        const Spacer(),
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: greyText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: greyText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: borderGrey),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      article.description,
                      style: const TextStyle(
                        color: mediumText,
                        fontSize: 15,
                        height: 1.65,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),
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
