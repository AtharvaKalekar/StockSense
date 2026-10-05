import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class CommandPaletteDialog extends ConsumerStatefulWidget {
  const CommandPaletteDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => const CommandPaletteDialog(),
    );
  }

  @override
  ConsumerState<CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends ConsumerState<CommandPaletteDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navActions = [
      {'title': 'Go to Warehouse Dashboard', 'route': '/dashboard', 'icon': Icons.dashboard_rounded},
      {'title': 'Search Inventory & SKUs', 'route': '/inventory', 'icon': Icons.inventory_2_rounded},
      {'title': 'Open Barcode / QR Scanner', 'route': '/scanner', 'icon': Icons.qr_code_scanner_rounded},
      {'title': '2D Warehouse Floor Map', 'route': '/location-map', 'icon': Icons.map_rounded},
      {'title': 'Goods Inward (GRN)', 'route': '/inward', 'icon': Icons.move_to_inbox_rounded},
      {'title': 'Goods Outward (Dispatch)', 'route': '/outward', 'icon': Icons.outbox_rounded},
      {'title': 'Order Picking Workflow', 'route': '/picking', 'icon': Icons.shopping_cart_rounded},
      {'title': 'Packing Kanban Board', 'route': '/dispatch', 'icon': Icons.local_shipping_rounded},
      {'title': 'Low-Stock Alerts', 'route': '/alerts', 'icon': Icons.warning_amber_rounded},
      {'title': 'Analytics Dashboard', 'route': '/analytics', 'icon': Icons.analytics_rounded},
      {'title': 'User & Role Management', 'route': '/user-management', 'icon': Icons.people_rounded},
      {'title': 'Audit History Log', 'route': '/audit-history', 'icon': Icons.history_rounded},
      {'title': 'SaaS Pricing & Calculator', 'route': '/pricing', 'icon': Icons.sell_rounded},
      {'title': 'Settings & Theme Toggle', 'route': '/settings', 'icon': Icons.settings_rounded},
    ];

    final filteredActions = navActions.where((a) => (a['title'] as String).toLowerCase().contains(_query)).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Type a command or jump to screen...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => _searchController.clear(),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBackground : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('ESC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: filteredActions.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('No matching commands found.'),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredActions.length,
                      itemBuilder: (context, index) {
                        final action = filteredActions[index];
                        return ListTile(
                          leading: Icon(action['icon'] as IconData, color: AppColors.primary),
                          title: Text(
                            action['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          onTap: () {
                            Navigator.of(context).pop();
                            context.go(action['route'] as String);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
