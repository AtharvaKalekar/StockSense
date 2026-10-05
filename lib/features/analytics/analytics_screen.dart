import '../../domain/models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/permissions/permission_manager.dart';
import '../../core/utils/pdf_generator.dart';
import '../../shared/providers/app_providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userRoleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!PermissionManager.canViewAnalytics(userRole)) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Executive Analytics'),
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_rounded, size: 64, color: Color(0xFFF43F5E)),
                const SizedBox(height: 16),
                const Text('Access Restricted', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Executive Analytics is restricted to Warehouse Manager & Admin roles (${userRole.displayName} logged in).',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                  onPressed: () => context.go('/dashboard'),
                  icon: const Icon(Icons.dashboard_rounded),
                  label: const Text('Return to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF6366F1), size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Executive Analytics & BI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Inventory Valuation, Velocity & Capacity Intelligence',
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
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444)),
            tooltip: 'Export Executive PDF Report',
            onPressed: () async {
              final pdfBytes = await PdfReportGenerator.generateInventoryReport([
                {'name': 'Samsung Galaxy S24 Ultra', 'sku': 'ELE-SAM-001', 'qty': 45, 'price': 129999.0},
                {'name': 'Amul Butter 500g', 'sku': 'FMC-AMU-002', 'qty': 12, 'price': 275.0},
                {'name': 'Lithium Battery Pack 3.7V', 'sku': 'SKU-4091', 'qty': 4, 'price': 1450.0},
              ]);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('📄 Executive PDF Report Exported Successfully (${pdfBytes.length} bytes)!'),
                    backgroundColor: const Color(0xFF059669),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Cards Grid
            Row(
              children: [
                Expanded(
                  child: _kpiSummaryCard(
                    title: 'VALUATION',
                    value: '₹4.82 Cr',
                    subtext: '+12.4% MoM',
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFF10B981),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _kpiSummaryCard(
                    title: 'DISPATCHES',
                    value: '1,482',
                    subtext: '98.5% On-Time',
                    icon: Icons.local_shipping_rounded,
                    color: const Color(0xFF6366F1),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _kpiSummaryCard(
                    title: 'ACCURACY',
                    value: '99.8%',
                    subtext: 'Audited Weekly',
                    icon: Icons.verified_user_rounded,
                    color: const Color(0xFF0D9488),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Valuation Trend Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock Valuation Trajectory (₹ Lakhs)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text('H2 2026', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: const FlTitlesData(
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(1, 320),
                              FlSpot(2, 380),
                              FlSpot(3, 410),
                              FlSpot(4, 440),
                              FlSpot(5, 465),
                              FlSpot(6, 482),
                            ],
                            isCurved: true,
                            color: const Color(0xFF4F46E5),
                            barWidth: 3.5,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Inbound vs Outbound Velocity
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      const Text(
                        'Inbound vs Outbound Monthly Volume',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _legendDot(const Color(0xFF0D9488), 'GRN Inward'),
                          const SizedBox(width: 8),
                          _legendDot(const Color(0xFF6366F1), 'Outward Dispatch'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        barGroups: [
                          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 340, color: const Color(0xFF0D9488), width: 12), BarChartRodData(toY: 290, color: const Color(0xFF6366F1), width: 12)]),
                          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 410, color: const Color(0xFF0D9488), width: 12), BarChartRodData(toY: 380, color: const Color(0xFF6366F1), width: 12)]),
                          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 450, color: const Color(0xFF0D9488), width: 12), BarChartRodData(toY: 430, color: const Color(0xFF6366F1), width: 12)]),
                          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 520, color: const Color(0xFF0D9488), width: 12), BarChartRodData(toY: 490, color: const Color(0xFF6366F1), width: 12)]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Top Fast Moving SKUs Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Top Fast-Moving SKUs Performance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _skuRow('1', 'Samsung Galaxy S24 Ultra', 'ELE-SAM-001', '420 units/mo', 'Zone B', const Color(0xFF10B981), isDark),
                  const Divider(height: 16),
                  _skuRow('2', 'Fortune Sunlite Oil 1L', 'FMC-FOR-009', '380 units/mo', 'Zone C', const Color(0xFF3B82F6), isDark),
                  const Divider(height: 16),
                  _skuRow('3', 'Parle-G Gold Biscuit 100g', 'FMC-PAR-012', '310 units/mo', 'Zone C', const Color(0xFF8B5CF6), isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiSummaryCard({required String title, required String value, required String subtext, required IconData icon, required Color color, required bool isDark}) {
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
              Text(title, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color, fontFamily: 'JetBrains Mono')),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
          Text(subtext, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _skuRow(String rank, String name, String code, String velocity, String zone, Color accent, bool isDark) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Text(rank, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: accent)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
              Text('$code • Location: $zone', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(velocity, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: accent, fontFamily: 'JetBrains Mono')),
        ),
      ],
    );
  }
}
