import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:korazon/src/screens/eventDetails.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:transparent_image/transparent_image.dart';

class EventCard extends StatefulWidget {
  const EventCard({super.key, required this.document});
  final DocumentSnapshot document;

  @override
  State<EventCard> createState() => _EventCardState();
}
class _EventCardState extends State<EventCard> {
  bool isLikeAnimating = false;

  @override
  Widget build(BuildContext context) {

    final String dateTimeStr = widget.document['dateTime']; // e.g., "2025-01-15 22:00"
    DateTime eventDateTime = DateTime.parse(dateTimeStr);

    // Format the date and time separately
    String formattedDate = DateFormat('MMMM d, yyyy').format(eventDateTime); // e.g., "January 15, 2025"
    String formattedTime = DateFormat('h:mm a').format(eventDateTime); // e.g., "10:00 PM"

    return FutureBuilder<Uint8List?>(
      future: getImage(widget.document['photoPath']),
      builder: (context, snapshot) {
        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventDetails(
                document: widget.document,
                imageData: snapshot.data,
                formattedDate: formattedDate,
                formattedTime: formattedTime,
              ),
            ),
          ),

          /// We keep a `margin` so the card is spaced nicely,
          /// but remove any background color/shadow from the Container.
          child: Container(
            margin: const EdgeInsets.only(bottom: 16.0, right: 16, left: 16),
            child: Column(
              children: [
                // Stack so the CircleAvatar can float over the clipped image.
                Stack(
                  children: [
                    // 1) Clip the image with a rounded border:
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Hero(
                        tag: widget.document.id,
                        flightShuttleBuilder: (
                          flightContext,
                          animation,
                          flightDirection,
                          fromHeroContext,
                          toHeroContext,
                        ) {
                          // Keep your slower animation curve:
                          final curvedAnimation = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          );
                          return AnimatedBuilder(
                            animation: curvedAnimation,
                            builder: (context, child) {
                              return flightDirection == HeroFlightDirection.push
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
                          height: 400,
                          width: double.infinity,
                        ),
                      ),
                    ),

                    // 2) Position the CircleAvatar so it overlaps the image:
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: korazonColor,
                            backgroundImage: widget.document['profilePicUrl'] != null ?  AssetImage(
                              widget.document['profilePicUrl'],
                            ):AssetImage(
                              'assets/images/no_profile_picture.webp',
                            ),
                            radius: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.document['hostName']?? 'No host name',
                            //widget.document['hostName'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: tertiaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // (Optional) If you still want the "Host Name" below the image,
                // simply add it here (or inside a separate Padding/Row):
                

              
                // Date and Time Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Date
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today, 
                                  color: secondaryColor,
                                  size: 24,
                                  ),
                                const SizedBox(width: 6),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                            // Time
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time, 
                                  color: secondaryColor,
                                   size: 24,
                                   ),
                                const SizedBox(width: 6),
                                Text(
                                  formattedTime,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}