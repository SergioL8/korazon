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
    this.ticketCapacity,
    this.genderRestriction = 'all',
    this.ticketHolders,
    this.userWithTicketsOnHold,
  });

  final String ticketID;
  final String ticketName;
  final double ticketPrice;
  final String? ticketDescription;
  final Timestamp? ticketEntryTimeStart;
  final Timestamp? ticketEntryTimeEnd;
  final int? ticketCapacity;
  final String genderRestriction;
  final List<String>? ticketHolders;
  final List<String>? userWithTicketsOnHold;

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
      'ticketHolders': ticketHolders ?? [],
      'userWithTicketsOnHold': userWithTicketsOnHold ?? [],
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
      ticketCapacity: (map['ticketCapacity'] is num) ? (map['ticketCapacity'] as num).toInt() : null,
      genderRestriction: map['genderRestriction'] ?? 'all',
      ticketHolders: (map['ticketHolders'] as List<dynamic>?)
          ?.map((holder) => holder as String)
          .toList() ?? [],
      userWithTicketsOnHold: (map['userWithTicketsOnHold'] as List<dynamic>?)
          ?.map((holder) => holder as String)
          .toList() ?? [],
    );
  }
}



class EventModel {

  EventModel({
    required this.documentID,
    required this.title,
    required this.description,
    required this.location,
    required this.photoPath,
    required this.startDateTime,
    required this.endDateTime,
    required this.plus21,
    required this.hostId,
    required this.hostName,
    required this.profilePicPath,
    required this.tickets,
    required this.stripeConnectedCustomerId,
    required this.eventTicketHolders,
  });

  final String documentID;
  final String title;
  final String description;
  final LocationModel? location;
  final String photoPath;
  final Timestamp startDateTime;
  final Timestamp? endDateTime;
  final bool plus21;
  final String hostId;
  final String hostName;
  final String profilePicPath;
  final List<TicketModel> tickets;
  final String? stripeConnectedCustomerId;
  final List<String>? eventTicketHolders;


  static EventModel? fromDocumentSnapshot(DocumentSnapshot doc) {

    final data = doc.data() as Map<String, dynamic>?;

    if (data == null || data.isEmpty) { return null; }

    return EventModel(
      documentID: doc.id,
      title: data['title'] ?? 'No title',
      description: data['description'] ?? '',
      location: data['location'] != null 
        ? LocationModel.fromMap(data['location'] as Map<String, dynamic>)
        : null,
      photoPath: data['photoPath'] ?? '',
      startDateTime: data['startDateTime'],
      endDateTime: data['endDateTime'],
      plus21: data['plus21'] ?? false,
      hostId: data['hostId'],
      hostName: data['hostName'] ?? 'No host name',
      profilePicPath: data['profilePicPath'] ?? '',
      tickets: (data['tickets'] as List<dynamic>?)
          ?.map((ticket) => TicketModel.fromMap(ticket as Map<String, dynamic>))
          .toList() ?? [],
      stripeConnectedCustomerId: data['stripeConnectedCustomerId'],
      eventTicketHolders: (data['eventTicketHolders'] as List<dynamic>?)?.map((holder) => holder as String).toList() ?? [],
    );
  }
}