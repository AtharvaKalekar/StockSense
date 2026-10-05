import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/engine/stock_movement_engine.dart';
import '../../domain/models/sku_model.dart';
import '../../shared/providers/app_providers.dart';

class InwardScreen extends ConsumerStatefulWidget {
  const InwardScreen({super.key});

  @override
  ConsumerState<InwardScreen> createState() => _InwardScreenState();
}

class _InwardScreenState extends ConsumerState<InwardScreen> {
  int _currentStep = 0;
  String? _selectedSkuId;
  final _supplierController = TextEditingController(text: 'Reliance Logistics India Ltd');
  final _poController = TextEditingController(text: 'PO-2026-9912');
  final _qtyController = TextEditingController(text: '50');

  @override
  void dispose() {
    _supplierController.dispose();
    _poController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _submitInward(List<SkuModel> skus) async {
    final selectedSku = skus.firstWhere(
      (s) => s.id == _selectedSkuId || s.skuCode == _selectedSkuId,
      orElse: () => skus.first,
    );

    final currentUserAsync = ref.read(currentUserProvider);
    final userEmail = currentUserAsync.value?.email ?? 'admin@stocksense.io';
    final inventoryRepo = ref.read(inventoryRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);
    final qty = int.tryParse(_qtyController.text) ?? 10;

    final result = StockMovementEngine.processInward(
      sku: selectedSku,
      inwardQty: qty,
      supplierName: _supplierController.text,
      referenceNumber: _poController.text,
      userEmail: userEmail,
      device: 'GRN Station Terminal A',
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
                Text('GRN Inward Completed!'),
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
        title: const Text('Goods Received Note (GRN Inward)'),
      ),
      body: inventoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (rawSkus) {
          if (rawSkus.isEmpty) {
            return const Center(child: Text('No SKUs available for Inward movement.'));
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
                _submitInward(skus);
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
                title: const Text('Select Supplier & Purchase Order'),
                isActive: _currentStep >= 0,
                content: Column(
                  children: [
                    TextField(
                      controller: _supplierController,
                      decoration: const InputDecoration(labelText: 'Supplier Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _poController,
                      decoration: const InputDecoration(labelText: 'PO / Invoice Ref', border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Select SKU & Received Quantity'),
                isActive: _currentStep >= 1,
                content: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedSkuId,
                      decoration: const InputDecoration(labelText: 'Select SKU', border: OutlineInputBorder()),
                      items: skus.map<DropdownMenuItem<String>>((s) => DropdownMenuItem<String>(
                        value: s.id,
                        child: Text('${s.name} (${s.skuCode})'),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedSkuId = val),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Received Quantity', border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Verification & Storage Bin'),
                isActive: _currentStep >= 2,
                content: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Summary: Inward ${_qtyController.text} units of ${selectedSku.name} into bin ${selectedSku.fullLocation}.',
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
