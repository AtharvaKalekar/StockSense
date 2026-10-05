import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'in stock':
      case 'instock':
      case 'delivered':
      case 'packed':
        badgeColor = AppColors.stockInStock;
        textColor = Colors.white;
        break;
      case 'low stock':
      case 'lowstock':
      case 'pending':
      case 'picking':
        badgeColor = AppColors.stockLow;
        textColor = Colors.black;
        break;
      case 'critical':
      case 'out of stock':
      case 'outofstock':
        badgeColor = AppColors.stockCritical;
        textColor = Colors.white;
        break;
      default:
        badgeColor = AppColors.primaryIndigo;
        textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
