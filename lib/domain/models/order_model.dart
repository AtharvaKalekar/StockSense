enum OrderStatus { pending, picking, packed, dispatched, delivered }

class OrderLineItem {
  final String skuId;
  final String skuCode;
  final String skuName;
  final int expectedQty;
  final int pickedQty;
  final String location;
  final bool isConfirmed;

  const OrderLineItem({
    required this.skuId,
    required this.skuCode,
    required this.skuName,
    required this.expectedQty,
    required this.pickedQty,
    required this.location,
    this.isConfirmed = false,
  });

  OrderLineItem copyWith({
    String? skuId,
    String? skuCode,
    String? skuName,
    int? expectedQty,
    int? pickedQty,
    String? location,
    bool? isConfirmed,
  }) {
    return OrderLineItem(
      skuId: skuId ?? this.skuId,
      skuCode: skuCode ?? this.skuCode,
      skuName: skuName ?? this.skuName,
      expectedQty: expectedQty ?? this.expectedQty,
      pickedQty: pickedQty ?? this.pickedQty,
      location: location ?? this.location,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  Map<String, dynamic> toJson() => {
        'skuId': skuId,
        'skuCode': skuCode,
        'skuName': skuName,
        'expectedQty': expectedQty,
        'pickedQty': pickedQty,
        'location': location,
        'isConfirmed': isConfirmed,
      };

  factory OrderLineItem.fromJson(Map<String, dynamic> json) => OrderLineItem(
        skuId: json['skuId'],
        skuCode: json['skuCode'],
        skuName: json['skuName'],
        expectedQty: json['expectedQty'],
        pickedQty: json['pickedQty'],
        location: json['location'],
        isConfirmed: json['isConfirmed'] ?? false,
      );
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String customerName;
  final String shippingAddress;
  final List<OrderLineItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final String? assignedPicker;
  final String? courierName;
  final String? trackingNumber;
  final String? vehicleNumber;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.shippingAddress,
    required this.items,
    required this.status,
    required this.createdAt,
    this.assignedPicker,
    this.courierName,
    this.trackingNumber,
    this.vehicleNumber,
  });

  bool get isFullyPicked => items.every((i) => i.pickedQty >= i.expectedQty);

  double get pickProgress {
    if (items.isEmpty) return 0.0;
    int totalReq = items.fold(0, (sum, i) => sum + i.expectedQty);
    int totalPicked = items.fold(0, (sum, i) => sum + i.pickedQty);
    return (totalPicked / totalReq).clamp(0.0, 1.0);
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerName,
    String? shippingAddress,
    List<OrderLineItem>? items,
    OrderStatus? status,
    DateTime? createdAt,
    String? assignedPicker,
    String? courierName,
    String? trackingNumber,
    String? vehicleNumber,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      assignedPicker: assignedPicker ?? this.assignedPicker,
      courierName: courierName ?? this.courierName,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'customerName': customerName,
        'shippingAddress': shippingAddress,
        'items': items.map((e) => e.toJson()).toList(),
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'assignedPicker': assignedPicker,
        'courierName': courierName,
        'trackingNumber': trackingNumber,
        'vehicleNumber': vehicleNumber,
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'],
        orderNumber: json['orderNumber'],
        customerName: json['customerName'],
        shippingAddress: json['shippingAddress'],
        items: (json['items'] as List).map((e) => OrderLineItem.fromJson(e)).toList(),
        status: OrderStatus.values.byName(json['status']),
        createdAt: DateTime.parse(json['createdAt']),
        assignedPicker: json['assignedPicker'],
        courierName: json['courierName'],
        trackingNumber: json['trackingNumber'],
        vehicleNumber: json['vehicleNumber'],
      );
}
