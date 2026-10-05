import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/animated_counter.dart';
import '../../../shared/widgets/glass_card.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final num value;
  final String? prefix;
  final String? suffix;
  final IconData icon;
  final Color color;
  final String subtitle;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.prefix,
    this.suffix,
    required this.icon,
    required this.color,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          AnimatedCounter(
            value: value,
            prefix: prefix,
            suffix: suffix,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
          ),
        ],
      ),
    );
  }
}
