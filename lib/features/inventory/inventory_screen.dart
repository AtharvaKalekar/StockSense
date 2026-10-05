import '../../shared/widgets/user_profile_menu.dart';
import '../../domain/models/sku_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/app_providers.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isSortOpen = false;
  String _sortBy = 'Stock Level';
  bool _sortAscending = false;

  void _toggleSort(String label) {
    setState(() {
      if (_sortBy == label) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = label;
        _sortAscending = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final skusAsync = ref.watch(inventoryListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
        ),
        backgroundColor: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.95),
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
                  'Inventory Catalog',
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
                    color: Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 18, color: Color(0xFF4F46E5)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'ADM',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'JetBrains Mono'),
                  ),
                ),
              ],
            ),
          ),
          ), 
        ]
      ),
      body: skusAsync.when(
        data: (skus) {
          int countForCat(String cat) {
            if (cat == 'All') return skus.length;
            return skus.where((s) => s.category.toLowerCase() == cat.toLowerCase()).length;
          }

          final filtered = skus.where((s) {
            final matchesCat = _selectedCategory == 'All' || s.category.toLowerCase() == _selectedCategory.toLowerCase();
            final matchesSearch = _searchQuery.isEmpty ||
                s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.skuCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.fullLocation.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesCat && matchesSearch;
          }).toList();

          filtered.sort((a, b) {
            int comp = 0;
            if (_sortBy == 'Stock Level') {
              comp = b.quantity.compareTo(a.quantity);
            } else if (_sortBy == 'Recency') {
              comp = b.updatedAt.compareTo(a.updatedAt);
            } else if (_sortBy == 'Unit Price') {
              comp = b.unitPrice.compareTo(a.unitPrice);
            }
            return _sortAscending ? -comp : comp;
          });

          final totalVal = filtered.fold<double>(0, (sum, item) => sum + (item.quantity * item.unitPrice));

          return Stack(
            children: [
              Column(
                children: [
                  // Sticky Search & Category Filter Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                    ),
                    child: Column(
                      children: [
                        // Search Row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 42,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'Search SKU, item name, bin...',
                                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (val) => setState(() => _searchQuery = val),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF4F46E5), size: 18),
                                      onPressed: () => context.go('/scanner'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => setState(() => _isSortOpen = !_isSortOpen),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: _isSortOpen ? const Color(0xFFEEF2FF) : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _isSortOpen ? const Color(0xFF4F46E5) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                                ),
                                child: Icon(Icons.tune_rounded, color: _isSortOpen ? const Color(0xFF4F46E5) : const Color(0xFF64748B), size: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Category Pills
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _categoryPill('All', '${countForCat("All")}'),
                              _categoryPill('Electronics', '${countForCat("Electronics")}'),
                              _categoryPill('FMCG', '${countForCat("FMCG")}'),
                              _categoryPill('Pharma', '${countForCat("Pharma")}', icon: Icons.ac_unit_rounded),
                              _categoryPill('Hardware', '${countForCat("Hardware")}'),
                            ],
                          ),
                        ),

                        // Sort Drawer Matrix
                        if (_isSortOpen) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'SORT MATRIX',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontFamily: 'JetBrains Mono'),
                                    ),
                                    Text(
                                      _sortAscending ? 'ORDER: ASCENDING ▲' : 'ORDER: DESCENDING ▼',
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _sortOption('Stock Level'),
                                      const SizedBox(width: 8),
                                      _sortOption('Recency'),
                                      const SizedBox(width: 8),
                                      _sortOption('Unit Price'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Catalog List
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text(
                                  'No matching SKUs found',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF475569)),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return _stitchSkuCard(context, item, isDark);
                            },
                          ),
                  ),
                ],
              ),

              // Floating Fast-Filter Summary Pill at Bottom
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(radius: 4, backgroundColor: Color(0xFF4F46E5)),
                        const SizedBox(width: 8),
                        Text(
                          'Showing ${filtered.length} of ${skus.length} SKUs',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF334155)),
                        ),
                        const SizedBox(width: 12),
                        const Text('|', style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 12),
                        const Text(
                          'VALUE: ',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, fontFamily: 'JetBrains Mono'),
                        ),
                        Text(
                          '₹${totalVal >= 10000000 ? (totalVal / 10000000).toStringAsFixed(2) + " Cr" : (totalVal >= 100000 ? (totalVal / 100000).toStringAsFixed(2) + " L" : totalVal.toStringAsFixed(0))}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF047857), fontFamily: 'JetBrains Mono'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading inventory: $err')),
      ),
    );
  }

  Widget _categoryPill(String label, String count, {IconData? icon}) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: isSelected ? Colors.white : const Color(0xFF0D9488)),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
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

  Widget _sortOption(String label) {
    final isSelected = _sortBy == label;
    return InkWell(
      onTap: () => _toggleSort(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF475569),
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                _sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 12,
                color: const Color(0xFF4F46E5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stitchSkuCard(BuildContext context, SkuModel item, bool isDark) {
    Color badgeBg = const Color(0xFFECFDF5);
    Color badgeText = const Color(0xFF047857);
    String statusLabel = 'In Stock';

    if (item.stockStatus == 'Low Stock' || item.quantity < 20) {
      badgeBg = const Color(0xFFFEF3C7);
      badgeText = const Color(0xFFB45309);
      statusLabel = 'Low Stock';
    } else if (item.stockStatus == 'Out of Stock' || item.quantity == 0) {
      badgeBg = const Color(0xFFFFE4E6);
      badgeText = const Color(0xFFBE123C);
      statusLabel = 'Out of Stock';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.memory_rounded, color: Color(0xFF4F46E5), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.skuCode,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
                            fontFamily: 'JetBrains Mono',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: badgeText,
                              fontFamily: 'JetBrains Mono',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Info Grid
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BIN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                      const SizedBox(height: 2),
                      Text(item.fullLocation, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A), fontFamily: 'JetBrains Mono')),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ON HAND', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                      const SizedBox(height: 2),
                      Text('${item.quantity} pcs', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: item.quantity < 10 ? const Color(0xFFEF4444) : (isDark ? Colors.white : const Color(0xFF0F172A)), fontFamily: 'JetBrains Mono')),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('UNIT RATE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontFamily: 'JetBrains Mono')),
                      const SizedBox(height: 2),
                      Text('₹${item.unitPrice.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontFamily: 'JetBrains Mono')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Capacity Mini Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Telemetry Capacity', style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : const Color(0xFF64748B))),
              Text('${((item.quantity / 150) * 100).clamp(0, 100).toInt()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeText, fontFamily: 'JetBrains Mono')),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (item.quantity / 150).clamp(0.0, 1.0),
              color: badgeText,
              backgroundColor: const Color(0xFFF1F5F9),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 8),

          // Card Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.conveyor_belt, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text('Automated Bay Transfer', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : const Color(0xFF64748B))),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.qr_code_2_rounded, size: 18, color: Color(0xFF4F46E5)),
                    onPressed: () => context.go('/scanner'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF64748B)),
                    onPressed: () => context.push('/inventory/detail', extra: item),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
