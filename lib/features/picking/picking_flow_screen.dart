import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PickingFlowScreen extends ConsumerStatefulWidget {
  final String? orderId;
  const PickingFlowScreen({super.key, this.orderId});

  @override
  ConsumerState<PickingFlowScreen> createState() => _PickingFlowScreenState();
}

class _PickingFlowScreenState extends ConsumerState<PickingFlowScreen> {
  int _pickedQty = 0;
  final int _targetQty = 2;
  int _secondsElapsed = 258;
  Timer? _timer;
  String? _toastMessage;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showToast(String msg) {
    setState(() => _toastMessage = msg);
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  void _executeScan() {
    setState(() {
      if (_pickedQty < _targetQty) {
        _pickedQty++;
        if (_pickedQty == 1) {
          _showToast("ITEM 1 OF 2 VERIFIED (SKU-8824-LDR)");
        } else if (_pickedQty == 2) {
          _showToast("TARGET COMPLETE! PROCEED TO ZONE C");
        }
      } else {
        _pickedQty = 0;
        _showToast("DEMO RESET: TARGET SET TO 0/2");
      }
    });
  }

  String _formatTimer(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isComplete = _pickedQty == _targetQty;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF334155)),
          onPressed: () => context.canPop() ? context.pop() : context.go("/dashboard"),
        ),
        title: const Text(
          'Guided Picking',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 18, color: Color(0xFF4F46E5)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Dispatch Sub-header & Live Wave Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'ACTIVE DISPATCH',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
                            fontFamily: 'JetBrains Mono',
                          ),
                        ),
                        SizedBox(width: 6),
                        Text('•', style: TextStyle(color: Colors.grey)),
                        SizedBox(width: 6),
                        Text('HUB 04', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE0E7FF)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: Color(0xFF4F46E5), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimer(_secondsElapsed),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                              fontFamily: 'JetBrains Mono',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pick Wave #PW-9821',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const Text(
                  'Batch 4 Consolidated Orders (Amazon Hub)',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),

                // Multi-Zone Waypoint Indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(radius: 8, backgroundColor: Color(0xFF059669), child: Text('✓', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                            SizedBox(width: 4),
                            Text('Done', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857), fontFamily: 'JetBrains Mono')),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(radius: 8, backgroundColor: Colors.white, child: Text('B', style: TextStyle(color: Color(0xFF4F46E5), fontSize: 9, fontWeight: FontWeight.bold))),
                            SizedBox(width: 4),
                            Text('Zone B Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'JetBrains Mono')),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(radius: 8, backgroundColor: Color(0xFFCBD5E1), child: Text('C', style: TextStyle(color: Color(0xFF475569), fontSize: 9, fontWeight: FontWeight.bold))),
                            SizedBox(width: 4),
                            Text('Queue', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Wave Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Wave Completion', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                    Text(isComplete ? '100%' : '66%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontFamily: 'JetBrains Mono')),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: isComplete ? 1.0 : 0.66,
                    color: const Color(0xFF4F46E5),
                    backgroundColor: const Color(0xFFE2E8F0),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 16),

                // Main Focus Container: Current Pick Target Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFC7D2FE)),
                            ),
                            child: const Row(
                              children: [
                                CircleAvatar(radius: 3, backgroundColor: Color(0xFF4F46E5)),
                                SizedBox(width: 4),
                                Text(
                                  'CURRENT PICK TARGET',
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
                          const Row(
                            children: [
                              Icon(Icons.near_me_rounded, color: Color(0xFF4F46E5), size: 16),
                              SizedBox(width: 4),
                              Text('Tier 3 Level', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Storage Bin Telemetry Readout
                      const Row(
                        children: [
                          Icon(Icons.location_on_rounded, color: Color(0xFF4F46E5), size: 16),
                          SizedBox(width: 4),
                          Text('Storage Bin Location', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Row(
                        children: [
                          Text(
                            'Bin B-02-R1-B4',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.grid_view_rounded, color: Color(0xFF4F46E5), size: 24),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // SKU Details Container
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Icon(Icons.sensors_rounded, color: Color(0xFF4F46E5), size: 28),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'OmniSense LiDAR Depth Sensor v4',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontFamily: 'Plus Jakarta Sans'),
                                  ),
                                  Text(
                                    'SKU-8824-LDR',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontFamily: 'JetBrains Mono'),
                                  ),
                                  Text('Lot #4092-EXP27 • Fragile Optics', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Rack Visualization + Qty Stepper Grid
                      Row(
                        children: [
                          // 4-Tier Rack Diagram
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Rack B1 Matrix', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                                      Text('Bay 4', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontFamily: 'JetBrains Mono')),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(height: 10, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(3))),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 22,
                                    decoration: BoxDecoration(color: const Color(0xFF4F46E5), borderRadius: BorderRadius.circular(4)),
                                    alignment: Alignment.center,
                                    child: const Text('T3 ACTIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(height: 10, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(3))),
                                  const SizedBox(height: 4),
                                  Container(height: 10, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(3))),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Quantity Stepper
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Required Qty', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                                      Text('UNITS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0D9488), fontFamily: 'JetBrains Mono')),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '$_pickedQty',
                                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5), fontFamily: 'JetBrains Mono'),
                                      ),
                                      const Text('/', style: TextStyle(fontSize: 18, color: Colors.grey)),
                                      Text(
                                        '$_targetQty',
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontFamily: 'JetBrains Mono'),
                                      ),
                                    ],
                                  ),
                                  const Text('Tote: TOT-BLUE-09', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontFamily: 'JetBrains Mono')),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Big Operator Scan CTA Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isComplete ? const Color(0xFF059669) : const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _executeScan,
                          icon: Icon(isComplete ? Icons.check_circle_rounded : Icons.qr_code_scanner_rounded, size: 24),
                          label: Text(
                            isComplete ? '✅ Bin B-02 Finished • Next Route' : '⚡ Simulate Scan & Pick (${_pickedQty + 1}/2)',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Manifest Checklist
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('WAVE MANIFEST (3 ITEMS)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                    Text('ROUTE OPTIMIZED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontFamily: 'JetBrains Mono')),
                  ],
                ),
                const SizedBox(height: 8),

                _manifestItemCard('AGV Li-Ion Battery Pack', '1 pc', 'Bin A-01-R2-B3', 'SKU-1002', '04:02 ago', true, isDark),
                _manifestItemCard('Stepper Motor NEMA 23', '4 pcs', 'Bin A-03-R4-B1', 'SKU-7715', '02:15 ago', true, isDark),
                _manifestItemCard('Micro-Controller Cortex-M7', '5 pcs', 'Bin C-01-R1-B2', 'SKU-4091', 'UP NEXT', false, isDark),

                const SizedBox(height: 12),

                // Telemetry Cart & Weight Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.forklift, color: Color(0xFF4F46E5), size: 20),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ASSIGNED CART', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, fontFamily: 'JetBrains Mono')),
                              Text('TROLLEY-ALPHA-04', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
                            ],
                          ),
                        ],
                      ),
                      VerticalDivider(thickness: 1, width: 20),
                      Row(
                        children: [
                          Icon(Icons.scale_rounded, color: Color(0xFF0D9488), size: 20),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOTAL WEIGHT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, fontFamily: 'JetBrains Mono')),
                              Text('4.82 kg / 25 kg', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Bottom Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFFECDD3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _showToast("FLAG DISPATCHED: INVENTORY LOGGED"),
                        icon: const Icon(Icons.report_problem_rounded, color: Color(0xFFEF4444), size: 18),
                        label: const Text('Bin Mismatch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFEF4444))),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _showToast("TOTE #09: 2 ITEMS SECURED"),
                        icon: const Icon(Icons.inventory_2_outlined, color: Color(0xFF4F46E5), size: 18),
                        label: const Text('Tote Manifest', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F46E5))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Toast Message Notification Overlay
          if (_toastMessage != null)
            Positioned(
              top: 10,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _toastMessage!,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'JetBrains Mono'),
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

  Widget _manifestItemCard(String title, String qty, String bin, String sku, String time, bool isDone, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isDone ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                child: Icon(
                  isDone ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                  color: isDone ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isDone ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(qty, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isDone ? const Color(0xFF047857) : const Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                      ),
                    ],
                  ),
                  Text('$bin • $sku', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isDone ? 'VERIFIED' : 'UP NEXT',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isDone ? const Color(0xFF059669) : const Color(0xFF4F46E5), fontFamily: 'JetBrains Mono'),
              ),
              Text(time, style: const TextStyle(fontSize: 9, color: Colors.grey, fontFamily: 'JetBrains Mono')),
            ],
          ),
        ],
      ),
    );
  }
}
