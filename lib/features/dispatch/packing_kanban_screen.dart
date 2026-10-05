import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/order_model.dart';
import '../../shared/providers/app_providers.dart';

class PackingKanbanScreen extends ConsumerWidget {
  const PackingKanbanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dispatch');
            }
          },
        ),
        title: const Text('Packing & Dispatch Kanban Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_agenda_outlined),
            onPressed: () => context.go('/dispatch'),
            tooltip: 'Switch to Mobile Card View',
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (orders) {
          final toPack = orders.where((o) => o.status == OrderStatus.picking || o.status == OrderStatus.pending).toList();
          final packed = orders.where((o) => o.status == OrderStatus.packed).toList();
          final dispatched = orders.where((o) => o.status == OrderStatus.dispatched).toList();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildKanbanColumn(context, 'To Pack (${toPack.length})', toPack, AppColors.accentWarning, isDark),
                    const SizedBox(width: 12),
                    _buildKanbanColumn(context, 'Packed & Ready (${packed.length})', packed, AppColors.primaryTeal, isDark),
                    const SizedBox(width: 12),
                    _buildKanbanColumn(context, 'Dispatched (${dispatched.length})', dispatched, AppColors.accentSuccess, isDark),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKanbanColumn(BuildContext context, String title, List<OrderModel> list, Color headerColor, bool isDark) {
    return Container(
      width: 280,
      constraints: const BoxConstraints(maxHeight: 600),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: headerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: headerColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text('No orders', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  )
                : ListView.builder(
                    itemCount: list.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final order = list[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: headerColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      order.status.name.toUpperCase(),
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: headerColor),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(order.customerName, style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text('${order.items.length} Items', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
