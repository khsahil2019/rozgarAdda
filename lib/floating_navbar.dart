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

  final Color _selectedColor = const Color(0xFF1E38FC); // Deep vibrant blue
  final Color _unselectedColor = const Color(0xFF9EABC0); // Greyish-blue

  // Define the screens for each tab
  final List<Widget> _screens = [
    const HomeScreen(),
    const NewsScreen(showBackButton: false),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'HOME'),
                _buildNavItem(1, Icons.newspaper_rounded, 'NEWS'),
                _buildNavItem(2, Icons.person_rounded, 'PROFILE'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final l10n = AppLocalizations.of(context);
    String localizedLabel;
    switch (label) {
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
        localizedLabel = label;
    }

    final isSelected = _selectedIndex == index;
    final color = isSelected ? _selectedColor : _unselectedColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 5),
          Text(
            localizedLabel,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
