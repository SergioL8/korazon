import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  
  final String uid;
  final String username; //this is a data map
  final String eventName;
  final String eventImage;
  final String description;
  final String? eventAge;
  final String? profilePicUrl;

  //ADD later: date, time and place 


  const Event ({
    required this.uid,
    required this.username,
    required this.eventName,
    required this.description,
    required this.eventImage,
    this.eventAge,
    this.profilePicUrl,
  });

  Map<String, dynamic> toJson() => {
      "uid": uid,
      "username": username,
      "eventName": eventName,
      "description": description,
      "eventImage": eventImage,
      "eventAge": eventAge,
      "profilePicUrl": profilePicUrl,
    };

  static Event fromSnap(DocumentSnapshot snap){ 
    //static makes a value not instance specific and it is shared in all instances of the class
    var snapshot = snap.data() as Map<String, dynamic>;

    return Event(
      uid: snapshot['uid'],
      username: snapshot['username'],
      eventName: snapshot['eventName'],
      description: snapshot['description'],
      eventImage: snapshot['eventImage'],
      eventAge: snapshot['eventAge'],
      profilePicUrl: snapshot['profilePicUrl'],
    );
  }
}