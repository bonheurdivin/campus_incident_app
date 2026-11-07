import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  late final StreamSubscription<User?> _sub;

  User? firebaseUser;
  AppUser? appUser;
  bool initializing = true;
  bool busy = false;
  String? error;

  AuthProvider(this._service) {
    _sub = _service.authChanges.listen(_onAuthChanged);
  }

  bool get isLoggedIn => firebaseUser != null;
  bool get isVerified => firebaseUser?.emailVerified ?? false;
  bool get isStaff => appUser?.isStaff ?? false;

  Future<void> _onAuthChanged(User? user) async {
    firebaseUser = user;
    appUser = user == null ? null : await _service.fetchUser(user.uid);
    initializing = false;
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password) =>
      _run(() async {
        await _service.register(name, email, password);
        appUser = await _service.fetchUser(_service.currentUser!.uid);
      });

  Future<bool> login(String email, String password) =>
      _run(() => _service.login(email, password));

  Future<void> logout() => _service.logout();

  Future<bool> resendVerification() => _run(_service.resendVerification);

  Future<void> checkVerified() async {
    firebaseUser = await _service.reloadUser();
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      error = e.message ?? 'Something went wrong';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}