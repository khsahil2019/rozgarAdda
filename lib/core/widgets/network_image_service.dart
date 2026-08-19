import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: (width != null && width! > 0 && width! < 1000)
          ? (width! * 2).toInt()
          : 400,
      memCacheHeight: (height != null && height! > 0 && height! < 1000)
          ? (height! * 2).toInt()
          : 400,
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
    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: const Color(0xFF0F5FFF),
        ),
      ),
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
