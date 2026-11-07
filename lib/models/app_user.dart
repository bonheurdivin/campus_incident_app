import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class AppUser {
  final String uid, name, email;
  final UserRole role;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  bool get isStaff => role == UserRole.staff;

  factory AppUser.fromMap(String uid, Map<String, dynamic> m) => AppUser(
        uid: uid,
        name: m['name'] ?? '',
        email: m['email'] ?? '',
        role: UserRole.values.byName(m['role'] ?? 'student'),
        createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role.name,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}