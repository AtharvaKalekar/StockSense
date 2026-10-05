import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

class CapacityGauge extends StatelessWidget {
  final double percentage;
  final num usedUnits;
  final num totalCapacity;

  const CapacityGauge({
    super.key,
    required this.percentage,
    required this.usedUnits,
    required this.totalCapacity,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gaugeColor = percentage > 85
        ? AppColors.errorRed
        : percentage > 70
            ? AppColors.accentWarning
            : AppColors.accentSuccess;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: CustomPaint(
              painter: _GaugePainter(
                percentage: percentage / 100,
                color: gaugeColor,
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: gaugeColor,
                          ),
                    ),
                    Text(
                      'Capacity',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Warehouse Occupancy',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${usedUnits.toString()} / ${totalCapacity.toString()} Units utilized across 4 active zones.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                      ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (percentage / 100).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color backgroundColor;

  _GaugePainter({
    required this.percentage,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 12.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final valPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      pi * 1.5,
      false,
      bgPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      pi * 1.5 * percentage,
      false,
      valPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}
