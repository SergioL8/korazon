import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:korazon/src/screens/eventDetails.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';

class EventCard extends StatefulWidget {
  const EventCard(
      {super.key, required this.document, required this.parentPage});
  final DocumentSnapshot document;
  final ParentPage parentPage;

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  Widget build(BuildContext context) {
    EventModel? event = EventModel.fromDocumentSnapshot(widget.document);

    if (event == null) {
      return SizedBox();
    }

    final Timestamp dateTimeStamp = event.startDateTime;
    DateTime dateTime = dateTimeStamp.toDate();

    String formattedDate =
        DateFormat('MMMM d, yyyy').format(dateTime); // e.g., "January 15, 2025"
    String formattedTime =
        DateFormat('h:mm a').format(dateTime); // e.g., "10:00 PM"

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Pink clipped rectangle (bottom)
        Container(
          margin: const EdgeInsets.only(
              top: 60,
              left: 16,
              right: 16), // Push it down to make space for image
          height: 200,
          decoration: BoxDecoration(
            color: korazonColor,
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // Narrower image (overlapping)
        Container(
          width: MediaQuery.of(context).size.width * 0.7, // ~70% width
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            image: const DecorationImage(
              image: AssetImage(
                  'assets/images/pary.jpg'), // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
