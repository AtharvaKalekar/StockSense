import '../../domain/models/user_model.dart';
import '../../core/permissions/permission_manager.dart';
import '../../shared/widgets/user_profile_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/pdf_generator.dart';
import '../../domain/models/order_model.dart';
import '../../shared/providers/app_providers.dart';

class DispatchScreen extends ConsumerStatefulWidget {
  const DispatchScreen({super.key});

  @override
  ConsumerState<DispatchScreen> createState() => _DispatchScreenState();
}

class _DispatchScreenState extends ConsumerState<DispatchScreen> {
  String _activeTab = 'to-pack'; // 'to-pack', 'packed', 'dispatched'
  String _activeTerminal = 'TERMINAL D-04';
  bool _isAutoSyncing = true;
  String? _toastMessage;

  void _showToast(String msg) {
    setState(() => _toastMessage = msg);
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  void _showTerminalPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final terminals = ['TERMINAL D-01', 'TERMINAL D-02', 'TERMINAL D-04', 'AIR CARGO BAY 3'];
        return Container(
          padding: const EdgeInsets.all(20),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Active Dispatch Terminal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...terminals.map(
                (t) => ListTile(
                  leading: Icon(Icons.dns_rounded, color: _activeTerminal == t ? const Color(0xFF4F46E5) : Colors.grey),
                  title: Text(t, style: TextStyle(fontWeight: _activeTerminal == t ? FontWeight.bold : FontWeight.normal)),
                  trailing: _activeTerminal == t ? const Icon(Icons.check_circle_rounded, color: Color(0xFF4F46E5)) : null,
                  onTap: () {
                    setState(() => _activeTerminal = t);
                    Navigator.pop(ctx);
                    _showToast('Switched terminal to $t');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDispatchDialog(OrderModel order) {
    final courierController = TextEditingController(text: order.courierName ?? 'BlueDart Express Priority Air');
    final trackingController = TextEditingController(text: order.trackingNumber ?? 'TRK-${100000 + DateTime.now().millisecond * 77}');
    final vehicleController = TextEditingController(text: order.vehicleNumber ?? 'KA-05-EV-${10 + DateTime.now().second}');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.local_shipping_rounded, color: Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              Text('Dispatch Order ${order.orderNumber}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: ${order.customerName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                const Text('Courier Provider:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: courierController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.badge_outlined, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('AWB / Tracking Number:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: trackingController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.qr_code_2_rounded, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Dispatch Vehicle Number:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: vehicleController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.directions_bus_rounded, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final repo = ref.read(orderRepositoryProvider);
                await repo.assignDispatchDetails(
                  order.id,
                  courierController.text,
                  trackingController.text,
                  vehicleController.text,
                );
                ref.invalidate(ordersListProvider);
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                if (mounted) {
                  _showToast('🚀 Order ${order.orderNumber} Dispatched via ${courierController.text}!');
                  await PdfReportGenerator.generateDispatchNote(order.orderNumber, order.customerName, []);
                }
              },
              child: const Text('Confirm & Dispatch', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersListProvider);
    final userRole = ref.watch(userRoleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canDispatch = PermissionManager.canPerformDispatch(userRole);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
        ),
        backgroundColor: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.9),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.hub_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'STOCKSENSE',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(radius: 3, backgroundColor: Color(0xFF10B981)),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Color(0xFF047857),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'JetBrains Mono',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  'Dispatch Board',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF64748B)),
            onPressed: () => context.go('/alerts'),
          ),
          const UserProfileMenu(),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Sub-bar: Terminal Identifier & Auto-Sync Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: _showTerminalPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(radius: 4, backgroundColor: Color(0xFF4F46E5)),
                            const SizedBox(width: 6),
                            Text(
                              _activeTerminal,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF334155), fontFamily: 'JetBrains Mono'),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() => _isAutoSyncing = !_isAutoSyncing);
                        _showToast(_isAutoSyncing ? '⚡ Auto-Sync Active (120ms)' : '⏸️ Auto-Sync Paused');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _isAutoSyncing ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.bolt_rounded, color: _isAutoSyncing ? const Color(0xFF059669) : Colors.grey, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _isAutoSyncing ? 'AUTO-SYNC 120ms' : 'SYNC PAUSED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _isAutoSyncing ? const Color(0xFF047857) : Colors.grey,
                                fontFamily: 'JetBrains Mono',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (!canDispatch) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECDD3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.gpp_maybe_rounded, color: Color(0xFFE11D48), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Access Restriction: Dispatch board actions are disabled for ${userRole.displayName}. Required: Admin, Warehouse Manager, or Dispatcher role.',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFBE123C)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Segmented Kanban Tab Switcher
                ordersAsync.when(
                  data: (allOrders) {
                    final toPackList = allOrders.where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.picking).toList();
                    final packedList = allOrders.where((o) => o.status == OrderStatus.packed).toList();
                    final dispatchedList = allOrders.where((o) => o.status == OrderStatus.dispatched).toList();

                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          _kanbanTab('To Pack', '${toPackList.length}', 'to-pack', isDark),
                          _kanbanTab('Packed', '${packedList.length}', 'packed', isDark),
                          _kanbanTab('Dispatched', '${dispatchedList.length}', 'dispatched', isDark),
                        ],
                      ),
                    );
                  },
                  loading: () => Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _kanbanTab('To Pack', '...', 'to-pack', isDark),
                        _kanbanTab('Packed', '...', 'packed', isDark),
                        _kanbanTab('Dispatched', '...', 'dispatched', isDark),
                      ],
                    ),
                  ),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 16),

                // Cards Stream Filtered by Tab
                ordersAsync.when(
                  data: (allOrders) {
                    List<OrderModel> activeOrders = [];
                    if (_activeTab == 'to-pack') {
                      activeOrders = allOrders.where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.picking).toList();
                    } else if (_activeTab == 'packed') {
                      activeOrders = allOrders.where((o) => o.status == OrderStatus.packed).toList();
                    } else if (_activeTab == 'dispatched') {
                      activeOrders = allOrders.where((o) => o.status == OrderStatus.dispatched).toList();
                    }

                    if (activeOrders.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Icon(Icons.inbox_rounded, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              'No orders in ${_activeTab.toUpperCase()} status',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF475569)),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: activeOrders.map((order) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _stitchOrderCard(context, order, isDark),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
                const SizedBox(height: 16),

                // Operational Telemetry Overview Widget
                ordersAsync.when(
                  data: (orders) {
                    final dispatchedCount = orders.where((o) => o.status == OrderStatus.dispatched).length;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.conveyor_belt, color: Color(0xFF4F46E5), size: 24),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Today's Outward", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text('${dispatchedCount + 12}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'JetBrains Mono')),
                                      const SizedBox(width: 4),
                                      const Text('orders', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('On-Time SLA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                              Row(
                                children: [
                                  CircleAvatar(radius: 4, backgroundColor: Color(0xFF059669)),
                                  SizedBox(width: 4),
                                  Text('99.4%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF059669), fontFamily: 'JetBrains Mono')),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 12),

                // Station Barcode Scanner Target
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF4F46E5), size: 18),
                          SizedBox(width: 8),
                          Text('Ready to scan package barcode...', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                        ],
                      ),
                      InkWell(
                        onTap: () => context.go('/scanner'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('SCAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'JetBrains Mono')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Toast Overlay Notification
          if (_toastMessage != null)
            Positioned(
              top: 10,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _toastMessage!,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'JetBrains Mono'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _kanbanTab(String title, String count, String key, bool isDark) {
    final isSelected = _activeTab == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? const Color(0xFF0F172A) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF334155),
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stitchOrderCard(BuildContext context, OrderModel order, bool isDark) {
    final userRole = ref.watch(userRoleProvider);
    final canDispatch = PermissionManager.canPerformDispatch(userRole);
    final itemsSummary = order.items.map((i) => '${i.skuName} (x${i.expectedQty})').join(', ');
    final itemCountText = '${order.items.length} item${order.items.length > 1 ? "s" : ""}';
    final isUrgent = order.customerName.contains('TechNova') || order.orderNumber.contains('8942');
    final isCold = order.customerName.contains('BioMed') || order.orderNumber.contains('8940');

    Color slaColor = const Color(0xFF64748B);
    String slaText = '2h 15m SLA';
    String tagText = 'Standard Surface';

    if (isUrgent) {
      slaColor = const Color(0xFFEF4444);
      slaText = '42m SLA';
      tagText = 'Express Air';
    } else if (isCold) {
      slaColor = const Color(0xFF0284C7);
      slaText = 'COLD VERIFIED';
      tagText = '-20°C Temp Lock';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(order.orderNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontFamily: 'JetBrains Mono')),
                      if (isUrgent) ...[
                        const SizedBox(width: 6),
                        const CircleAvatar(radius: 3, backgroundColor: Color(0xFFEF4444)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(order.customerName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A), fontFamily: 'Plus Jakarta Sans')),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Expanded(child: Text(order.shippingAddress, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: slaColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: slaColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(isCold ? Icons.ac_unit_rounded : Icons.bolt_rounded, size: 12, color: slaColor),
                        const SizedBox(width: 4),
                        Text(slaText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: slaColor, fontFamily: 'JetBrains Mono')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(tagText, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: slaColor, fontFamily: 'JetBrains Mono')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Payload Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(isCold ? Icons.science_rounded : Icons.memory_rounded, color: const Color(0xFF4F46E5), size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              itemsSummary.isEmpty ? 'Industrial Components Package' : itemsSummary,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Text(itemCountText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.scale_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text('4.2 KG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xFF4F46E5)),
                        const SizedBox(width: 4),
                        Text(
                          order.courierName ?? 'BlueDart Express Priority',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5), fontFamily: 'JetBrains Mono'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Primary CTA Button based on Active Tab
          if (_activeTab == 'to-pack')
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: !canDispatch ? null : () async {
                  final repo = ref.read(orderRepositoryProvider);
                  await repo.updateOrderStatus(order.id, OrderStatus.packed);
                  ref.invalidate(ordersListProvider);
                  _showToast('📦 Order ${order.orderNumber} Packed & Verified!');
                  await PdfReportGenerator.generateDispatchNote(order.orderNumber, order.customerName, []);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Pack Order & Generate Manifest', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          else if (_activeTab == 'packed')
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: !canDispatch ? null : () => _showDispatchDialog(order),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_shipping_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Assign Courier & Dispatch', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4F46E5),
                  side: const BorderSide(color: Color(0xFF4F46E5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  _showToast('📄 Downloading Manifest PDF for ${order.orderNumber}...');
                  await PdfReportGenerator.generateDispatchNote(order.orderNumber, order.customerName, []);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf_rounded, size: 18, color: Color(0xFF4F46E5)),
                    SizedBox(width: 8),
                    Text('Download & Print Manifest PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
