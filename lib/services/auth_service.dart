import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../models/enums.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get authChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> register(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = AppUser(
      uid: cred.user!.uid,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      role: UserRole.student, // everyone starts as a student
      createdAt: DateTime.now(),
    );
    await _db.collection('users').doc(user.uid).set(user.toMap());
    await cred.user!.sendEmailVerification();
  }

  Future<void> login(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> logout() => _auth.signOut();

  Future<void> resendVerification() =>
      _auth.currentUser!.sendEmailVerification();

  Future<User?> reloadUser() async {
    await _auth.currentUser?.reload();
    await _auth.currentUser?.getIdToken(true); // refresh token claims
    return _auth.currentUser;
  }

  Future<AppUser?> fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? AppUser.fromMap(uid, doc.data()!) : null;
  }
}