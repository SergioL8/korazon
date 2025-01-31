import 'package:cloud_firestore/cloud_firestore.dart';



// class Host {
//   Host({
//     required this.uidHost,
//     required this.profilePicHost,
//     required this.nameHost
//   });

//   final String uidHost;
//   final String profilePicHost;
//   final String nameHost;



//   factory Host
// }




class EventModel {

  EventModel({
    required this.documentID,
    required this.title,
    required this.description,
    required this.age,
    required this.location,
    required this.photoPath,
    required this.dateTime,
    required this.hostId,
    required this.hostName,
    required this.hostProfilePicUrl,
    required this.price,
    required this.ticketsSold
  });

  final String documentID;
  final String title;
  final String description;
  final double age;
  final String location;
  final String photoPath;
  final String dateTime;
  final String hostId;
  final String hostName;
  final String hostProfilePicUrl;
  final double price;
  final List<String> ticketsSold;


  static EventModel? fromDocumentSnapshot(DocumentSnapshot doc) {

    final data = doc.data() as Map<String, dynamic>?;

    if (data == null || data.isEmpty) { return null; }

    return EventModel(
      documentID: doc.id,
      title: data['title'] ?? 'No title',
      description: data['description'] ?? 'No description',
      age: (data['age'] is num) ? (data['age'] as num).toDouble() : -1.0, // if num convert it to double otherwise it doesn't exists to set it to -1
      location: data['location'] ?? 'No location',
      photoPath: data['photoPath'] ?? '',
      dateTime: data['dateTime'] ?? '',
      hostId: data['hostId'] ?? '',
      hostName: data['hostName'] ?? 'No host name',
      hostProfilePicUrl: data['hostProfilePicUrl'] ?? '',
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
      ticketsSold: List<String>.from(data['ticketsSold'] ?? []),
    );
  }
}


