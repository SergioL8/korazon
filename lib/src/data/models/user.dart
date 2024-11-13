import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  
  final String email;
  final String uid;
  final bool isHost;
  final bool? gender;
  final String username; //this is a data map
  final String? name;
  final String? bio;
  final int? age;
  final String? profilePicUrl;
  final String? qrCode;
  final List? yourEvents;  //List with the event eventids
  final String? instagram;

  const User ({
    required this.email,
    required this.uid,
    required this.isHost,
    required this.username,
    this.gender,
    this.name,
    this.bio,
    this.age,
    this.profilePicUrl,
    this.qrCode,
    this.yourEvents,
    this.instagram,
  });

  Map<String, dynamic> toJson() => {
    "email": email,
    "uid":uid,
    "isHost": isHost,
    "gender": gender,
    "name": name,
    "bio": bio,
    "age": age,
    "profilePicUrl": profilePicUrl,
    "qrCode": qrCode,
    "yourEvents": yourEvents,
    "instagram": instagram,
  };

  static User fromSnap(DocumentSnapshot snap){ 
    //static makes a value not instance specific and it is shared in all instances of the class
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      email: snapshot['email'],
      uid: snapshot['uid'],
      isHost: snapshot['isHost'],
      gender: snapshot['gender'],
      username: snapshot['username'],
      name: snapshot['name'],
      bio: snapshot['bio'],
      age: snapshot['age'],
      profilePicUrl: snapshot['profilePicUrl'],
      qrCode: snapshot['qrCode'],
      yourEvents: snapshot['yourEvents'],
    );
  }
}