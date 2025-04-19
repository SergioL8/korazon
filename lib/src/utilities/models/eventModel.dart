import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/models/userModel.dart';




class EventModel {

  EventModel({
    required this.documentID,
    required this.title,
    required this.description,
    required this.age,
    required this.location,
    required this.photoPath,
    required this.startDateTime,
    required this.endDateTime,
    required this.hostId,
    required this.hostName,
    required this.profilePicPath,
    required this.price,
    required this.ticketsSold
  });

  final String documentID;
  final String title;
  final String description;
  final double age;
  final LocationModel? location;
  final String photoPath;
  final Timestamp startDateTime;
  final Timestamp? endDateTime;
  final String hostId;
  final String hostName;
  final String profilePicPath;
  final double price;
  final List<String> ticketsSold;


  static EventModel? fromDocumentSnapshot(DocumentSnapshot doc) {

    final data = doc.data() as Map<String, dynamic>?;

    if (data == null || data.isEmpty) { return null; }

    return EventModel(
      documentID: doc.id,
      title: data['title'] ?? 'No title',
      description: data['description'] ?? '',
      age: (data['age'] is num) ? (data['age'] as num).toDouble() : -1.0, // if num convert it to double otherwise it doesn't exists to set it to -1
      location: data['location'] != null 
        ? LocationModel.fromMap(data['location'] as Map<String, dynamic>)
        : null,
      photoPath: data['photoPath'] ?? '',
      startDateTime: data['startDateTime'],
      endDateTime: data['endDateTime'],
      hostId: data['hostId'] ?? '',
      hostName: data['hostName'] ?? 'No host name',
      profilePicPath: data['profilePicPath'] ?? '',
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
      ticketsSold: List<String>.from(data['ticketsSold'] ?? []),
    );
  }
}


