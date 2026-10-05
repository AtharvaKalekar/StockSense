import 'dart:async';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/models/sku_model.dart';
import '../mock/mock_database.dart';

class MockInventoryRepository implements InventoryRepository {
  final MockDatabase _db = MockDatabase.instance;

  @override
  Future<List<SkuModel>> getSkus({
    String? category,
    String? status,
    String? searchQuery,
    String? sortBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var list = List<SkuModel>.from(_db.skus);

    if (category != null && category != 'All') {
      list = list.where((s) => s.category == category).toList();
    }

    if (status != null && status != 'All') {
      list = list.where((s) => s.stockStatus.toLowerCase() == status.toLowerCase()).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((s) =>
        s.skuCode.toLowerCase().contains(q) ||
        s.name.toLowerCase().contains(q) ||
        s.barcode.contains(q) ||
        s.fullLocation.toLowerCase().contains(q) ||
        s.category.toLowerCase().contains(q)
      ).toList();
    }

    return list;
  }

  @override
  Future<SkuModel?> getSkuById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _db.skus.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<SkuModel?> getSkuByCodeOrBarcode(String query) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final q = query.trim().toLowerCase();
    try {
      return _db.skus.firstWhere(
        (s) => s.skuCode.toLowerCase() == q || s.barcode == q || s.id.toLowerCase() == q,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateSku(SkuModel sku) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _db.skus.indexWhere((s) => s.id == sku.id);
    if (idx != -1) {
      _db.skus[idx] = sku;
    }
  }

  @override
  Future<void> addSku(SkuModel sku) async {
    await Future.delayed(const Duration(milliseconds: 450));
    _db.skus.insert(0, sku);
  }

  @override
  Future<void> deleteSku(String id) async {
    await Future.delayed(const Duration(milliseconds: 350));
    _db.skus.removeWhere((s) => s.id == id);
  }
}
