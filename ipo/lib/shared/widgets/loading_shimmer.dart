import 'package:flutter/material.dart';
import 'package:ipo/core/constants/app_colors.dart';

class LoadingShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.cardBorder,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

class IpoCardSkeleton extends StatelessWidget {
  const IpoCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LoadingShimmer(width: MediaQuery.of(context).size.width * 0.5, height: 20),
                const LoadingShimmer(width: 60, height: 22, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 12),
            const LoadingShimmer(width: 100, height: 14),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LoadingShimmer(width: 80, height: 36),
                LoadingShimmer(width: 80, height: 36),
                LoadingShimmer(width: 80, height: 36),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: LoadingShimmer(width: double.infinity, height: 40, borderRadius: 10)),
                SizedBox(width: 12),
                Expanded(child: LoadingShimmer(width: double.infinity, height: 40, borderRadius: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
