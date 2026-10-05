import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

class SmartInsightsCard extends StatelessWidget {
  const SmartInsightsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final insights = [
      {
        'title': 'Stockout Warning',
        'desc': '12 SKUs predicted to stock out in 5 days based on sales velocity.',
        'icon': Icons.warning_amber_rounded,
        'color': AppColors.errorRed,
      },
      {
        'title': 'Zone Rebalance',
        'desc': 'Zone B capacity is at 94%. Move 40 fast-moving SKUs to Zone A.',
        'icon': Icons.swap_horiz_rounded,
        'color': AppColors.accentWarning,
      },
      {
        'title': 'Optimized Route',
        'desc': 'Picking travel distance reduced by 18% today with smart pathing.',
        'icon': Icons.auto_awesome_rounded,
        'color': AppColors.primaryTeal,
      },
    ];

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: AppColors.primaryTeal, size: 24),
              const SizedBox(width: 8),
              Text(
                'AI Smart Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryIndigo.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Automated Engine',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryIndigo,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...insights.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (item['color'] as Color).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: item['color'] as Color,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['desc'] as String,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
