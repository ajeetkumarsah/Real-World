import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String profileImageUrl;
  final String email;
  final String bio;
  final String createdAt;
  final String chattingWith;

  User({
    this.id,
    this.name,
    this.profileImageUrl,
    this.email,
    this.bio,
    this.createdAt,
    this.chattingWith,
  });

  factory User.fromDoc(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      name: doc['name'],
      profileImageUrl: doc['profileImageUrl'],
      email: doc['email'],
      bio: doc['bio'] ?? '',
      createdAt: doc[ DateTime.now().millisecondsSinceEpoch.toString()],
      chattingWith: null,
    );
  }
}