import '../../domain/models/user_model.dart';
import '../../core/permissions/permission_manager.dart';
import '../../shared/widgets/user_profile_menu.dart';
import '../../domain/models/movement_log_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/app_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _tickerIndex = 0;
  final List<String> _tickerLogs = [
    'AGV #02 transferred SKU-1002 to Zone B • Conveyor Belt C: 98.4% Eff • Inbound Dock: Truck #IND-44 Arrived',
    'Batch #104 Pick Confirmed • Pallet Jack #07 Assigned to Lane 4 • Temperature Normal (4.2°C)',
    'Autonomous Drone Yard Scan Complete • 100% SKU Verification • Zero discrepancies flagged',
  ];

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final userRole = ref.watch(userRoleProvider);
        final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.9),
        elevation: 0,
        title: Row(
          children: [
            // Logo Image / Icon
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
                  'Dashboard',
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
            icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            tooltip: 'Low Stock Alerts',
            onPressed: () => context.go('/alerts'),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: Color(0xFF6366F1)),
            tooltip: 'Executive Analytics',
            onPressed: () => context.go('/analytics'),
          ),
          IconButton(
            icon: const Icon(Icons.history_edu_rounded, color: Color(0xFF8B5CF6)),
            tooltip: 'Audit Ledger Log',
            onPressed: () => context.go('/audit-history'),
          ),
          InkWell(
            onTap: () => UserProfileMenu.showProfileSheet(context, ref),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4F46E5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 18, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    'ADM',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ),
              ],
            ),
          ),
          ), 
        ]
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HUB.SYNC Telemetry Ticker Banner
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E7FF)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E7FF)),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(radius: 3, backgroundColor: Color(0xFF4F46E5)),
                        SizedBox(width: 4),
                        Text(
                          'HUB.SYNC',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
                            fontFamily: 'JetBrains Mono',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _tickerLogs[_tickerIndex],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sync_rounded, size: 16, color: Color(0xFF64748B)),
                    onPressed: () {
                      setState(() {
                        _tickerIndex = (_tickerIndex + 1) % _tickerLogs.length;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Main Facility Info Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E7FF)),
                    ),
                    child: const Icon(Icons.hub_rounded, color: Color(0xFF4F46E5), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'FACILITY 04 • BAY D',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                letterSpacing: 0.8,
                                fontFamily: 'JetBrains Mono',
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                border: Border.all(color: const Color(0xFFA7F3D0)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'ONLINE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF047857),
                                  fontFamily: 'JetBrains Mono',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Main Automated Hub',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'SHIFT #02',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          fontFamily: 'JetBrains Mono',
                        ),
                      ),
                      const Text(
                        '06:42:19',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
                          fontFamily: 'JetBrains Mono',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2x2 Metric Cards Grid
            metricsAsync.when(
              data: (data) => GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.45,
                children: [
                  _stitchMetricCard(
                    context,
                    onTap: () => context.go('/inventory'),
                    title: 'TOTAL SKUs',
                    icon: Icons.category_rounded,
                    iconBg: const Color(0xFFEEF2FF),
                    iconColor: const Color(0xFF4F46E5),
                    value: '${data["totalSkus"]}',
                    footerText: '+4 today',
                    footerIcon: Icons.arrow_upward_rounded,
                    footerColor: const Color(0xFF059669),
                    tagText: 'CAT-A',
                    tagBg: const Color(0xFFEEF2FF),
                    tagColor: const Color(0xFF4F46E5),
                    isDark: isDark,
                  ),
                  _stitchMetricCard(
                    context,
                    onTap: () => context.go('/inventory'),
                    title: 'STOCK UNITS',
                    icon: Icons.layers_rounded,
                    iconBg: const Color(0xFFCCFBF1),
                    iconColor: const Color(0xFF0D9488),
                    value: '42.8k',
                    footerText: '99.2%',
                    footerIcon: Icons.verified_rounded,
                    footerColor: const Color(0xFF0F766E),
                    tagText: 'AUDITED',
                    tagBg: const Color(0xFFCCFBF1),
                    tagColor: const Color(0xFF0F766E),
                    isDark: isDark,
                  ),
                  _stitchMetricCard(
                    context,
                    onTap: () => context.go('/alerts'),
                    title: 'LOW ALERTS',
                    icon: Icons.warning_rounded,
                    iconBg: const Color(0xFFFFE4E6),
                    iconColor: const Color(0xFFEF4444),
                    value: '${data["lowStockCount"]}',
                    valueColor: const Color(0xFFEF4444),
                    footerText: 'Critical',
                    footerIcon: Icons.circle,
                    footerColor: const Color(0xFFEF4444),
                    tagText: 'REQ #18',
                    tagBg: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                    tagColor: isDark ? Colors.white60 : const Color(0xFF64748B),
                    isDark: isDark,
                  ),
                  _stitchMetricCard(
                    context,
                    onTap: () => context.go('/inward'),
                    title: 'PENDING INBOUND',
                    icon: Icons.local_shipping_rounded,
                    iconBg: const Color(0xFFE0F2FE),
                    iconColor: const Color(0xFF0284C7),
                    value: '${data["pendingInbound"]}',
                    footerText: 'Dock 2 & 4',
                    footerColor: isDark ? Colors.white70 : const Color(0xFF334155),
                    tagText: 'ACTIVE',
                    tagBg: const Color(0xFFCCFBF1),
                    tagColor: const Color(0xFF0F766E),
                    isDark: isDark,
                  ),
                ],
              ),
              loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              error: (err, s) => const Text('Error loading metrics'),
            ),
            const SizedBox(height: 12),

            // Radial Capacity Gauge Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.donut_large_rounded, color: Color(0xFF0D9488), size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Radial Capacity Gauge',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFBF1),
                          border: Border.all(color: const Color(0xFF99F6E4)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '2,400 / 3,060 BINS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D9488),
                            fontFamily: 'JetBrains Mono',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // Radial Arc SVG Mockup
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 90,
                              height: 90,
                              child: CircularProgressIndicator(
                                value: 0.784,
                                strokeWidth: 10,
                                backgroundColor: const Color(0xFFF1F5F9),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                              ),
                            ),
                            const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '78.4%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'JetBrains Mono',
                                  ),
                                ),
                                Text(
                                  'Occupied',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Zone Progress Rows
                      Expanded(
                        child: Column(
                          children: [
                            _zoneProgressRow('Zone A (High Velocity)', 0.89, const Color(0xFFF43F5E), isDark),
                            const SizedBox(height: 8),
                            _zoneProgressRow('Zone B (Electronics)', 0.74, const Color(0xFF0D9488), isDark),
                            const SizedBox(height: 8),
                            _zoneProgressRow('Zone C (Cold FMCG)', 0.65, const Color(0xFF0284C7), isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Operational Commands
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'OPERATIONAL COMMANDS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const Text(
                  'THUMB DOCK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D9488),
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _actionButton(context, Icons.warning_amber_rounded, 'Low Alerts', const Color(0xFFEF4444), () => context.go('/alerts'), isDark),
                  _actionButton(context, Icons.bar_chart_rounded, 'Analytics', const Color(0xFF6366F1), () => context.go('/analytics'), isDark),
                  _actionButton(context, Icons.history_edu_rounded, 'Audit History', const Color(0xFF8B5CF6), () => context.go('/audit-history'), isDark),
                  _actionButton(context, Icons.qr_code_scanner_rounded, 'Scan Barcode', const Color(0xFF0D9488), () => context.go('/scanner'), isDark),
                  _actionButton(context, Icons.input_rounded, 'GRN Inward', const Color(0xFF4F46E5), () {
                    if (!PermissionManager.canPerformInward(userRole)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('⛔ Access Denied: GRN Inward requires Admin or Warehouse Manager role (${userRole.displayName} logged in).'),
                          backgroundColor: const Color(0xFFBE123C),
                        ),
                      );
                    } else {
                      context.go('/inward');
                    }
                  }, isDark),
                  _actionButton(context, Icons.local_shipping_rounded, 'Dispatch', const Color(0xFF059669), () {
                    if (!PermissionManager.canPerformDispatch(userRole)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('⛔ Access Denied: Dispatch Board operations require Admin, Manager, or Dispatcher role (${userRole.displayName} logged in).'),
                          backgroundColor: const Color(0xFFBE123C),
                        ),
                      );
                    } else {
                      context.go('/dispatch');
                    }
                  }, isDark),
                  _actionButton(context, Icons.alt_route_rounded, 'Pick Route', const Color(0xFF0D9488), () {
                    if (!PermissionManager.canPickOrders(userRole)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('⛔ Access Denied: Picking workflow requires Admin, Manager, or Picker role (${userRole.displayName} logged in).'),
                          backgroundColor: const Color(0xFFBE123C),
                        ),
                      );
                    } else {
                      context.go('/picking');
                    }
                  }, isDark),
                  _actionButton(context, Icons.map_rounded, 'Floor Map', const Color(0xFF4F46E5), () => context.go('/location-map'), isDark),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // AI Predictive Telemetry
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.smart_toy_rounded, color: Color(0xFF4F46E5), size: 18),
                    SizedBox(width: 6),
                    Text(
                      'AI Predictive Telemetry',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF4F46E5), shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFCBD5E1), shape: BoxShape.circle)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Telemetry Card 1
                  Container(
                    width: 310,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECDD3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE4E6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.emergency_rounded, color: Color(0xFFEF4444), size: 16),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CRITICAL STOCKOUT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEF4444),
                                      fontFamily: 'JetBrains Mono',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'SKU-4091 (Lithium 3.7V)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE4E6),
                                border: Border.all(color: const Color(0xFFFECDD3)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '18H ETA',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEF4444),
                                  fontFamily: 'JetBrains Mono',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Depletion in 18 hrs based on order velocity spike. Recommend automated purchase order dispatch.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF4444),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => _showAutoReorderModal(context, ref),
                                child: const Text('Auto-Reorder', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFFECDD3)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {},
                              child: const Text('Dismiss', style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

// Telemetry Card 2
                  Container(
                    width: 310,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.bolt_rounded, color: Color(0xFF0D9488), size: 16),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ROUTE OPTIMIZATION',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D9488),
                                      fontFamily: 'JetBrains Mono',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'AGV Fleet Batch #84',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                border: Border.all(color: const Color(0xFFBBF7D0)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D9488),
                                  fontFamily: 'JetBrains Mono',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pathing rerouted around Sector-02 maintenance. Travel time reduced by 14.2%.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D9488),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => context.go('/location-map'),
                                child: const Text('View Pathing', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFBBF7D0)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {},
                              child: const Text('Details', style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Autonomous Fleet Status
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Icon(Icons.precision_manufacturing_rounded, color: Color(0xFF059669), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Autonomous Fleet Status',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        Text(
                          '8 AGVs Active • 0 Idle faults',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Row(
                    children: [
                      Text(
                        '100%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF059669),
                          fontFamily: 'JetBrains Mono',
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stitchMetricCard(
    BuildContext context, {
    VoidCallback? onTap,
    required String title,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    Color? valueColor,
    required String footerText,
    IconData? footerIcon,
    required Color footerColor,
    required String tagText,
    required Color tagBg,
    required Color tagColor,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  fontFamily: 'JetBrains Mono',
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
              fontFamily: 'JetBrains Mono',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (footerIcon != null) ...[
                    Icon(footerIcon, size: 12, color: footerColor),
                    const SizedBox(width: 2),
                  ],
                  Text(
                    footerText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: footerColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tagText,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: tagColor,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _zoneProgressRow(String label, double val, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white70 : const Color(0xFF334155),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(val * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: val,
            color: color,
            backgroundColor: const Color(0xFFF1F5F9),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          foregroundColor: const Color(0xFF334155),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  void _showAutoReorderModal(BuildContext context, WidgetRef ref) {
    final userRole = ref.read(userRoleProvider);
    if (!PermissionManager.canReorder(userRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⛔ Access Denied: Reorder & PO issuance is restricted to Admin or Warehouse Manager role (${userRole.displayName} logged in).'),
          backgroundColor: const Color(0xFFBE123C),
        ),
      );
      return;
    }
    final qtyController = TextEditingController(text: '250');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final qty = int.tryParse(qtyController.text) ?? 250;
            final totalCost = qty * 1450;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Color(0xFFEF4444), size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Auto-Reorder Purchase Order', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text('SKU-4091 • Smart Lithium Battery Pack', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: const Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Current Stock:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text('4 units (CRITICAL LOW)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Preferred Vendor:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text('Reliance Power Systems', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Unit Rate:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text('₹1,450 / unit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Reorder Quantity (Units):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setModalState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated PO Value:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                          Text('₹' + totalCost.toString(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF047857), fontFamily: 'JetBrains Mono')),
                        ],
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
                    final auditRepo = ref.read(auditRepositoryProvider);
                    await auditRepo.addAuditLog(
                      MovementLogModel(
                        id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
                        timestamp: DateTime.now(),
                        type: MovementType.inward,
                        skuId: 'SKU-4091',
                        skuCode: 'SKU-4091',
                        skuName: 'Smart Lithium Battery Pack 3.7V',
                        quantity: qty,
                        beforeQty: 4,
                        afterQty: 4 + qty,
                        fromLocation: 'Reliance Power Systems Ltd',
                        toLocation: 'Zone A-01-R-2-B-7',
                        performedBy: 'admin@stocksense.io',
                        referenceNumber: 'PO-2026-8891',
                        device: 'Dashboard Terminal',
                      ),
                    );
                    ref.invalidate(dashboardMetricsProvider);
                    if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('⚡ Purchase Order #PO-2026-8891 issued for $qty units to Reliance Power Systems!'),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    }
                  },
                  child: const Text('Confirm & Issue PO', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

}