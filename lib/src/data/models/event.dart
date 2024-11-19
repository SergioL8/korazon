import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  
  final String accountId;
  final String postId;
  final String? username; //this is a data map
  final String? eventName;
  final String eventImageUrl;
  final String? description;
  final String? eventAge;
  final String? profilePicUrl;

  //ADD later: date, time and place 


  const Event ({
    required this.accountId,
    required this.postId,
    required this.username,
    this.eventName,
    this.description,
    required this.eventImageUrl,
    this.eventAge,
    this.profilePicUrl,
  });

  Map<String, dynamic> toJson() => {
      "uid": accountId,
      "postId":postId,
      "username": username,
      "eventName": eventName,
      "description": description,
      "eventImage": eventImageUrl,
      "eventAge": eventAge,
      "profilePicUrl": profilePicUrl,
    };

  static Event fromSnap(DocumentSnapshot snap){ 
    //static makes a value not instance specific and it is shared in all instances of the class
    var snapshot = snap.data() as Map<String, dynamic>;

    return Event(
      accountId: snapshot['uid'],
      postId: snapshot['postId'],
      username: snapshot['username'],
      eventName: snapshot['eventName'],
      description: snapshot['description'],
      eventImageUrl: snapshot['eventImage'],
      eventAge: snapshot['eventAge'],
      profilePicUrl: snapshot['profilePicUrl'],
    );
  }
}