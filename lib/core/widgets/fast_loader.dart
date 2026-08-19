import 'package:flutter/material.dart';

/// Lightweight, high-performance shimmer animation container.
class FastShimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const FastShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE2E8F0),
    this.highlightColor = const Color(0xFFF8FAFC),
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<FastShimmer> createState() => _FastShimmerState();
}

class _FastShimmerState extends State<FastShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(_animation.value - 1.0, -0.3),
                end: Alignment(_animation.value + 1.0, 0.3),
                colors: [
                  widget.baseColor,
                  widget.highlightColor,
                  widget.baseColor,
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Generic skeleton box container with rounded corners.
class FastSkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const FastSkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
    );
  }
}

/// Shimmer loader for NetworkImageService placeholder.
class FastImageLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const FastImageLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return FastShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: borderRadius ?? BorderRadius.zero,
        ),
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            color: Color(0xFFCBD5E1),
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Skeleton loader for Avatar / Profile circles.
class FastAvatarSkeleton extends StatelessWidget {
  final double size;

  const FastAvatarSkeleton({super.key, this.size = 48.0});

  @override
  Widget build(BuildContext context) {
    return FastShimmer(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFE2E8F0),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Skeleton loader for Job / Product Card.
class FastCardSkeleton extends StatelessWidget {
  final double? height;

  const FastCardSkeleton({super.key, this.height = 140.0});

  @override
  Widget build(BuildContext context) {
    return FastShimmer(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const FastSkeletonBox(
                  width: 44,
                  height: 44,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FastSkeletonBox(width: double.infinity, height: 14),
                      const SizedBox(height: 6),
                      FastSkeletonBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const FastSkeletonBox(width: double.infinity, height: 10),
            const SizedBox(height: 8),
            FastSkeletonBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for 2-column Grid Views (Role Cards, Category Grids).
class FastGridSkeleton extends StatelessWidget {
  final int itemCount;
  final double childAspectRatio;

  const FastGridSkeleton({
    super.key,
    this.itemCount = 6,
    this.childAspectRatio = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return FastShimmer(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(19),
                      ),
                    ),
                    child: const Center(
                      child: FastSkeletonBox(
                        width: 48,
                        height: 48,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: const [
                      FastSkeletonBox(width: 90, height: 12),
                      SizedBox(height: 6),
                      FastSkeletonBox(width: 60, height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton loader for Vertical List Views.
class FastListSkeleton extends StatelessWidget {
  final int itemCount;
  final double cardHeight;

  const FastListSkeleton({
    super.key,
    this.itemCount = 5,
    this.cardHeight = 130.0,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return FastCardSkeleton(height: cardHeight);
      },
    );
  }
}
