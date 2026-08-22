import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/features/jobs/presentation/bindings/jobs_binding.dart';
import 'package:rojgar/features/jobs/presentation/screens/recent_jobs_screen.dart';
import 'package:rojgar/features/jobs/presentation/screens/select_category_screen.dart';
import 'package:rojgar/features/kyc/presentation/screens/edit_kyc_screen.dart';
import 'package:rojgar/features/missing_person/presentation/screens/missing_person_list_screen.dart';
import 'package:rojgar/features/news/prsentation/screens/news_screen.dart';
import 'package:rojgar/features/sell_product/presentation/screens/sell_product_category_screen.dart';
import 'package:rojgar/localization/app_localizations.dart';
import '../models/quick_link_model.dart';

class QuickLinkCard extends StatelessWidget {
  final QuickLink link;
  const QuickLinkCard({super.key, required this.link});

  Widget _buildAssetOrFallback() {
    if (link.assetPath.isNotEmpty) {
      return Image.asset(
        link.assetPath,
        fit: BoxFit.fill,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    }
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      color: link.iconColor.withValues(alpha: 0.9),
      child: Center(
        child: Icon(
          link.icon,
          color: Colors.white.withValues(alpha: 0.3),
          size: 48,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            kUseNetworkImages && link.imageUrl.isNotEmpty
                ? Image.network(
                    link.imageUrl,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildAssetOrFallback();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: link.iconColor.withValues(alpha: 0.4),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : _buildAssetOrFallback(),
            // Subtle Dark Gradient Overlay at bottom for clean text legibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            // Tappable InkWell with Text
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (link.label == 'Missing Persons') {
                      Get.to(() => const MissingPersonListScreen());
                    } else if (link.label == 'Post Job') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context).text('post_job_coming_soon'),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else if (link.label == 'KYC Status') {
                      Get.to(() => EditKycScreen());
                    } else if (link.label == 'Sell Products') {
                      Get.to(() => const SellProductCategoryScreen());
                    } else if (link.label == 'News') {
                      Get.to(() => const NewsScreen());
                    } else if (link.label == 'Recent Jobs') {
                      Get.to(() => const RecentJobsScreen());
                    } else {
                      Get.to(
                        () => const SelectCategoryScreen(),
                        binding: JobsBinding(),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        _getLocalizedLabel(context, link.label),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedLabel(BuildContext context, String rawLabel) {
    final key = rawLabel.toLowerCase().replaceAll(' ', '_');
    final l10n = AppLocalizations.of(context);
    if (key == 'recent_jobs') {
      final res = l10n.text('recent_jobs_title');
      if (res.isNotEmpty && res != 'recent_jobs_title') return res;
      return 'Recent Jobs';
    }
    final translated = l10n.text(key);
    if (translated.isNotEmpty && translated != key) {
      return translated;
    }
    return rawLabel;
  }
}
