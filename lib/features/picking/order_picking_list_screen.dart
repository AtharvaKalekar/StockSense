import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/shimmer_loader.dart';
import '../../shared/widgets/status_badge.dart';

class OrderPickingListScreen extends ConsumerWidget {
  const OrderPickingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
        ),
        title: const Text('Order Picking Workflow'),
      ),
      body: ordersAsync.when(
        loading: () => const ShimmerList(height: 100, itemCount: 5),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyState(
              icon: Icons.checklist_rtl_rounded,
              title: 'No Pending Pick Lists',
              subtitle: 'All customer sales orders have been picked and routed for packing.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.orderNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          StatusBadge(status: order.status.name),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Customer: ${order.customerName}'),
                      Text('Items: ${order.items.length} SKUs | Priority: High'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () => context.push('/picking/${order.id}'),
                            icon: const Icon(Icons.directions_walk_rounded),
                            label: const Text('Start Pick Route'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
