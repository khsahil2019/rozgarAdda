import 'package:flutter/material.dart';

class NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const NavItem(this.activeIcon, this.inactiveIcon, this.label);
}
