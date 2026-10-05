import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/permissions/permission_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/utils/formatters.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/shimmer_loader.dart';
import '../../shared/widgets/status_badge.dart';
import '../scanner/widgets/barcode_generator_dialog.dart';
import 'widgets/stock_adjustment_dialog.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String skuId;

  const ProductDetailScreen({super.key, required this.skuId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryListProvider);
    final userRole = ref.watch(userRoleProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/inventory');
            }
          },
        ),
        title: const Text('SKU Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2_rounded),
            onPressed: () async {
              final skus = await ref.read(skuRepositoryProvider).getSkus();
              final matched = skus.firstWhere((s) => s.id == skuId, orElse: () => skus.first);
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (_) => BarcodeGeneratorDialog(sku: matched),
                );
              }
            },
          ),
        ],
      ),
      body: inventoryAsync.when(
        loading: () => const ShimmerList(height: 120, itemCount: 3),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (skus) {
          final sku = skus.firstWhere((s) => s.id == skuId, orElse: () => skus.first);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Hero(
                        tag: sku.id,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.widgets_rounded, color: AppColors.primaryTeal, size: 36),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sku.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text('SKU Code: ${sku.skuCode} | Category: ${sku.category}'),
                            const SizedBox(height: 8),
                            StatusBadge(status: sku.stockStatus),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _specCard(context, 'Available Qty', '${sku.quantity} units', AppColors.primaryTeal),
                    const SizedBox(width: 12),
                    _specCard(context, 'Reorder Point', '${sku.reorderLevel} units', AppColors.accentWarning),
                    const SizedBox(width: 12),
                    _specCard(context, 'Unit Value', AppFormatters.formatCurrency(sku.unitPrice), AppColors.primaryIndigo),
                  ],
                ),
                const SizedBox(height: 16),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Mapping',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.place_rounded, color: AppColors.primaryTeal),
                          const SizedBox(width: 8),
                          Text(
                            'Assigned Bin: ${sku.fullLocation}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '30-Day Stock Velocity Chart',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 120),
                            FlSpot(5, 110),
                            FlSpot(10, 140),
                            FlSpot(15, 95),
                            FlSpot(20, 130),
                            FlSpot(25, 150),
                            FlSpot(30, 145),
                          ],
                          isCurved: true,
                          color: AppColors.primaryTeal,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primaryTeal.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (PermissionManager.canAdjustStock(userRole))
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => StockAdjustmentDialog(sku: sku),
                        );
                      },
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text(
                        'Adjust Stock Level',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _specCard(BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
