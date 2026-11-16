import 'package:flutter/material.dart';
import '../theme/buy_product_theme.dart';

/// Pill-shaped search bar with a uniform reddish-maroon border on all four sides.
/// Explicitly neutralizes the global [InputDecorationTheme] so no inner box or
/// clipped side border overlaps the outer pill outline.
class MarketplaceSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onClear;
  final Color borderColor;

  const MarketplaceSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
    this.onSubmitted,
    this.borderColor = BuyProductTheme.borderMaroon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: borderColor,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: const TextStyle(
          color: BuyProductTheme.darkText,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: BuyProductTheme.lightGreyText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: borderColor,
            size: 22,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: BuyProductTheme.greyText,
                    size: 18,
                  ),
                  onPressed: onClear,
                )
              : null,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        ),
      ),
    );
  }
}

