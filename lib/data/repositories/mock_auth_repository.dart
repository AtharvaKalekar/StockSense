import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/models/user_model.dart';
import '../../core/constants/app_constants.dart';
import '../mock/mock_database.dart';

class MockAuthRepository implements AuthRepository {
  final MockDatabase _db = MockDatabase.instance;
  UserModel? _currentUser;

  MockAuthRepository() {
    _initSession();
  }

  Future<void> _initSession() async {
    final prefs = await SharedPreferences.getInstance();
    final roleCode = prefs.getString(AppConstants.keyUserRole) ?? 'admin';
    _currentUser = _db.users.firstWhere(
      (u) => u.role.code == roleCode,
      orElse: () => _db.users.first,
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    final roleCode = prefs.getString(AppConstants.keyUserRole);
    if (roleCode != null && _currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: UserRoleExtension.fromCode(roleCode));
    }
    return _currentUser ?? _db.users.first;
  }

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final user = _db.users.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => UserModel(
        id: 'USR-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: email.split('@').first.toUpperCase(),
        photoUrl: 'https://i.pravatar.cc/150?img=12',
        role: UserRole.admin,
        lastLogin: DateTime.now(),
      ),
    );
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserRole, user.role.code);
    return user;
  }

  @override
  Future<UserModel> signupWithEmail(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newUser = UserModel(
      id: 'USR-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      photoUrl: 'https://i.pravatar.cc/150?img=33',
      role: UserRole.warehouseManager,
      lastLogin: DateTime.now(),
    );
    _db.users.add(newUser);
    _currentUser = newUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserRole, newUser.role.code);
    return newUser;
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 700));
    final googleUser = UserModel(
      id: 'USR-G-${DateTime.now().millisecondsSinceEpoch}',
      email: 'rajesh.sharma@gmail.com',
      name: 'Rajesh Sharma (Google)',
      photoUrl: 'https://i.pravatar.cc/150?img=11',
      role: UserRole.admin,
      lastLogin: DateTime.now(),
    );
    _currentUser = googleUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserRole, googleUser.role.code);
    return googleUser;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  @override
  Future<void> updateUserRole(String userId, String roleCode) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserRole, roleCode);
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: UserRoleExtension.fromCode(roleCode));
    }
  }
}
