import "../../domain/models/user_model.dart";
import "../../domain/models/alert_model.dart";
import "package:go_router/go_router.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../core/permissions/permission_manager.dart";
import "../../shared/providers/app_providers.dart";

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  String _searchQuery = "";
  String _selectedFilter = "ALL";

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsListProvider);
    final userRole = ref.watch(currentRoleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Low Stock Alerts",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: isMobile
                ? IconButton(
                    tooltip: "Order All Low Stock",
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 20),
                    onPressed: () => _handleBatchOrderClick(context, userRole),
                  )
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _handleBatchOrderClick(context, userRole),
                    icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 16),
                    label: const Text("Order All Low Stock", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
          ),
        ],
      ),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error loading alerts: $err")),
        data: (alerts) {
          final criticalCount = alerts.where((a) => a.severity == AlertSeverity.critical).length;
          final warningCount = alerts.where((a) => a.severity == AlertSeverity.warning).length;
          final infoCount = alerts.where((a) => a.severity == AlertSeverity.info).length;

          final filteredAlerts = alerts.where((a) {
            final matchesFilter = switch (_selectedFilter) {
              "CRITICAL" => a.severity == AlertSeverity.critical,
              "WARNING" => a.severity == AlertSeverity.warning,
              "INFO" => a.severity == AlertSeverity.info,
              _ => true,
            };

            final q = _searchQuery.toLowerCase();
            final matchesQuery = q.isEmpty ||
                a.title.toLowerCase().contains(q) ||
                a.message.toLowerCase().contains(q) ||
                (a.skuCode ?? "").toLowerCase().contains(q);

            return matchesFilter && matchesQuery;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Severity Metrics Row
                Row(
                  children: [
                    Expanded(child: _metricCard(context, title: "ALL ALERTS", count: "${alerts.length}", color: const Color(0xFF64748B), icon: Icons.notifications_rounded, isDark: isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _metricCard(context, title: "CRITICAL", count: "$criticalCount", color: const Color(0xFFEF4444), icon: Icons.error_outline_rounded, isDark: isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _metricCard(context, title: "WARNING", count: "$warningCount", color: const Color(0xFFF59E0B), icon: Icons.warning_amber_rounded, isDark: isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _metricCard(context, title: "INFO", count: "$infoCount", color: const Color(0xFF3B82F6), icon: Icons.info_outline_rounded, isDark: isDark)),
                  ],
                ),
                const SizedBox(height: 16),

                // Search Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: "Search by SKU, item, or alert...",
                          prefixIcon: const Icon(Icons.search, size: 20),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Severity Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip("ALL", "All (${alerts.length})"),
                      _filterChip("CRITICAL", "Critical ($criticalCount)"),
                      _filterChip("WARNING", "Warning ($warningCount)"),
                      _filterChip("INFO", "Info ($infoCount)"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Alerts List
                if (filteredAlerts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 48, color: isDark ? Colors.white38 : Colors.black26),
                          const SizedBox(height: 12),
                          const Text("No Matching Alerts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text("All inventory levels are within safe operating thresholds.", style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 12)),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredAlerts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final alert = filteredAlerts[index];
                      Color accentColor;
                      switch (alert.severity) {
                        case AlertSeverity.critical:
                          accentColor = const Color(0xFFEF4444);
                          break;
                        case AlertSeverity.warning:
                          accentColor = const Color(0xFFF59E0B);
                          break;
                        default:
                          accentColor = const Color(0xFF3B82F6);
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Glowing Severity Strip
                                Container(
                                  width: 6,
                                  color: accentColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: accentColor.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                alert.severity.name.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: accentColor,
                                                  fontFamily: "JetBrains Mono",
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                "SKU: ${alert.skuCode ?? "SKU-UNKNOWN"}",
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                                                  fontFamily: "JetBrains Mono",
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          alert.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          alert.message,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? Colors.white70 : const Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // Location Tag
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Bin: Zone A-0${(alert.skuCode ?? "").hashCode % 4 + 1}-R${(alert.skuCode ?? "").hashCode % 5 + 1}",
                                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: "JetBrains Mono"),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        // Action Buttons Bar (Responsive Row/Wrap)
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                                  side: const BorderSide(color: Color(0xFF0D9488)),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                onPressed: () => context.go("/inward"),
                                                icon: const Icon(Icons.input_rounded, size: 14, color: Color(0xFF0D9488)),
                                                label: const Text("GRN Inward", style: TextStyle(fontSize: 11, color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF4F46E5),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                                  elevation: 2,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                onPressed: () => _handleOrderStockClick(context, alert, userRole),
                                                icon: const Icon(Icons.add_shopping_cart_rounded, size: 14),
                                                label: const Text("Order Stock", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleBatchOrderClick(BuildContext context, UserRole userRole) {
    if (!PermissionManager.canReorder(userRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⛔ Access Denied: Ordering stock requires Admin or Warehouse Manager role (${userRole.displayName} logged in)."),
          backgroundColor: const Color(0xFFBE123C),
        ),
      );
    } else {
      _showBatchOrderDialog(context);
    }
  }

  void _handleOrderStockClick(BuildContext context, AlertModel alert, UserRole userRole) {
    if (!PermissionManager.canReorder(userRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⛔ Access Denied: Ordering stock requires Admin or Warehouse Manager role (${userRole.displayName} logged in)."),
          backgroundColor: const Color(0xFFBE123C),
        ),
      );
    } else {
      _showOrderStockDialog(context, alert);
    }
  }

  Widget _filterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedFilter = key),
        selectedColor: const Color(0xFF4F46E5),
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
      ),
    );
  }

  Widget _metricCard(BuildContext context, {required String title, required String count, required Color color, required IconData icon, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color, fontFamily: "JetBrains Mono"),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            count,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }

  void _showOrderStockDialog(BuildContext context, AlertModel alert) {
    final qtyController = TextEditingController(text: "200");
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_shopping_cart_rounded, color: Color(0xFF4F46E5), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order Stock PO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Create Purchase Order to Replenish", style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("SKU Code: ${alert.skuCode ?? "N/A"}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: "JetBrains Mono")),
                  const SizedBox(height: 4),
                  Text(alert.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(alert.message, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text("Quantity to Order (Units)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixText: "Units",
              ),
            ),
            const SizedBox(height: 12),
            const Text("Preferred Supplier", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Apex Tech Electronics Ltd.", style: TextStyle(fontSize: 12)),
                  Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final poNum = "PO-2026-${DateTime.now().millisecondsSinceEpoch % 10000}";
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text("✅ Purchase Order $poNum created for ${qtyController.text} units of ${alert.skuCode ?? "SKU"}!"),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.send_rounded, size: 14),
            label: const Text("Confirm & Order Stock", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showBatchOrderDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.inventory_2_rounded, color: Color(0xFF4F46E5), size: 26),
            SizedBox(width: 10),
            Text("Batch Order Stock", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text("Are you sure you want to generate automated Purchase Orders for ALL low stock and critical deficit SKUs?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("⚡ Batch PO Generated! Purchase Orders created for all low stock items."),
                  backgroundColor: Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Confirm Batch Order", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
