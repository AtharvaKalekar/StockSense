import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/engine/stock_movement_engine.dart';
import '../../domain/models/sku_model.dart';
import '../../shared/providers/app_providers.dart';

class OutwardScreen extends ConsumerStatefulWidget {
  const OutwardScreen({super.key});

  @override
  ConsumerState<OutwardScreen> createState() => _OutwardScreenState();
}

class _OutwardScreenState extends ConsumerState<OutwardScreen> {
  int _currentStep = 0;
  String? _selectedSkuId;
  final _customerController = TextEditingController(text: 'Flipkart Fulfillment Center Bangalore');
  final _soController = TextEditingController(text: 'SO-88219');
  final _qtyController = TextEditingController(text: '5');

  @override
  void dispose() {
    _customerController.dispose();
    _soController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _submitOutward(List<SkuModel> skus) async {
    final selectedSku = skus.firstWhere(
      (s) => s.id == _selectedSkuId || s.skuCode == _selectedSkuId,
      orElse: () => skus.first,
    );

    final currentUserAsync = ref.read(currentUserProvider);
    final userEmail = currentUserAsync.value?.email ?? 'dispatcher@stocksense.io';
    final inventoryRepo = ref.read(inventoryRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);
    final qty = int.tryParse(_qtyController.text) ?? 5;

    final result = StockMovementEngine.processOutward(
      sku: selectedSku,
      outwardQty: qty,
      customerName: _customerController.text,
      referenceNumber: _soController.text,
      userEmail: userEmail,
      device: 'Dispatch Terminal B',
    );

    if (result.success && result.updatedSku != null) {
      await inventoryRepo.updateSku(result.updatedSku!);
      if (result.logEntry != null) {
        await auditRepo.addAuditLog(result.logEntry!);
      }

      ref.invalidate(inventoryListProvider);
      ref.invalidate(dashboardMetricsProvider);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.accentSuccess),
                SizedBox(width: 8),
                Text('Goods Outward Dispatched!'),
              ],
            ),
            content: Text(result.message),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () {
                  Navigator.of(dialogContext, rootNavigator: true).pop();
                  context.go('/dashboard');
                },
                child: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: const Text('Goods Outward & Dispatch'),
      ),
      body: inventoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (rawSkus) {
          if (rawSkus.isEmpty) {
            return const Center(child: Text('No SKUs available for Outward movement.'));
          }

          final uniqueMap = <String, SkuModel>{};
          for (final s in rawSkus) {
            uniqueMap[s.id] = s;
          }
          final skus = uniqueMap.values.toList();

          final selectedSku = skus.firstWhere(
            (s) => s.id == _selectedSkuId || s.skuCode == _selectedSkuId,
            orElse: () => skus.first,
          );
          _selectedSkuId = selectedSku.id;

          return Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 2) {
                setState(() => _currentStep += 1);
              } else {
                _submitOutward(skus);
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              } else {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/dashboard');
                }
              }
            },
            steps: [
              Step(
                title: const Text('Sales Order & Customer Details'),
                isActive: _currentStep >= 0,
                content: Column(
                  children: [
                    TextField(
                      controller: _customerController,
                      decoration: const InputDecoration(labelText: 'Customer / Hub Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _soController,
                      decoration: const InputDecoration(labelText: 'Sales Order Ref', border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Select SKU & Dispatch Qty'),
                isActive: _currentStep >= 1,
                content: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedSkuId,
                      decoration: const InputDecoration(labelText: 'Select SKU', border: OutlineInputBorder()),
                      items: skus.map<DropdownMenuItem<String>>((s) => DropdownMenuItem<String>(
                        value: s.id,
                        child: Text('${s.name} (Available: ${s.quantity})'),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedSkuId = val),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Dispatch Quantity', border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Final Verification'),
                isActive: _currentStep >= 2,
                content: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Summary: Dispatching ${_qtyController.text} units of ${selectedSku.name} from bin ${selectedSku.fullLocation}.',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
