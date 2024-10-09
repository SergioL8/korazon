import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? username; //this is a data map
  final String email;
  final String uid;
  final String? profilePicUrl;

  const User ({
    this.username,
    required this.email,
    required this.uid,
    this.profilePicUrl,
  });

  Map<String, dynamic> toJson() => {
    "username":username,
    "uid":uid,
    "email":email,
    "photoUrl":profilePicUrl,
  };

  static User fromSnap(DocumentSnapshot snap){ 
    //static makes a value not instance specific and it is shared in all instances of the class
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      email: snapshot['email'],
      username: snapshot['username'],
      uid: snapshot['uid'],
      profilePicUrl: snapshot['profilePicUrl'],
    );
  }
}