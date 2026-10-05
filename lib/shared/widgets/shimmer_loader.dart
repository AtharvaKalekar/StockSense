import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ShimmerListLoader extends StatefulWidget {
  final int itemCount;
  final double height;

  const ShimmerListLoader({
    super.key,
    this.itemCount = 6,
    this.height = 90,
  });

  @override
  State<ShimmerListLoader> createState() => _ShimmerListLoaderState();
}

class _ShimmerListLoaderState extends State<ShimmerListLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkSurface : Colors.grey.shade300;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            return Container(
              height: widget.height,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: _animation.value),
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
        );
      },
    );
  }
}

typedef ShimmerList = ShimmerListLoader;
