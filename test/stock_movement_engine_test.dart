import 'package:flutter_test/flutter_test.dart';
import 'package:stocksense/domain/engine/stock_movement_engine.dart';
import 'package:stocksense/domain/models/sku_model.dart';
import 'package:stocksense/domain/models/movement_log_model.dart';

void main() {
  group('StockMovementEngine Unit Tests', () {
    final sampleSku = SkuModel(
      id: 'sku_1',
      skuCode: 'ELE-SAM-001',
      barcode: '890123456701',
      name: 'Samsung S24 Ultra',
      category: 'Electronics',
      unitPrice: 129999.0,
      quantity: 10,
      reorderLevel: 5,
      maxCapacity: 100,
      zone: 'Zone A',
      aisle: '01',
      rack: 'R1',
      bin: 'B1',
      imageUrl: '',
      description: 'Test Phone',
      stockHistory: [10],
      updatedAt: DateTime.now(),
    );

    test('processInward increases stock and creates log entry', () {
      final result = StockMovementEngine.processInward(
        sku: sampleSku,
        inwardQty: 5,
        supplierName: 'Reliance Retail',
        referenceNumber: 'GRN-001',
        userEmail: 'admin@stocksense.io',
        device: 'Test Device',
      );

      expect(result.success, true);
      expect(result.updatedSku?.quantity, 15);
      expect(result.logEntry?.type, MovementType.inward);
      expect(result.logEntry?.quantity, 5);
    });

    test('processOutward fails if quantity exceeds available stock', () {
      final result = StockMovementEngine.processOutward(
        sku: sampleSku,
        outwardQty: 20,
        customerName: 'Flipkart',
        referenceNumber: 'SO-001',
        userEmail: 'admin@stocksense.io',
        device: 'Test Device',
      );

      expect(result.success, false);
      expect(result.message.contains('Insufficient Stock'), true);
    });
  });
}
