class SkuModel {
  final String id;
  final String skuCode;
  final String barcode;
  final String name;
  final String category;
  final double unitPrice;
  final int quantity;
  final int reorderLevel;
  final int maxCapacity;
  final String zone;
  final String aisle;
  final String rack;
  final String bin;
  final String imageUrl;
  final String description;
  final List<int> stockHistory;
  final DateTime updatedAt;

  const SkuModel({
    required this.id,
    required this.skuCode,
    required this.barcode,
    required this.name,
    required this.category,
    required this.unitPrice,
    required this.quantity,
    required this.reorderLevel,
    required this.maxCapacity,
    required this.zone,
    required this.aisle,
    required this.rack,
    required this.bin,
    required this.imageUrl,
    required this.description,
    required this.stockHistory,
    required this.updatedAt,
  });

  String get fullLocation => '$zone-$aisle-$rack-$bin';

  String get stockStatus {
    if (quantity == 0) return 'Out of Stock';
    if (quantity <= reorderLevel / 2) return 'Critical';
    if (quantity <= reorderLevel) return 'Low Stock';
    return 'In Stock';
  }

  SkuModel copyWith({
    String? id,
    String? skuCode,
    String? barcode,
    String? name,
    String? category,
    double? unitPrice,
    int? quantity,
    int? reorderLevel,
    int? maxCapacity,
    String? zone,
    String? aisle,
    String? rack,
    String? bin,
    String? imageUrl,
    String? description,
    List<int>? stockHistory,
    DateTime? updatedAt,
  }) {
    return SkuModel(
      id: id ?? this.id,
      skuCode: skuCode ?? this.skuCode,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      category: category ?? this.category,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      zone: zone ?? this.zone,
      aisle: aisle ?? this.aisle,
      rack: rack ?? this.rack,
      bin: bin ?? this.bin,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      stockHistory: stockHistory ?? this.stockHistory,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'skuCode': skuCode,
        'barcode': barcode,
        'name': name,
        'category': category,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'reorderLevel': reorderLevel,
        'maxCapacity': maxCapacity,
        'zone': zone,
        'aisle': aisle,
        'rack': rack,
        'bin': bin,
        'imageUrl': imageUrl,
        'description': description,
        'stockHistory': stockHistory,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SkuModel.fromJson(Map<String, dynamic> json) => SkuModel(
        id: json['id'],
        skuCode: json['skuCode'],
        barcode: json['barcode'],
        name: json['name'],
        category: json['category'],
        unitPrice: (json['unitPrice'] as num).toDouble(),
        quantity: json['quantity'],
        reorderLevel: json['reorderLevel'],
        maxCapacity: json['maxCapacity'],
        zone: json['zone'],
        aisle: json['aisle'],
        rack: json['rack'],
        bin: json['bin'],
        imageUrl: json['imageUrl'],
        description: json['description'],
        stockHistory: List<int>.from(json['stockHistory']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}
