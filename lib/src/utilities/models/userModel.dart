



import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {

  UserModel({
    required this.userID,
    required this.username,
    required this.email,
    required this.isHost,
    required this.name,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.academicYear,
    required this.bio,
    required this.qrCode,
    required this.tickets,
    required this.createdEvents,
    required this.profilePicUrl,
    required this.followers,
    required this.profilePicturesPath,
    required this.instaAcc,
    required this.snapAcc,
  });

  final String userID;
  final String email;
  final String username;
  final bool isHost;
  final String name;
  final String lastName;
  final String gender;
  final double age;
  final String academicYear;
  final String bio;
  final String qrCode;
  final List<String> tickets;
  final List<String> createdEvents;
  final String profilePicUrl;
  final List<String> followers;
  final List<String> profilePicturesPath;
  final String instaAcc;
  final String snapAcc;


  static UserModel? fromDocumentSnapshot(DocumentSnapshot doc) {

    final data = doc.data() as Map<String, dynamic>?;

    if (data == null || data.isEmpty) {
      return null;
    }

    return UserModel(
      userID: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? 'No username',
      isHost: data['isHost'] ?? false,
      name: data['name'] ?? 'No name',
      lastName: data['lastName'] ?? 'No last name',
      gender: data['gender'] ?? 'Unknown',
      age: (data['age'] is num) ? (data['age'] as num).toDouble() : -1.0,
      academicYear: data['academicYear'] ?? 'No academic year',
      bio: data['bio'] ?? '',
      qrCode: data['qrCode'] ?? '',
      tickets: List<String>.from(data['tickets'] ?? []),
      createdEvents: List<String>.from(data['createdEvents'] ?? []),
      profilePicUrl: data['profilePicUrl'] ?? '',
      followers: List<String>.from(data['followers'] ?? []),
      profilePicturesPath: List<String>.from(data['profilePicturesPath'] ?? []),
      instaAcc: data['instaAcc'] ?? '',
      snapAcc: data['snapAcc'] ?? '',
    );
  }
}