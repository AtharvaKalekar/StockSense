import '../models/user_model.dart';

abstract class UserRepository {
  Future<List<UserModel>> getUsers();
  Future<void> updateUserStatus(String userId, bool isActive);
  Future<void> updateUserRole(String userId, String roleCode);
  Future<void> addUser(UserModel user);
}
