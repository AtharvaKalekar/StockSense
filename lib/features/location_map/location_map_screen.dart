import '../../shared/widgets/user_profile_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LocationMapScreen extends ConsumerStatefulWidget {
  const LocationMapScreen({super.key});

  @override
  ConsumerState<LocationMapScreen> createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends ConsumerState<LocationMapScreen> {
  String _selectedDeck = 'Floor 1: Main Deck';
  String _selectedLayer = 'occupancy'; // 'occupancy', 'agv', 'temp'
  String _selectedRack = 'RACK B2-R1';
  bool _isTiersMinimized = false;
  String? _toastMessage;

  void _showToast(String msg) {
    setState(() => _toastMessage = msg);
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  void _selectDeck(String deck) {
    setState(() {
      _selectedDeck = deck;
      if (deck.contains('Floor 2')) {
        _selectedRack = 'SORT-01';
      } else {
        _selectedRack = 'RACK B2-R1';
      }
    });
    _showToast('Switched map view to $deck');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFloor2 = _selectedDeck.contains('Floor 2');

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
                  'Floor Map Deck',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Floor Switcher & Nodes Count
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                Icon(
                                  isFloor2 ? Icons.stairs_rounded : Icons.layers_rounded,
                                  color: const Color(0xFF4F46E5),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedDeck,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                              ],
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF64748B)),
                              onSelected: _selectDeck,
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'Floor 1: Main Deck', child: Text('Floor 1: Main Warehouse Deck')),
                                const PopupMenuItem(value: 'Floor 2: Mezzanine', child: Text('Floor 2: Mezzanine Logistics')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.hub_rounded, color: Color(0xFF059669), size: 18),
                          const SizedBox(width: 4),
                          Text(
                            isFloor2 ? '16/16 ' : '24/24 ',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono'),
                          ),
                          const Text('NODES', style: TextStyle(fontSize: 10, color: Color(0xFF059669), fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Layer Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _layerChip('occupancy', 'Heatmap: Occupancy', Icons.grid_goldenratio_rounded),
                      _layerChip('agv', 'AGV Routes', Icons.precision_manufacturing_rounded),
                      _layerChip('temp', 'Temp Sensors', Icons.device_thermostat_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Interactive 2D Floor Map Canvas
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 380,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : (isFloor2 ? const Color(0xFFF0FDF4) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : (isFloor2 ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0))),
                  ),
                  child: Stack(
                    children: [
                      // HUD Overlay Corner Text
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isFloor2 ? 'SECTOR-02 // MEZZANINE LOGISTICS' : 'SECTOR-01 // MAIN WAREHOUSE DECK',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isFloor2 ? const Color(0xFF059669) : const Color(0xFF4F46E5),
                                fontFamily: 'JetBrains Mono',
                              ),
                            ),
                            Text(
                              isFloor2 ? 'ELEVATION: +5.4m | DECK B-MEZZ' : 'LOC: GPS: 37.8N 122.2W | GROUND LEVEL',
                              style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono'),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Row(
                            children: [
                              CircleAvatar(radius: 3, backgroundColor: Color(0xFF10B981)),
                              SizedBox(width: 4),
                              Text('SYNC 100ms', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF334155), fontFamily: 'JetBrains Mono')),
                            ],
                          ),
                        ),
                      ),

                      // Layer Overlay Info Banner
                      if (_selectedLayer == 'agv')
                        Positioned(
                          top: 48,
                          left: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5).withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.precision_manufacturing_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    isFloor2
                                        ? '🤖 AGV-M1: Active on Sortation Belt | AGV-M2: Micro-Bin Robotics Station'
                                        : '🤖 AGV-01: En Route to Central Aisle | AGV-02: Docked at Dispatch Bay 1',
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'JetBrains Mono'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_selectedLayer == 'temp')
                        Positioned(
                          top: 48,
                          left: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0891B2).withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.thermostat_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    isFloor2
                                        ? '🌡️ Mezzanine Climate: Sortation 24.1°C | Robotics 23.8°C | QC Hold 22.0°C'
                                        : '🌡️ Ground Climate: Central Aisle 21.4°C | Cold Pod 2.1°C (NORMAL) | East Wing 22.5°C',
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'JetBrains Mono'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Interactive 2D Grid Layout Graphic
                      Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: isFloor2
                                ? [
                                    // FLOOR 2 MEZZANINE ZONES
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _zoneBlock(
                                          context,
                                          'ZONE M1: SORTATION HUB',
                                          '88% HIGH SPEED',
                                          const Color(0xFFFEF3C7),
                                          const Color(0xFFD97706),
                                          ['SORT-01', 'SORT-02', 'SORT-03', 'SORT-04'],
                                        ),
                                        const SizedBox(width: 12),
                                        _zoneBlock(
                                          context,
                                          'ZONE M2: MICRO-BIN ROBOTICS',
                                          '94% ROBOT ACTIVE',
                                          const Color(0xFFEEF2FF),
                                          const Color(0xFF4F46E5),
                                          ['MBIN-M1', 'MBIN-M2', 'MBIN-M3', 'MBIN-M4'],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _zoneBlock(
                                          context,
                                          'ZONE M3: KITTING & PACK',
                                          '52% PACKING STAGE',
                                          const Color(0xFFCCFBF1),
                                          const Color(0xFF0D9488),
                                          ['KIT-01', 'KIT-02', 'KIT-03'],
                                        ),
                                        const SizedBox(width: 12),
                                        _zoneBlock(
                                          context,
                                          'ZONE M4: RETURNS & RMA QC',
                                          '28% QC HOLDING',
                                          const Color(0xFFFFE4E6),
                                          const Color(0xFFE11D48),
                                          ['RMA-01', 'QC-HOLD-1', 'QC-HOLD-2'],
                                        ),
                                      ],
                                    ),
                                  ]
                                : [
                                    // FLOOR 1 MAIN DECK ZONES
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _zoneBlock(
                                          context,
                                          'ZONE B: CENTRAL AISLE',
                                          '74% OPTIMAL LOAD',
                                          const Color(0xFFEEF2FF),
                                          const Color(0xFF4F46E5),
                                          ['RACK B1-R1', 'RACK B1-R2', 'RACK B2-R1', 'RACK B2-R2'],
                                        ),
                                        const SizedBox(width: 12),
                                        _zoneBlock(
                                          context,
                                          'ZONE A: EAST WING',
                                          '91% OCCUPIED',
                                          const Color(0xFFFFE4E6),
                                          const Color(0xFFEF4444),
                                          ['BAY A-01', 'BAY A-02', 'BAY A-03', 'BAY A-04'],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _zoneBlock(
                                          context,
                                          'ZONE C: COLD CRYOPOD',
                                          '2.1°C • 65% CAP',
                                          const Color(0xFFECFEFF),
                                          const Color(0xFF0891B2),
                                          ['COLD-01', 'COLD-02', 'COLD-03'],
                                        ),
                                        const SizedBox(width: 12),
                                        _zoneBlock(
                                          context,
                                          'ZONE D: DISPATCH BAY',
                                          '35% CLEAR',
                                          const Color(0xFFECFDF5),
                                          const Color(0xFF059669),
                                          ['BAY 01 TRUCK', 'BAY 02 STAGE', 'BAY 03 STAGE'],
                                        ),
                                      ],
                                    ),
                                  ],
                          ),
                        ),
                      ),

                      // Bottom Map Legend
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Row(
                            children: [
                              CircleAvatar(radius: 4, backgroundColor: Color(0xFFEF4444)),
                              SizedBox(width: 4),
                              Text('90%+ ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
                              SizedBox(width: 6),
                              CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
                              SizedBox(width: 4),
                              Text('OPT ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
                              SizedBox(width: 6),
                              CircleAvatar(radius: 4, backgroundColor: Color(0xFF06B6D4)),
                              SizedBox(width: 4),
                              Text('FREE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
                            ],
                          ),
                        ),
                      ),

                      // Zoom Control Buttons
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.zoom_in_rounded, size: 18),
                                onPressed: () => _showToast('Zoom factor 1.25x'),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.zoom_out_rounded, size: 18),
                                onPressed: () => _showToast('Zoom factor 1.0x'),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.filter_center_focus_rounded, color: Color(0xFF4F46E5), size: 18),
                                onPressed: () => _showToast('Viewport centered to $_selectedRack'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Slide-Up Rack Detail Sheet
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
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Row(
                                children: [
                                  Text(
                                    _selectedRack,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      fontFamily: 'JetBrains Mono',
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isFloor2 ? const Color(0xFFFEF3C7) : const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isFloor2 ? 'MEZZANINE DECK' : 'MAIN WAREHOUSE AISLE',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isFloor2 ? const Color(0xFFD97706) : const Color(0xFF4F46E5),
                                        fontFamily: 'JetBrains Mono',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isFloor2
                                    ? 'High-Speed Automated Logistics & Micro-Bins'
                                    : 'High Velocity Consumer Electronics & Bulk Storage',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.my_location_rounded, color: Color(0xFF4F46E5), size: 18),
                                onPressed: () => _showToast('Location pinned to $_selectedRack'),
                              ),
                              IconButton(
                                icon: Icon(_isTiersMinimized ? Icons.unfold_more_rounded : Icons.unfold_less_rounded, color: const Color(0xFF64748B), size: 18),
                                onPressed: () => setState(() => _isTiersMinimized = !_isTiersMinimized),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Metrics Pill Row
                      Row(
                        children: [
                          _rackMetricPill(
                            'CAPACITY',
                            isFloor2 ? '62%' : '88%',
                            isFloor2 ? '25/40 Bins' : '35/40 Bins',
                            Icons.pie_chart_rounded,
                            isFloor2 ? const Color(0xFFD97706) : const Color(0xFF4F46E5),
                            isDark,
                          ),
                          const SizedBox(width: 8),
                          _rackMetricPill(
                            'TEMP',
                            isFloor2 ? '24.1°C' : '21.4°C',
                            isFloor2 ? 'Mezzanine Climate' : 'Normal Sensor',
                            Icons.thermostat_rounded,
                            const Color(0xFF059669),
                            isDark,
                          ),
                          const SizedBox(width: 8),
                          _rackMetricPill(
                            'VELOCITY',
                            isFloor2 ? '285' : '142',
                            'picks / day',
                            Icons.speed_rounded,
                            const Color(0xFF0891B2),
                            isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Vertical Shelf Matrix
                      if (!_isTiersMinimized) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Vertical Shelf Matrix', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                                  Text(
                                    isFloor2 ? 'MEZZ TIER 1 TO 4' : 'TIER 1 TO 4',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isFloor2 ? const Color(0xFFD97706) : const Color(0xFF4F46E5),
                                      fontFamily: 'JetBrains Mono',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (isFloor2) ...[
                                _shelfTierRow('M4', ['BOT-BIN-A', 'BOT-BIN-B', 'MBIN-88', 'MBIN-89'], '92% FULL', const Color(0xFF059669), false),
                                const SizedBox(height: 4),
                                _shelfTierRow('M3', ['SKU-9910', 'SKU-7721', 'SKU-8824', 'SKU-5511'], 'SORT ACTIVE', const Color(0xFFD97706), true),
                                const SizedBox(height: 4),
                                _shelfTierRow('M2', ['KIT-BIN-1', 'KIT-BIN-2', 'PACK-01', 'EMPTY'], 'OPTIMAL', const Color(0xFF059669), false),
                                const SizedBox(height: 4),
                                _shelfTierRow('M1', ['BUFF-A1', 'BUFF-A2', 'RMA-HOLD', 'EMPTY'], 'BUFFER STAGE', const Color(0xFF64748B), false),
                              ] else ...[
                                _shelfTierRow('T4', ['SKU-1022', 'SKU-4091', 'EMPTY', 'SKU-9901'], '95% FULL', const Color(0xFF059669), false),
                                const SizedBox(height: 4),
                                _shelfTierRow('T3', ['SKU-5012', 'SKU-3011', 'SKU-8824', 'SKU-1092'], 'FULL', const Color(0xFF059669), false),
                                const SizedBox(height: 4),
                                _shelfTierRow('T2', ['SKU-8824', 'SKU-8824', 'SKU-4091', 'EMPTY'], 'TARGET PICK', const Color(0xFF4F46E5), true),
                                const SizedBox(height: 4),
                                _shelfTierRow('T1', ['BULK-01', 'BULK-02', 'EMPTY', 'EMPTY'], 'PALLET ONLY', const Color(0xFF64748B), false),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
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

  Widget _layerChip(String key, String label, IconData icon) {
    final isSelected = _selectedLayer == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedLayer = key),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: isSelected ? Colors.white : const Color(0xFF4F46E5)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _zoneBlock(BuildContext context, String title, String subtitle, Color bg, Color border, List<String> racks) {
    return InkWell(
      onTap: () {
        setState(() => _selectedRack = racks.first);
        _showToast('Selected $title');
      },
      child: Container(
        width: 155,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: border, fontFamily: 'JetBrains Mono')),
            Text(subtitle, style: TextStyle(fontSize: 8, color: border.withValues(alpha: 0.8), fontFamily: 'JetBrains Mono')),
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: racks.map((r) {
                final isSelected = _selectedRack == r;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? border : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: border.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    r,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rackMetricPill(String label, String val, String sub, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
              ],
            ),
            const SizedBox(height: 2),
            Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color, fontFamily: 'JetBrains Mono')),
            Text(sub, style: const TextStyle(fontSize: 8, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _shelfTierRow(String lvl, List<String> bins, String statusText, Color statusColor, bool isTarget) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isTarget ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isTarget ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(lvl, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isTarget ? const Color(0xFF4F46E5) : const Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
          ),
          Expanded(
            child: Row(
              children: bins.map((b) {
                final isSku = b.startsWith('SKU-');
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 22,
                    decoration: BoxDecoration(
                      color: isSku ? const Color(0xFF4F46E5) : (b == 'EMPTY' ? Colors.grey.shade100 : Colors.white),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isSku ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      b,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: isSku ? Colors.white : (b == 'EMPTY' ? Colors.grey : Colors.black87),
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 6),
          Text(statusText, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor, fontFamily: 'JetBrains Mono')),
        ],
      ),
    );
  }
}
