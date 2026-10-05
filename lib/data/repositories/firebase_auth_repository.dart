import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/models/user_model.dart';
import '../../core/constants/app_constants.dart';
import './mock_auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MockAuthRepository _mockAuth = MockAuthRepository();

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser == null) {
        return await _mockAuth.getCurrentUser();
      }

      final doc = await _firestore.collection("users").doc(fbUser.uid).get();
      final data = doc.data();
      final roleCode = data?["role"] ?? "admin";
      final name = data?["name"] ?? fbUser.displayName ?? fbUser.email?.split("@").first.toUpperCase() ?? "User";

      final userModel = UserModel(
        id: fbUser.uid,
        email: fbUser.email ?? "",
        name: name,
        photoUrl: fbUser.photoURL ?? "https://i.pravatar.cc/150?img=12",
        role: UserRoleExtension.fromCode(roleCode),
        lastLogin: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserRole, userModel.role.code);
      return userModel;
    } catch (_) {
      return await _mockAuth.getCurrentUser();
    }
  }

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = credential.user!;

      DocumentSnapshot doc = await _firestore.collection("users").doc(fbUser.uid).get();
      final data = doc.data() as Map<String, dynamic>?;
      final roleCode = data?["role"] ?? "admin";
      final name = data?["name"] ?? fbUser.email?.split("@").first.toUpperCase() ?? "User";

      final user = UserModel(
        id: fbUser.uid,
        email: fbUser.email ?? email,
        name: name,
        photoUrl: fbUser.photoURL ?? "https://i.pravatar.cc/150?img=12",
        role: UserRoleExtension.fromCode(roleCode),
        lastLogin: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserRole, user.role.code);
      return user;
    } catch (_) {
      return await _mockAuth.loginWithEmail(email, password);
    }
  }

  @override
  Future<UserModel> signupWithEmail(String name, String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = credential.user!;
      await fbUser.updateDisplayName(name);

      const defaultRole = UserRole.admin;
      await _firestore.collection("users").doc(fbUser.uid).set({
        "uid": fbUser.uid,
        "name": name,
        "email": email,
        "role": defaultRole.code,
        "createdAt": FieldValue.serverTimestamp(),
      });

      final newUser = UserModel(
        id: fbUser.uid,
        email: email,
        name: name,
        photoUrl: "https://i.pravatar.cc/150?img=33",
        role: defaultRole,
        lastLogin: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserRole, newUser.role.code);
      return newUser;
    } catch (_) {
      return await _mockAuth.signupWithEmail(name, email, password);
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      final googleProvider = fb.GoogleAuthProvider();
      final credential = await _firebaseAuth.signInWithPopup(googleProvider);
      final fbUser = credential.user!;

      final userDoc = _firestore.collection("users").doc(fbUser.uid);
      final snapshot = await userDoc.get();

      String roleCode = "admin";
      if (!snapshot.exists) {
        await userDoc.set({
          "uid": fbUser.uid,
          "name": fbUser.displayName ?? "Google User",
          "email": fbUser.email ?? "",
          "role": "admin",
          "createdAt": FieldValue.serverTimestamp(),
        });
      } else {
        roleCode = snapshot.data()?["role"] ?? "admin";
      }

      final user = UserModel(
        id: fbUser.uid,
        email: fbUser.email ?? "",
        name: fbUser.displayName ?? "Google User",
        photoUrl: fbUser.photoURL ?? "https://i.pravatar.cc/150?img=11",
        role: UserRoleExtension.fromCode(roleCode),
        lastLogin: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserRole, user.role.code);
      return user;
    } catch (_) {
      return await _mockAuth.loginWithGoogle();
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } catch (_) {
      await _mockAuth.sendPasswordResetEmail(email);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
    await _mockAuth.logout();
  }

  @override
  Future<void> updateUserRole(String userId, String roleCode) async {
    try {
      await _firestore.collection("users").doc(userId).update({
        "role": roleCode,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (_) {}
    await _mockAuth.updateUserRole(userId, roleCode);
  }
}
