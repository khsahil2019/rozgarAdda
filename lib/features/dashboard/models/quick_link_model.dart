import 'package:flutter/material.dart';

/// App Color Constants for Dashboard Quick Links
class AC {
  static const Color blueBg = Color(0xFFEFF6FF);
  static const Color blueIcon = Color(0xFF3B82F6);
  static const Color greenBg = Color(0xFFF0FDF4);
  static const Color greenIcon = Color(0xFF22C55E);
  static const Color orangeBg = Color(0xFFFFF7ED);
  static const Color orangeIcon = Color(0xFFF97316);
  static const Color pinkBg = Color(0xFFFDF2F8);
  static const Color pinkIcon = Color(0xFFEC4899);
  static const Color purpleBg = Color(0xFFFAF5FF);
  static const Color purpleIcon = Color(0xFFA855F7);
  static const Color cyanBg = Color(0xFFECFEFF);
  static const Color cyanIcon = Color(0xFF06B6D4);
}

/// Set to true to prefer network images, or false to use local asset images from assets/img/
const bool kUseNetworkImages = false;

class QuickLink {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final String imageUrl;
  final String assetPath;

  const QuickLink(
    this.label,
    this.icon,
    this.bgColor,
    this.iconColor,
    this.imageUrl, {
    this.assetPath = '',
  });
}

const List<QuickLink> kQuickLinks = [
  QuickLink(
    'Find Jobs',
    Icons.work_rounded,
    AC.blueBg,
    AC.blueIcon,
    'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=400&q=80',
    assetPath: 'assets/img/find_job.jpeg',
  ),
  QuickLink(
    'KYC Status',
    Icons.verified_rounded,
    AC.greenBg,
    AC.greenIcon,
    'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=400&q=80',
    assetPath: 'assets/img/kyc_status.jpeg',
  ),
  QuickLink(
    'Sell Products',
    Icons.storefront_rounded,
    AC.greenBg,
    AC.greenIcon,
    'https://images.unsplash.com/photo-1573216755088-971e32839531?auto=format&fit=crop&w=400&q=80',
    assetPath: 'assets/img/sell_product.jpeg',
  ),
  QuickLink(
    'News',
    Icons.payments_rounded,
    AC.orangeBg,
    AC.orangeIcon,
    'https://i.ibb.co/qFXNhgFD/Whats-App-Image-2026-06-06-at-12-45-46-AM.jpg',
    assetPath: 'assets/img/news.jpeg',
  ),
  QuickLink(
    'Missing Persons',
    Icons.support_agent_rounded,
    AC.pinkBg,
    AC.pinkIcon,
    'https://images.unsplash.com/photo-1737154590393-20c0b8c389ae?auto=format&fit=crop&w=400&q=80',
    assetPath: 'assets/img/missing.jpeg',
  ),
  QuickLink(
    'Recent Jobs',
    Icons.school_rounded,
    AC.cyanBg,
    Color.fromARGB(255, 174, 152, 255),
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=400&q=80',
    assetPath: 'assets/img/recent_job.jpeg',
  ),
];
