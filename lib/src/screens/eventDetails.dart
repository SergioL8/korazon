import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:korazon/src/screens/buyTicketPage.dart';
import 'package:korazon/src/screens/hostscreens/hostProfile.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';
import 'package:korazon/src/utilities/design_variables.dart';

class EventDetails extends StatelessWidget {
  const EventDetails({
    Key? key,
    required this.event,
    required this.imageData,
    required this.formattedDate,
    required this.formattedTime,
  });

  final EventModel event;
  final Uint8List? imageData;
  final String formattedDate;
  final String formattedTime;

  @override
  Widget build(BuildContext context) {

    final String eventName = event.title;
    final String eventDescription = event.description;
    final bool plus21 = event.plus21;
    final String hostName = event.hostName;
    final String hostId = event.hostId;
    final String hostProfilePicUrl = event.profilePicPath;


    return Scaffold(
      // AppBar with a slightly transparent background
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Event Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
        elevation: 0,
        backgroundColor: appBarColor,
        bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2.0),
              child: Container(
                color: dividerColor,
                height: barThickness,
              ),
            ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // === Event Name ===

            Padding(
              padding: const EdgeInsets.only(left: 32, right: 32, top: 16),
              child: Text(
                eventName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // === Hero Image ===
            // Put the image in a top container with rounded corners
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Hero(
                  tag: event.documentID,
                  child: imageData != null
                      ? Image.memory(imageData!, fit: BoxFit.cover)
                      : Image.asset(
                          'assets/images/pary.jpg',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),

            // === Overlapping Card ===
            // Use Stack to overlap the Card with the hero image
            Stack(
              clipBehavior: Clip.none,
              children: [
                // The Card (some padding and margin for style)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // === Creator Name ===
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HostProfileScreen(uid: hostId))),
                          child: Row(
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
                              backgroundImage: hostProfilePicUrl != ''
                                  ? NetworkImage(hostProfilePicUrl)
                                  : AssetImage(
                                      'assets/images/no_profile_picture.webp',
                                    ) as ImageProvider,
                              radius: 20, // Adjust to fit inside the container
                            ),
                          ),
                              SizedBox(width: 8),
                              Text(
                                hostName, 
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // === Event Description ===
                        Text(
                          eventDescription,
                          style: const TextStyle(
                            fontSize: 16,
                            color: secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // === Event Description ===
                        Row(
                          children: [
                            Text(
                              formattedDate, // Can't be null because required by the constructor
                              style: const TextStyle(
                                fontSize: 16,
                                color: secondaryColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              formattedTime,
                              style: const TextStyle(
                                fontSize: 16,
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // === Event Age ===
                        Row(
                          children: [
                            Text(
                              '+21: ${plus21.toString()}',
                              style: const TextStyle(
                                color: secondaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        // Center "Buy Ticket" button
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: korazonColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                useSafeArea: true,
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                ),
                                context: context,
                                builder: (ctx) => FractionallySizedBox(
                                  heightFactor:
                                      0.35, // Occupies 35% of the screen height
                                  child: BuyTicketPage(event: event),
                                ),
                              );
                            },
                            child: const Text(
                              'Buy Now',
                              style: TextStyle(
                                  fontSize: 24, 
                                  color: secondaryColor,
                                  fontWeight: FontWeight.w800
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Add spacing below
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
