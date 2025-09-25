import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String role;
  final String username;
  final bool notificationsEnabled;
  final String? profileImageUrl;
  final String? phone;
  final String? bio;
  final DateTime? createdAt;
  final Timestamp? premiumExpiry;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.username,
    this.notificationsEnabled = true,
    this.profileImageUrl,
    this.phone,
    this.bio,
    this.createdAt,
    this.premiumExpiry,
  });

  /// Display name (maps to username for UI purposes)
  String get name => username;

  /// Check if user is premium
  bool get isPremium => role.toLowerCase() == 'premium';

  /// Check if user is admin
  bool get isAdmin => role.toLowerCase() == 'admin';

  /// Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'username': username,
      'notificationsEnabled': notificationsEnabled,
      'profileImageUrl': profileImageUrl,
      'phone': phone,
      'bio': bio,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'premiumExpiry': premiumExpiry,
    };
  }

  /// Create UserModel from Firestore document
  factory UserModel.fromDocument(
    String uid,
    Map<String, dynamic> data,
  ) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? 'no-email@example.com',
      role: data['role'] ?? 'user',
      username: data['username'] ?? 'Anonymous User',
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      profileImageUrl: data['profileImageUrl'],
      phone: data['phone'],
      bio: data['bio'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      premiumExpiry: data['premiumExpiry'] as Timestamp?,
    );
  }

  /// Create UserModel from Firestore DocumentSnapshot
  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromDocument(doc.id, data);
  }
}
