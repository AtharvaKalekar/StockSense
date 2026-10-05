import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/movement_log_model.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/shimmer_loader.dart';

class AuditHistoryScreen extends ConsumerStatefulWidget {
  const AuditHistoryScreen({super.key});

  @override
  ConsumerState<AuditHistoryScreen> createState() => _AuditHistoryScreenState();
}

class _AuditHistoryScreenState extends ConsumerState<AuditHistoryScreen> {
  String _selectedType = 'ALL';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final auditLogsAsync = ref.watch(auditLogsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.history_edu_rounded, color: Color(0xFF8B5CF6), size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Immutable Audit Ledger Log',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Timestamped Stock Movement & Activity History',
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
      ),
      body: auditLogsAsync.when(
        loading: () => const ShimmerList(height: 80, itemCount: 6),
        error: (err, stack) => Center(child: Text('Error loading audit log: $err')),
        data: (logs) {
          final filteredLogs = logs.where((log) {
            final matchesSearch = log.skuCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                log.skuName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                log.performedBy.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                log.referenceNumber.toLowerCase().contains(_searchQuery.toLowerCase());
            
            if (_selectedType == 'INWARD') return matchesSearch && log.type == MovementType.inward;
            if (_selectedType == 'OUTWARD') return matchesSearch && log.type == MovementType.outward;
            if (_selectedType == 'ADJUSTMENT') return matchesSearch && log.type == MovementType.adjust;
            if (_selectedType == 'PICK') return matchesSearch && log.type == MovementType.pick;
            return matchesSearch;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search audit logs by SKU, user, or reference code...',
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF94A3B8), fontSize: 12),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Movement Type Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _typeChip('ALL', 'All Transactions (${logs.length})'),
                      _typeChip('INWARD', 'Inward Receipts'),
                      _typeChip('OUTWARD', 'Outward Dispatches'),
                      _typeChip('ADJUSTMENT', 'Adjustments'),
                      _typeChip('PICK', 'Pick Waves'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Audit Log Items
                if (filteredLogs.isEmpty)
                  const EmptyState(
                    icon: Icons.history_edu_rounded,
                    title: 'No Matching Audit Logs',
                    subtitle: 'No stock transactions match your search filter.',
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredLogs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      Color badgeColor;
                      IconData typeIcon;
                      switch (log.type) {
                        case MovementType.inward:
                          badgeColor = const Color(0xFF10B981);
                          typeIcon = Icons.input_rounded;
                          break;
                        case MovementType.outward:
                          badgeColor = const Color(0xFF6366F1);
                          typeIcon = Icons.local_shipping_rounded;
                          break;
                        case MovementType.adjust:
                          badgeColor = const Color(0xFFF59E0B);
                          typeIcon = Icons.tune_rounded;
                          break;
                        default:
                          badgeColor = const Color(0xFF0D9488);
                          typeIcon = Icons.alt_route_rounded;
                      }

                      final delta = log.afterQty - log.beforeQty;
                      final deltaText = delta > 0 ? '+$delta' : '$delta';

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(typeIcon, color: badgeColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: badgeColor.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              log.type.name.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: badgeColor,
                                                fontFamily: 'JetBrains Mono',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            log.skuCode,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                                              fontFamily: 'JetBrains Mono',
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        AppFormatters.formatDateTime(log.timestamp),
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    log.skuName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline_rounded, size: 13, color: Color(0xFF64748B)),
                                          const SizedBox(width: 4),
                                          Text(
                                            log.performedBy,
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.tag_rounded, size: 13, color: Color(0xFF64748B)),
                                          const SizedBox(width: 2),
                                          Text(
                                            log.referenceNumber,
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono'),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: badgeColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Qty: ${log.beforeQty} → ${log.afterQty} ($deltaText)',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: badgeColor,
                                            fontFamily: 'JetBrains Mono',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  Widget _typeChip(String key, String label) {
    final isSelected = _selectedType == key;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedType = key),
        selectedColor: const Color(0xFF8B5CF6),
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: isSelected ? const Color(0xFF8B5CF6) : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
      ),
    );
  }
}
