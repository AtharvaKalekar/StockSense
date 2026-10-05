import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PostScanSheet extends StatefulWidget {
  final VoidCallback onDismiss;
  final bool isEmbedded;

  const PostScanSheet({
    super.key,
    required this.onDismiss,
    this.isEmbedded = false,
  });

  @override
  State<PostScanSheet> createState() => _PostScanSheetState();
}

class _PostScanSheetState extends State<PostScanSheet> {
  bool _isVerified = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sheet Header title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4F46E5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'SCANNED ITEM RESULT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const Text(
              'Real-time Telemetry',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F46E5),
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Result Card Container
        Container(
          padding: const EdgeInsets.all(14),
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
              // Product Header Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.sensors_rounded, color: Color(0xFF4F46E5), size: 32),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Text(
                            'v4.2',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                              fontFamily: 'JetBrains Mono',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'SKU-8824-LDR',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F46E5),
                                fontFamily: 'JetBrains Mono',
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                border: Border.all(color: const Color(0xFFA7F3D0)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'HIGH VELOCITY',
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
                          'OmniSense LiDAR Depth Sensor v4',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Automated guided vehicle precision navigation payload.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 14),
                            SizedBox(width: 4),
                            Text('In Stock', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
                            SizedBox(width: 6),
                            Text('•', style: TextStyle(color: Colors.grey)),
                            SizedBox(width: 6),
                            Text('QC Verified', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2x2 Metrics Grid
              Row(
                children: [
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
                          const Text(
                            'AVAILABLE STOCK',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 2),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('42', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
                              SizedBox(width: 4),
                              Text('Units', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                            ],
                          ),
                          Text('Reorder trigger at 15', style: TextStyle(fontSize: 9, color: isDark ? Colors.white54 : const Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                          const Text(
                            'TRANSFER UNIT VAL',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '₹14,850',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontFamily: 'JetBrains Mono'),
                          ),
                          Text('HSN: 9031.90.00', style: TextStyle(fontSize: 9, color: isDark ? Colors.white54 : const Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Bin Coordinates Tile
              Container(
                padding: const EdgeInsets.all(10),
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
                        const Row(
                          children: [
                            Icon(Icons.warehouse_rounded, color: Color(0xFF4F46E5), size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Current Bin Coordinates',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ZONE B',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontFamily: 'JetBrains Mono'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.shelves, color: Color(0xFF4F46E5), size: 18),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aisle B2 • Rack R1',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    fontFamily: 'JetBrains Mono',
                                  ),
                                ),
                                Text('Shelf 03 • Bin B4', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : const Color(0xFF64748B))),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.near_me_rounded, color: Color(0xFF4F46E5), size: 18),
                          onPressed: () => context.go('/location-map'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isVerified ? const Color(0xFF059669) : const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() => _isVerified = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _isVerified = false);
                    });
                  },
                  icon: Icon(_isVerified ? Icons.check_circle_rounded : Icons.add_circle_rounded, size: 20),
                  label: Text(
                    _isVerified ? 'Verified & Allocated!' : 'Inward Stock / Verify (+)',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => context.go('/location-map'),
                  icon: const Icon(Icons.route_rounded, color: Color(0xFF64748B), size: 18),
                  label: const Text('View Bin Route in Yard 3D', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Shift Pick History Bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.history_rounded, color: Color(0xFF4F46E5), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shift Pick History',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text('128 Items verified without dispute', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : const Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '99.8%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF047857),
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return content;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FD),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: content,
    );
  }
}
