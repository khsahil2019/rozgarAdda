import 'package:flutter/material.dart';
import 'package:rojgar/dashboard_screen.dart';
import 'package:rojgar/features/news/prsentation/screens/news_screen.dart';
import 'package:rojgar/localization/app_localizations.dart';

import 'profile_screen.dart';

class FloatingNavbarScreen extends StatefulWidget {
  const FloatingNavbarScreen({super.key});

  @override
  State<FloatingNavbarScreen> createState() => _FloatingNavbarScreenState();
}

class _FloatingNavbarScreenState extends State<FloatingNavbarScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const NewsScreen(showBackButton: false),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.1),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'HOME', 'Home'),
              _buildNavItem(1, Icons.newspaper_rounded, Icons.newspaper_outlined, 'NEWS', 'News'),
              _buildNavItem(2, Icons.person_rounded, Icons.person_outline_rounded, 'PROFILE', 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String translationKey,
    String defaultLabel,
  ) {
    final l10n = AppLocalizations.of(context);
    String localizedLabel;
    switch (translationKey) {
      case 'HOME':
        localizedLabel = l10n.text('nav_home');
        break;
      case 'NEWS':
        localizedLabel = l10n.text('nav_news');
        break;
      case 'PROFILE':
        localizedLabel = l10n.text('nav_profile');
        break;
      default:
        localizedLabel = defaultLabel;
    }

    if (localizedLabel.isEmpty || localizedLabel.contains('_')) {
      localizedLabel = defaultLabel;
    }

    final isSelected = _selectedIndex == index;
    const activeColor = Color(0xFF1400FF);
    final activeBgColor = const Color(0xFF1400FF).withValues(alpha: 0.08);
    const inactiveColor = Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: activeColor.withValues(alpha: 0.2), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? activeColor : inactiveColor,
              size: isSelected ? 24 : 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: const TextStyle(
                  color: activeColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
                child: Text(localizedLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
