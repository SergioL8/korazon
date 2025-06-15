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
      return const SizedBox();
    }

    final Timestamp dateTimeStamp = event.startDateTime;
    DateTime dateTime = dateTimeStamp.toDate();

    String formattedDateTime =
        DateFormat('MMM d, HH:mm').format(dateTime).toUpperCase();
// Example: "FEB 14, 20:00"

//! Formatted date and time are not used is just for it to compile with EventDetails
    String formattedDate =
        DateFormat('MMMM d, yyyy').format(dateTime); // e.g., "January 15, 2025"
    String formattedTime =
        DateFormat('h:mm a').format(dateTime); // e.g., "10:00 PM"

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double imageHeight =
        screenWidth * 0.82 * (4 / 3); // because aspect ratio is 3:4
    double pinkBoxHeight = screenHeight * 0.3;
    double overlap = screenHeight * 0.18;

    return FutureBuilder<Uint8List?>(
      future: getImage(event.photoPath),
      builder: (context, snapshot) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: screenHeight * 0.06,
            right: screenWidth * 0.02,
            left: screenWidth * 0.02,
          ),
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EventDetails(
                  event: event,
                  imageData: snapshot.data,
                  formattedDate: formattedDate,
                  formattedTime: formattedTime,
                ),
              ),
            ),
            child: SizedBox(
              height: imageHeight + pinkBoxHeight - overlap,
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  // 1. Pink container
                  Container(
                    height: pinkBoxHeight,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: korazonColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Spacer to push content to the bottom
                        const Spacer(),

                        // Host row (profile + name)
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: CircleAvatar(
                                backgroundColor: korazonColor,
                                backgroundImage: event.profilePicPath.isNotEmpty
                                    ? NetworkImage(event.profilePicPath)
                                    : const AssetImage(
                                            'assets/images/no_profile_picture.webp')
                                        as ImageProvider,
                                radius: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              event.hostName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                            height: 8), // Space between row and title

                        // Event title (bottom)
                        Row(
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            Spacer(),
                            Text(
                              formattedDateTime,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 2. Image (overlapping)
                  Positioned(
                    bottom: pinkBoxHeight - overlap,
                    child: Container(
                      width: screenWidth * 0.85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Hero(
                            tag: event.documentID,
                            flightShuttleBuilder: (
                              flightContext,
                              animation,
                              flightDirection,
                              fromHeroContext,
                              toHeroContext,
                            ) {
                              final curvedAnimation = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              );
                              return AnimatedBuilder(
                                animation: curvedAnimation,
                                builder: (context, child) {
                                  return flightDirection ==
                                          HeroFlightDirection.push
                                      ? toHeroContext.widget
                                      : fromHeroContext.widget;
                                },
                              );
                            },
                            child: FadeInImage(
                              placeholder: MemoryImage(kTransparentImage),
                              image: snapshot.data != null
                                  ? MemoryImage(snapshot.data!)
                                  : const AssetImage('assets/images/pary.jpg')
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
