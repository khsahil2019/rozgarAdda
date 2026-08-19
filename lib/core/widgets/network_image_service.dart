import 'package:flutter/material.dart';
import 'fast_loader.dart';

/// Lightweight, high-performance Network Image widget using Flutter's native memory cache.
/// Bypasses SQLite database disk locks for ultra-fast main thread rendering.
class NetworkImageService extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const NetworkImageService({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return borderRadius != null
          ? ClipRRect(
              borderRadius: borderRadius!,
              child: _buildDefaultErrorWidget(),
            )
          : _buildDefaultErrorWidget();
    }

    final int? cacheWidth = (width != null && width! > 0 && width! < 1200)
        ? (width! * 2).toInt()
        : null;
    final int? cacheHeight = (height != null && height! > 0 && height! < 1200)
        ? (height! * 2).toInt()
        : null;

    final imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildDefaultPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _buildDefaultErrorWidget(),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildDefaultPlaceholder() {
    return FastImageLoader(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF7F8FB),
      alignment: Alignment.center,
      child: const Icon(
        Icons.work_outline_rounded,
        color: Color(0xFF0F5FFF),
        size: 28,
      ),
    );
  }
}
