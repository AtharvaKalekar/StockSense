import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/engine/stock_movement_engine.dart';
import '../../../domain/models/movement_log_model.dart';
import '../../../domain/models/sku_model.dart';
import '../../../shared/providers/app_providers.dart';

class StockAdjustmentDialog extends ConsumerStatefulWidget {
  final SkuModel sku;

  const StockAdjustmentDialog({super.key, required this.sku});

  @override
  ConsumerState<StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends ConsumerState<StockAdjustmentDialog> {
  MovementType _type = MovementType.inward;
  int _quantity = 10;
  final _reasonController = TextEditingController(text: 'Routine Stock Count Adjustment');

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() async {
    final currentUserAsync = ref.read(currentUserProvider);
    final userEmail = currentUserAsync.value?.email ?? 'admin@stocksense.io';
    final inventoryRepo = ref.read(inventoryRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    final StockMovementResult result;
    if (_type == MovementType.inward) {
      result = StockMovementEngine.processInward(
        sku: widget.sku,
        inwardQty: _quantity,
        supplierName: _reasonController.text,
        referenceNumber: 'ADJ-${DateTime.now().millisecondsSinceEpoch % 10000}',
        userEmail: userEmail,
        device: 'Handheld Terminal A',
      );
    } else {
      result = StockMovementEngine.processOutward(
        sku: widget.sku,
        outwardQty: _quantity,
        customerName: _reasonController.text,
        referenceNumber: 'ADJ-${DateTime.now().millisecondsSinceEpoch % 10000}',
        userEmail: userEmail,
        device: 'Handheld Terminal A',
      );
    }

    if (result.success && result.updatedSku != null) {
      await inventoryRepo.updateSku(result.updatedSku!);
      if (result.logEntry != null) {
        await auditRepo.addAuditLog(result.logEntry!);
      }

      ref.invalidate(inventoryListProvider);
      ref.invalidate(dashboardMetricsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adjust Stock - ${widget.sku.skuCode}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<MovementType>(
              segments: const [
                ButtonSegment(
                  value: MovementType.inward,
                  label: Text('Inward (+)'),
                  icon: Icon(Icons.add),
                ),
                ButtonSegment(
                  value: MovementType.outward,
                  label: Text('Outward (-)'),
                  icon: Icon(Icons.remove),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (set) => setState(() => _type = set.first),
            ),
            const SizedBox(height: 16),
            Text('Current Qty: ${widget.sku.quantity} | Location: ${widget.sku.fullLocation}'),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _quantity = (_quantity - 1).clamp(1, 1000)),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Expanded(
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _quantity += 1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason / Reference Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryTeal,
            foregroundColor: Colors.black,
          ),
          onPressed: _submit,
          child: const Text('Confirm Adjustment'),
        ),
      ],
    );
  }
}
