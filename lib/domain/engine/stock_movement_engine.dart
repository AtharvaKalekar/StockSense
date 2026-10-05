import '../models/sku_model.dart';
import '../models/movement_log_model.dart';
import '../models/alert_model.dart';

class StockMovementResult {
  final bool success;
  final String message;
  final SkuModel? updatedSku;
  final MovementLogModel? logEntry;
  final AlertModel? triggeredAlert;

  const StockMovementResult({
    required this.success,
    required this.message,
    this.updatedSku,
    this.logEntry,
    this.triggeredAlert,
  });
}

class StockMovementEngine {
  static StockMovementResult processInward({
    required SkuModel sku,
    required int inwardQty,
    required String supplierName,
    required String referenceNumber,
    required String userEmail,
    required String device,
  }) {
    if (inwardQty <= 0) {
      return const StockMovementResult(
        success: false,
        message: 'Inward quantity must be greater than zero.',
      );
    }

    if (sku.quantity + inwardQty > sku.maxCapacity) {
      return StockMovementResult(
        success: false,
        message:
            'Capacity Exceeded! Maximum bin capacity is ${sku.maxCapacity} units. Current: ${sku.quantity}, Attempted addition: $inwardQty.',
      );
    }

    final int beforeQty = sku.quantity;
    final int afterQty = beforeQty + inwardQty;
    final updatedHistory = List<int>.from(sku.stockHistory)..add(afterQty);
    if (updatedHistory.length > 10) updatedHistory.removeAt(0);

    final updatedSku = sku.copyWith(
      quantity: afterQty,
      stockHistory: updatedHistory,
      updatedAt: DateTime.now(),
    );

    final log = MovementLogModel(
      id: 'MOV-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: MovementType.inward,
      skuId: sku.id,
      skuCode: sku.skuCode,
      skuName: sku.name,
      quantity: inwardQty,
      beforeQty: beforeQty,
      afterQty: afterQty,
      fromLocation: 'Supplier: $supplierName',
      toLocation: sku.fullLocation,
      performedBy: userEmail,
      referenceNumber: referenceNumber.isEmpty ? 'GRN-${DateTime.now().millisecondsSinceEpoch % 10000}' : referenceNumber,
      device: device,
    );

    return StockMovementResult(
      success: true,
      message: 'Successfully inwarded $inwardQty units of ${sku.skuCode} into ${sku.fullLocation}.',
      updatedSku: updatedSku,
      logEntry: log,
    );
  }

  static StockMovementResult processOutward({
    required SkuModel sku,
    required int outwardQty,
    required String customerName,
    required String referenceNumber,
    required String userEmail,
    required String device,
  }) {
    if (outwardQty <= 0) {
      return const StockMovementResult(
        success: false,
        message: 'Outward quantity must be greater than zero.',
      );
    }

    if (sku.quantity < outwardQty) {
      return StockMovementResult(
        success: false,
        message:
            'Insufficient Stock! Available quantity is ${sku.quantity} units, attempted removal is $outwardQty units.',
      );
    }

    final int beforeQty = sku.quantity;
    final int afterQty = beforeQty - outwardQty;
    final updatedHistory = List<int>.from(sku.stockHistory)..add(afterQty);
    if (updatedHistory.length > 10) updatedHistory.removeAt(0);

    final updatedSku = sku.copyWith(
      quantity: afterQty,
      stockHistory: updatedHistory,
      updatedAt: DateTime.now(),
    );

    final log = MovementLogModel(
      id: 'MOV-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: MovementType.outward,
      skuId: sku.id,
      skuCode: sku.skuCode,
      skuName: sku.name,
      quantity: outwardQty,
      beforeQty: beforeQty,
      afterQty: afterQty,
      fromLocation: sku.fullLocation,
      toLocation: 'Customer: $customerName',
      performedBy: userEmail,
      referenceNumber: referenceNumber.isEmpty ? 'DN-${DateTime.now().millisecondsSinceEpoch % 10000}' : referenceNumber,
      device: device,
    );

    AlertModel? alert;
    if (afterQty <= sku.reorderLevel) {
      alert = AlertModel(
        id: 'ALT-${DateTime.now().millisecondsSinceEpoch}',
        title: afterQty <= (sku.reorderLevel / 2) ? 'Critical Stock Alert' : 'Low Stock Warning',
        message: '${sku.name} (${sku.skuCode}) has fallen to $afterQty units (Reorder level: ${sku.reorderLevel}).',
        severity: afterQty <= (sku.reorderLevel / 2) ? AlertSeverity.critical : AlertSeverity.warning,
        skuId: sku.id,
        skuCode: sku.skuCode,
        createdAt: DateTime.now(),
      );
    }

    return StockMovementResult(
      success: true,
      message: 'Successfully dispatched $outwardQty units of ${sku.skuCode} to $customerName.',
      updatedSku: updatedSku,
      logEntry: log,
      triggeredAlert: alert,
    );
  }

  static StockMovementResult processTransfer({
    required SkuModel sku,
    required int transferQty,
    required String toZone,
    required String toAisle,
    required String toRack,
    required String toBin,
    required String userEmail,
    required String device,
  }) {
    if (transferQty <= 0) {
      return const StockMovementResult(
        success: false,
        message: 'Transfer quantity must be greater than zero.',
      );
    }

    if (sku.quantity < transferQty) {
      return StockMovementResult(
        success: false,
        message: 'Insufficient Stock! Available quantity is ${sku.quantity} units.',
      );
    }

    final String fromLoc = sku.fullLocation;
    final String targetLoc = '$toZone-$toAisle-$toRack-$toBin';

    final updatedSku = sku.copyWith(
      zone: toZone,
      aisle: toAisle,
      rack: toRack,
      bin: toBin,
      updatedAt: DateTime.now(),
    );

    final log = MovementLogModel(
      id: 'MOV-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: MovementType.transfer,
      skuId: sku.id,
      skuCode: sku.skuCode,
      skuName: sku.name,
      quantity: transferQty,
      beforeQty: sku.quantity,
      afterQty: sku.quantity,
      fromLocation: fromLoc,
      toLocation: targetLoc,
      performedBy: userEmail,
      referenceNumber: 'TRF-${DateTime.now().millisecondsSinceEpoch % 10000}',
      device: device,
    );

    return StockMovementResult(
      success: true,
      message: 'Transferred $transferQty units of ${sku.skuCode} from $fromLoc to $targetLoc.',
      updatedSku: updatedSku,
      logEntry: log,
    );
  }
}
