import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/models/userModel.dart';



class TicketModel {
  TicketModel({
    required this.ticketID,
    required this.ticketName,
    required this.ticketPrice,
    this.ticketDescription,
    this.ticketEntryTimeStart,
    this.ticketEntryTimeEnd,
    this.ticketCapacity = 9999999,
    this.genderRestriction = 'all',
    this.ticketsSold,
  });

  final String ticketID;
  final String ticketName;
  final double ticketPrice;
  final String? ticketDescription;
  final Timestamp? ticketEntryTimeStart;
  final Timestamp? ticketEntryTimeEnd;
  final int? ticketCapacity;
  final String genderRestriction;
  final int? ticketsSold;

  Map<String, dynamic> toMap() {
    return {
      'documentID': ticketID,
      'ticketName': ticketName,
      'ticketPrice': ticketPrice,
      'ticketDescription': ticketDescription,
      'ticketEntryTimeStart': ticketEntryTimeStart,
      'ticketEntryTimeEnd': ticketEntryTimeEnd,
      'ticketCapacity': ticketCapacity,
      'genderRestriction': genderRestriction,
      'ticketsSold': ticketsSold,
    };
  }

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      ticketID: map['documentID'],
      ticketName: map['ticketName'] ?? 'No Ticket Name',
      ticketPrice: (map['ticketPrice'] is num) ? (map['ticketPrice'] as num).toDouble() : 0.0,
      ticketDescription: map['ticketDescription'] ?? '',
      ticketEntryTimeStart: map['ticketEntryTimeStart'],
      ticketEntryTimeEnd: map['ticketEntryTimeEnd'],
      ticketCapacity: (map['ticketCapacity'] is num) ? (map['ticketCapacity'] as num).toInt() : 999999999,
      genderRestriction: map['genderRestriction'] ?? 'all',
      ticketsSold: (map['ticketsSold'] is num) ? (map['ticketsSold'] as num).toInt() : null,
    );
  }
}



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


