import 'package:cloud_firestore/cloud_firestore.dart';

class LocationModel {
  LocationModel({
    required this.description,
    required this.verifiedAddress,
    this.placeID,
    this.lat,
    this.lon,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  final String description;
  final bool verifiedAddress;
  final String? placeID;
  final double? lat;
  final double? lon;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'verifiedAddress': verifiedAddress,
      'placeID': placeID,
      'lat': lat,
      'lon': lon,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      description: map['description'] ?? '',
      verifiedAddress: map['verifiedAddress'] ?? false,
      placeID: map['placeID'],
      lat: map['lat'],
      lon: map['lon'],
      city: map['city'],
      state: map['state'],
      country: map['country'],
      postalCode: map['postalCode'],
    );
  }
}

class UserModel {
  UserModel({
    required this.userID,
    required this.username,
    required this.email,
    required this.isHost,
    required this.isVerifiedHost,
    required this.name,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.academicYear,
    required this.bio,
    required this.qrCode,
    required this.tickets,
    required this.createdEvents,
    required this.profilePicPath,
    required this.followers,
    required this.profilePicturesPath,
    required this.instaAcc,
    required this.snapAcc,
    required this.location,
  });

  final String userID;
  final String email;
  final String username;
  final bool isHost;
  final bool isVerifiedHost;
  final String name;
  final String lastName;
  final String gender;
  final double age;
  final String academicYear;
  final String bio;
  final String qrCode;
  final List<String> tickets;
  final List<String> createdEvents;
  final String profilePicPath;
  final List<String> followers;
  final List<String> profilePicturesPath;
  final String instaAcc;
  final String snapAcc;
  final LocationModel? location;

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
      isVerifiedHost: data['isVerifiedHost'] ?? false,
      name: data['name'] ?? 'No name',
      lastName: data['lastName'] ?? 'No last name',
      gender: data['gender'] ?? 'Unknown',
      age: (data['age'] is num) ? (data['age'] as num).toDouble() : -1.0,
      academicYear: data['academicYear'] ?? 'No academic year',
      bio: data['bio'] ?? '',
      qrCode: data['qrCode'] ?? '',
      tickets: List<String>.from(data['tickets'] ?? []),
      createdEvents: List<String>.from(data['createdEvents'] ?? []),
      profilePicPath: data['profilePicPath'] ?? '',
      followers: List<String>.from(data['followers'] ?? []),
      profilePicturesPath: List<String>.from(data['profilePicturesPath'] ?? []),
      instaAcc: data['instaAcc'] ?? '',
      snapAcc: data['snapAcc'] ?? '',
      location: data['location'] != null
          ? LocationModel.fromMap(data['location'] as Map<String, dynamic>)
          : null,
    );
  }
}
