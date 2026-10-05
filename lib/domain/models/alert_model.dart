enum AlertSeverity { info, low, warning, critical }

class AlertModel {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final String? skuId;
  final String? skuCode;
  final DateTime createdAt;
  final bool isRead;
  final String actionText;

  const AlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    this.skuId,
    this.skuCode,
    required this.createdAt,
    this.isRead = false,
    this.actionText = 'Create Inward Request',
  });

  AlertModel copyWith({
    String? id,
    String? title,
    String? message,
    AlertSeverity? severity,
    String? skuId,
    String? skuCode,
    DateTime? createdAt,
    bool? isRead,
    String? actionText,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      skuId: skuId ?? this.skuId,
      skuCode: skuCode ?? this.skuCode,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionText: actionText ?? this.actionText,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'severity': severity.name,
        'skuId': skuId,
        'skuCode': skuCode,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
        'actionText': actionText,
      };

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
        id: json['id'],
        title: json['title'],
        message: json['message'],
        severity: AlertSeverity.values.byName(json['severity']),
        skuId: json['skuId'],
        skuCode: json['skuCode'],
        createdAt: DateTime.parse(json['createdAt']),
        isRead: json['isRead'] ?? false,
        actionText: json['actionText'] ?? 'Create Inward Request',
      );
}
