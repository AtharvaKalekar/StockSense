import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> signupWithEmail(String name, String email, String password);
  Future<UserModel> loginWithGoogle();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> logout();
  Future<void> updateUserRole(String userId, String roleCode);
}
