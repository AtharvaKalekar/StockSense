enum MovementType { inward, outward, transfer, pick, adjust }

class MovementLogModel {
  final String id;
  final DateTime timestamp;
  final MovementType type;
  final String skuId;
  final String skuCode;
  final String skuName;
  final int quantity;
  final int beforeQty;
  final int afterQty;
  final String fromLocation;
  final String toLocation;
  final String performedBy;
  final String referenceNumber;
  final String device;

  const MovementLogModel({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.skuId,
    required this.skuCode,
    required this.skuName,
    required this.quantity,
    required this.beforeQty,
    required this.afterQty,
    required this.fromLocation,
    required this.toLocation,
    required this.performedBy,
    required this.referenceNumber,
    required this.device,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'type': type.name,
        'skuId': skuId,
        'skuCode': skuCode,
        'skuName': skuName,
        'quantity': quantity,
        'beforeQty': beforeQty,
        'afterQty': afterQty,
        'fromLocation': fromLocation,
        'toLocation': toLocation,
        'performedBy': performedBy,
        'referenceNumber': referenceNumber,
        'device': device,
      };

  factory MovementLogModel.fromJson(Map<String, dynamic> json) => MovementLogModel(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        type: MovementType.values.byName(json['type']),
        skuId: json['skuId'],
        skuCode: json['skuCode'],
        skuName: json['skuName'],
        quantity: json['quantity'],
        beforeQty: json['beforeQty'] ?? 0,
        afterQty: json['afterQty'] ?? json['quantity'],
        fromLocation: json['fromLocation'],
        toLocation: json['toLocation'],
        performedBy: json['performedBy'],
        referenceNumber: json['referenceNumber'],
        device: json['device'] ?? 'Mobile Terminal A',
      );
}
