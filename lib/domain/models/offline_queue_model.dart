class OfflineQueueItem {
  final String id;
  final String actionType;
  final String skuCode;
  final int quantity;
  final String fromLocation;
  final String toLocation;
  final String referenceNumber;
  final DateTime timestamp;
  final String status;

  const OfflineQueueItem({
    required this.id,
    required this.actionType,
    required this.skuCode,
    required this.quantity,
    required this.fromLocation,
    required this.toLocation,
    required this.referenceNumber,
    required this.timestamp,
    this.status = 'PENDING',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'actionType': actionType,
        'skuCode': skuCode,
        'quantity': quantity,
        'fromLocation': fromLocation,
        'toLocation': toLocation,
        'referenceNumber': referenceNumber,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
      };

  factory OfflineQueueItem.fromJson(Map<String, dynamic> json) => OfflineQueueItem(
        id: json['id'],
        actionType: json['actionType'],
        skuCode: json['skuCode'],
        quantity: json['quantity'],
        fromLocation: json['fromLocation'],
        toLocation: json['toLocation'],
        referenceNumber: json['referenceNumber'],
        timestamp: DateTime.parse(json['timestamp']),
        status: json['status'] ?? 'PENDING',
      );
}
