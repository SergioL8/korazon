import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:korazon/src/screens/eventDetails.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';

class ProfileEventCard extends StatefulWidget {
  const ProfileEventCard({super.key, required this.document});
  final DocumentSnapshot document;

  @override
  State<ProfileEventCard> createState() => _ProfileEventCardState();
}
class _ProfileEventCardState extends State<ProfileEventCard> {
  bool isLikeAnimating = false;

  

  @override
  Widget build(BuildContext context) {

    EventModel? event = EventModel.fromDocumentSnapshot(widget.document);

    if (event == null) {
      return SizedBox();
    }

    final String dateTimeStr = event.dateTime; // e.g., "2025-01-15 22:00"

    String formattedDate = 'No Date'; // e.g., "January 15, 2025"
    String formattedTime = 'No time'; // e.g., "10:00 PM"

    if (dateTimeStr != '') {
      DateTime eventDateTime = DateTime.parse(dateTimeStr);

      // Format the date and time separately
      formattedDate = DateFormat('MMMM d, yyyy').format(eventDateTime); // e.g., "January 15, 2025"
      formattedTime = DateFormat('h:mm a').format(eventDateTime); // e.g., "10:00 PM"
    }

    return FutureBuilder<Uint8List?>(
      future: getImage(event.photoPath),
      builder: (context, snapshot) {
        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventDetails(
                event: event,
                imageData: snapshot.data,
                formattedDate: formattedDate,
                formattedTime: formattedTime,
                page: ParentPage.userProfile,
              ),
            ),
          ),

          /// We keep a `margin` so the card is spaced nicely,
          /// but remove any background color/shadow from the Container.
          child: Container(
            margin: const EdgeInsets.only(bottom: 16.0, right: 16, left: 16, top: 20),
            child: Column(
              children: [
                // Stack so the CircleAvatar can float over the clipped image.
                Stack(
                  children: [
                    // 1) Clip the image with a rounded border:
                    ClipRRect(
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
                          Container(
                            width: 44, // Adjust to fit your desired border size (radius + border thickness)
                            height: 44, // Same as width
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, 
                              border: Border.all(
                                color: Colors.white, // White border color
                                width: 2.0, // Border width
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: korazonColor,
                              backgroundImage: event.hostProfilePicUrl != ''
                                  ? NetworkImage(event.hostProfilePicUrl)
                                  : AssetImage(
                                      'assets/images/no_profile_picture.webp',
                                    ) as ImageProvider,
                              radius: 20, // Adjust to fit inside the container
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            event.hostName,
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
              ],
            ),
          ),
        );
      },
    );
  }
}