import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String hostId;
  final String? hostName;
  final String? hostProfilePicture;
  final String photoPath;
  final String title;
  final String description;
  final String location;
  final String dateTime;
  final double age;
  final double price;
 


  const Event ({
    required this.hostId,
    required this.hostName,
    required this.hostProfilePicture,
    required this.photoPath,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.age,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    "hostId": hostId,
    "hostName": hostName,
    "hostProfilePicture": hostProfilePicture,
    "photoPath": photoPath,
    "title": title,
    "description": description,
    "location": location,
    "dateTime": dateTime,
    "age": age,
    "price": price,
    };

  static Event fromSnap(DocumentSnapshot snap){ 
    //static makes a value not instance specific and it is shared in all instances of the class
    var snapshot = snap.data() as Map<String, dynamic>;

    return Event(
      hostId: snapshot['hostId'] as String,
      hostName: snapshot['hostName'] as String,
      hostProfilePicture: snapshot['hostProfilePicture'] as String,
      photoPath: snapshot['photoPath'] as String,
      title: snapshot['title'] as String,
      description: snapshot['description'] as String,
      location: snapshot['location'] as String,
      dateTime: snapshot['dateTime'] as String,
      age: snapshot['age'] as double,
      price: snapshot['price'] as double,  //added this line to match the property type in the json object
     
    );
  }
}