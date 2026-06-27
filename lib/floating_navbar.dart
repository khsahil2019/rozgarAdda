import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/dashboard_screen.dart';
import 'package:rojgar/features/app/app_controller.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_screen.dart';

class FloatingNavbarScreen extends StatefulWidget {
  const FloatingNavbarScreen({super.key});

  @override
  State<FloatingNavbarScreen> createState() => _FloatingNavbarScreenState();
}

class _FloatingNavbarScreenState extends State<FloatingNavbarScreen> {
  int _selectedIndex = 0; // Default to Explore as in the image

  final Color _selectedColor = const Color(0xFF1E38FC); // Deep vibrant blue
  final Color _unselectedColor = const Color(0xFF9EABC0); // Greyish-blue
  final Color _fabColor = const Color(0xFF0015FF); // Pure blue for FAB

  // Define the screens for each tab
  final List<Widget> _screens = [
    const HomeScreen(), // 0: Home index
    const Center(
      child: Text(
        'Explore Screen',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
    const Center(
      child: Text(
        'Saved Screen',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
    const ProfileScreen(), // 3: Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF0F2F5,
      ), // Light background to contrast white navbar
      body: IndexedStack(index: _selectedIndex, children: _screens),
      // FAB
      floatingActionButton: Container(
        height: 68.0,
        width: 68.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _fabColor.withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              // Add action here
            },
            backgroundColor: _fabColor,
            elevation: 0,
            shape: const CircleBorder(
              side: BorderSide(color: Colors.white, width: 4.0),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Bottom Navigation Bar
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor:
              Colors.transparent, // Disable click highlights for exact match
        ),
        child: BottomAppBar(
          color: Colors.white,
          elevation: 10,
          shadowColor: Colors.black45,
          padding: EdgeInsets.zero,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: SizedBox(
            height: 75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(0, Icons.home_rounded, 'HOME'),
                      _buildNavItem(1, Icons.widgets, 'EXPLORE'),
                    ],
                  ),
                ),
                const SizedBox(width: 64), // Space for centered FAB notch
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(2, Icons.bookmark_rounded, 'SAVED'),
                      _buildNavItem(3, Icons.person_rounded, 'PROFILE'),
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

  Widget _buildNavItem(int index, IconData icon, String label) {
    final l10n = AppLocalizations.of(context);
    String localizedLabel;
    switch (label) {
      case 'HOME':
        localizedLabel = l10n.text('nav_home');
        break;
      case 'EXPLORE':
        localizedLabel = l10n.text('nav_explore');
        break;
      case 'SAVED':
        localizedLabel = l10n.text('nav_saved');
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
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
