import 'dart:async';
import '../../domain/repositories/user_repository.dart';
import '../../domain/models/user_model.dart';
import '../mock/mock_database.dart';

class MockUserRepository implements UserRepository {
  final MockDatabase _db = MockDatabase.instance;

  @override
  Future<List<UserModel>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return List<UserModel>.from(_db.users);
  }

  @override
  Future<void> updateUserStatus(String userId, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _db.users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _db.users[idx] = _db.users[idx].copyWith(isActive: isActive);
    }
  }

  @override
  Future<void> updateUserRole(String userId, String roleCode) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final idx = _db.users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _db.users[idx] = _db.users[idx].copyWith(role: UserRoleExtension.fromCode(roleCode));
    }
  }

  @override
  Future<void> addUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _db.users.add(user);
  }
}
