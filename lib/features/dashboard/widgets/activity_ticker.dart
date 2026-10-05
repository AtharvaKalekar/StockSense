import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ActivityTicker extends StatefulWidget {
  const ActivityTicker({super.key});

  @override
  State<ActivityTicker> createState() => _ActivityTickerState();
}

class _ActivityTickerState extends State<ActivityTicker> {
  late Timer _timer;
  int _currentIndex = 0;

  final List<String> _activities = [
    'LIVE: Inbound shipment GRN-8821 received (45 units Samsung S24)',
    'LIVE: Order #ORD-1092 picked by Rajesh Kumar in Zone A',
    'LIVE: Stock Transfer SKU-1002 from A-01-R2 to B-03-R1',
    'LIVE: Dispatch #ORD-1088 handed over to BlueDart Courier',
    'LIVE: Low stock alert generated for Amul Butter 500g (12 units remaining)',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _activities.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryTeal.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryTeal,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE TELEMETRY',
                  style: TextStyle(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Text(
                _activities[_currentIndex],
                key: ValueKey<int>(_currentIndex),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
