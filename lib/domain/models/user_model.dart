enum UserRole {
  admin,
  warehouseManager,
  picker,
  dispatcher,
  viewer,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'System Admin';
      case UserRole.warehouseManager:
        return 'Warehouse Manager';
      case UserRole.picker:
        return 'Inventory Picker';
      case UserRole.dispatcher:
        return 'Dispatch Operator';
      case UserRole.viewer:
        return 'Read-Only Viewer';
    }
  }

  String get code {
    return toString().split('.').last;
  }

  static UserRole fromCode(String code) {
    return UserRole.values.firstWhere(
      (e) => e.code.toLowerCase() == code.toLowerCase(),
      orElse: () => UserRole.warehouseManager,
    );
  }
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final String photoUrl;
  final UserRole role;
  final bool isActive;
  final DateTime lastLogin;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.role,
    this.isActive = true,
    required this.lastLogin,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    UserRole? role,
    bool? isActive,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'role': role.code,
        'isActive': isActive,
        'lastLogin': lastLogin.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        email: json['email'],
        name: json['name'],
        photoUrl: json['photoUrl'],
        role: UserRoleExtension.fromCode(json['role']),
        isActive: json['isActive'] ?? true,
        lastLogin: DateTime.parse(json['lastLogin']),
      );
}
