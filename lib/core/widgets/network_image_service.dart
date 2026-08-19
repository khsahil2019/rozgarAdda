import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'fast_loader.dart';

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

    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 150),
      fadeOutDuration: const Duration(milliseconds: 150),
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) =>
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

