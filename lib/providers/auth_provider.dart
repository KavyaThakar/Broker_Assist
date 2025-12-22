
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _initialized = false;

  final List<UserModel> _allUsers = [];

  // ---------------- PHONE OTP STATE ----------------
  String _verificationId = "";
  bool otpSent = false;

  List<UserModel> get allUsers => List.unmodifiable(_allUsers);

  AuthProvider() {
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        _currentUser = null;
      } else {
        await _fetchUserFromFirestore(user.uid);
      }

      _initialized = true;
      notifyListeners();
    });

    _boot();
  }

  Future<void> _boot() async {
    await _loadFirebaseUser();
    await refreshUsers();
    _initialized = true;
    notifyListeners();
  }

  bool get initialized => _initialized;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> _loadFirebaseUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _fetchUserFromFirestore(user.uid);
    }
  }

  Future<void> _fetchUserFromFirestore(String uid) async {
    try {
      final doc = await _db.collection("users").doc(uid).get();
      if (!doc.exists) return;

      final data = doc.data()!;

      _currentUser = UserModel(
        id: uid,
        name: data["name"] ?? "",
        email: data["email"] ?? "",
        role: data["role"] ?? "",
      );

      notifyListeners();
    } catch (_) {}
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _db.collection("users").doc(cred.user!.uid).set({
        "name": name.trim(),
        "email": email.trim().toLowerCase(),
        "role": role,
        "createdAt": FieldValue.serverTimestamp(),
      });

      await _fetchUserFromFirestore(cred.user!.uid);
      await refreshUsers();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _fetchUserFromFirestore(_auth.currentUser!.uid);
      await refreshUsers();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  List<UserModel> getAllUsers() {
    return List.unmodifiable(_allUsers);
  }

  Future<void> refreshUsers() async {
    try {
      final snap = await _db.collection("users").get();

      _allUsers.clear();
      for (var doc in snap.docs) {
        _allUsers.add(
          UserModel(
            id: doc.id,
            name: doc.data()["name"] ?? "",
            email: doc.data()["email"] ?? "",
            role: doc.data()["role"] ?? "",
          ),
        );
      }

      notifyListeners();
    } catch (_) {}
  }

  Future<String?> updateName(String newName) async {
    try {
      if (_currentUser == null) return "User not logged in";

      await _db.collection("users").doc(_currentUser!.id).update({
        "name": newName,
      });

      _currentUser = UserModel(
        id: _currentUser!.id,
        name: newName,
        email: _currentUser!.email,
        role: _currentUser!.role,
      );

      await refreshUsers();
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ---------------------------------------------------------------
  // 🔥 PHONE OTP MODULE (FINAL CLEAN VERSION)
  // ---------------------------------------------------------------

  Future<String?> sendOtp(String phone) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          return;
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          otpSent = true;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> verifyOtp(String otpCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otpCode,
      );

      await _auth.signInWithCredential(credential);

      await _fetchUserFromFirestore(_auth.currentUser!.uid);
      await refreshUsers();

      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
