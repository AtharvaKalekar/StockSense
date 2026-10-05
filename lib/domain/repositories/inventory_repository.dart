import '../models/sku_model.dart';

abstract class InventoryRepository {
  Future<List<SkuModel>> getSkus({
    String? category,
    String? status,
    String? searchQuery,
    String? sortBy,
  });
  Future<SkuModel?> getSkuById(String id);
  Future<SkuModel?> getSkuByCodeOrBarcode(String query);
  Future<void> updateSku(SkuModel sku);
  Future<void> addSku(SkuModel sku);
  Future<void> deleteSku(String id);
}
