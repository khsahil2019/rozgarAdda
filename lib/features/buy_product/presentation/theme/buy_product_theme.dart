import 'package:flutter/material.dart';

/// Centralized color palette and visual tokens for the Buy Product / Marketplace module.
/// Modeled faithfully after the "OLD QART" wine-maroon reference theme.
class BuyProductTheme {
  // ── Core Wine / Burgundy Maroon Palette ─────────────────
  static const Color primaryMaroon = Color(0xFF801438);
  static const Color darkMaroon = Color(0xFF5E0B25);
  static const Color deepWine = Color(0xFF6B0E2A);
  static const Color darkPlum = Color(0xFF180A12);
  static const Color softMaroon = Color(0xFF9E1B46);
  static const Color lightMaroonBg = Color(0xFFFDF2F4);
  static const Color chipMaroonBg = Color(0xFFFCE8EC);
  static const Color borderMaroon = Color(0xFF801438);
  static const Color subtleBorder = Color(0xFFE2E8F0);

  // ── Accents & Neutrals ──────────────────────────────────
  static const Color goldAccent = Color(0xFFF59E0B);
  static const Color darkText = Color(0xFF111827);
  static const Color mediumText = Color(0xFF374151);
  static const Color greyText = Color(0xFF64748B);
  static const Color lightGreyText = Color(0xFF94A3B8);
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;

  // ── Gradients ───────────────────────────────────────────
  /// Header gradient (Deep Wine Maroon -> Dark Midnight Plum)
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF6E0D27), Color(0xFF190913)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Category icon card gradient (Wine -> Deep Plum)
  static const LinearGradient categoryCardGradient = LinearGradient(
    colors: [Color(0xFF801438), Color(0xFF4A0A1F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Promo banner gradient
  static const LinearGradient promoBannerGradient = LinearGradient(
    colors: [Color(0xFF7B1236), Color(0xFF3F0719)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

