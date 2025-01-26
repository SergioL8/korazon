



import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {

  UserModel({
    required this.userID,
    required this.email,
    required this.isHost,
    required this.name,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.bio,
    required this.qrCode,
    required this.tickets,
    required this.createdEvents,
    required this.profilePicUrl,
    required this.followers,
  });

  final String userID;
  final String email;
  final bool isHost;
  final String name;
  final String lastName;
  final String gender;
  final int age;
  final String bio;
  final String qrCode;
  final List<String> tickets;
  final List<String> createdEvents;
  final String profilePicUrl;
  final List<String> followers;


  static UserModel? fromDocumentSnapshot(DocumentSnapshot doc) {

    final data = doc.data() as Map<String, dynamic>?;

    if (data == null || data.isEmpty) {
      return null;
    }

    return UserModel(
      userID: doc.id,
      email: data['email'] ?? '',
      isHost: data['isHost'] ?? false,
      name: data['name'] ?? 'No name',
      lastName: data['lastName'] ?? 'No last name',
      gender: data['gender'] ?? 'Unknown',
      age: data['age'] ?? -1,
      bio: data['bio'] ?? '',
      qrCode: data['qrCode'] ?? '',
      tickets: List<String>.from(data['tickets'] ?? []),
      createdEvents: List<String>.from(data['createdEvents'] ?? []),
      profilePicUrl: data['profilePicUrl'] ?? '',
      followers: List<String>.from(data['followers'] ?? []),
    );
  }
}