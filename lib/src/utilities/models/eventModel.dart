import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/models/userModel.dart';

class TicketModel {
  TicketModel({
    required this.ticketID,
    required this.eventID,
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
  final String eventID;
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
      'eventID': eventID,
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
      eventID: map['eventID'],
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

    // Event information
    required this.title,
    required this.description,
    required this.location,
    required this.photoPath,
    required this.startDateTime,
    required this.endDateTime,
    required this.plus21,

    // Host information
    required this.hostId,
    required this.hostName,
    required this.hostProfilePicPath,
    required this.stripeConnectedCustomerId,

    // Tickets and atendees
    required this.tickets,
    required this.eventTicketHolders,
    required this.attendees,
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
  final String hostProfilePicPath;
  final List<TicketModel> tickets;
  final String? stripeConnectedCustomerId;
  final List<String>? eventTicketHolders;
  final List<String>? attendees;


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
      hostProfilePicPath: data['hostProfilePicPath'] ?? '',
      tickets: (data['tickets'] as List<dynamic>?)
          ?.map((ticket) => TicketModel.fromMap(ticket as Map<String, dynamic>))
          .toList() ?? [],
      stripeConnectedCustomerId: data['stripeConnectedCustomerId'],
      eventTicketHolders: (data['eventTicketHolders'] as List<dynamic>?)?.map((holder) => holder as String).toList() ?? [],
      attendees: (data['attendees'] as List<dynamic>?)?.map((holder) => holder as String).toList() ?? [],
    );
  }
}