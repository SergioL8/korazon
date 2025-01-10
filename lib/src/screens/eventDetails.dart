import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/screens/buyTicketPage.dart';
import 'package:korazon/src/screens/hostscreens/hostProfile.dart';
import 'package:korazon/src/utilities/design_variables.dart';

class EventDetails extends StatelessWidget {
  const EventDetails({
    Key? key,
    required this.document,
    required this.imageData,
    required this.formattedDate,
    required this.formattedTime,
  }) : super(key: key);

  final DocumentSnapshot document;
  final Uint8List? imageData;
  final String formattedDate;
  final String formattedTime;


  @override
  Widget build(BuildContext context) {
    final String eventName = document['title'];
    final String eventDescription = document['description'];
    final double eventAge = document['age'];
    final String eventID = document.id;

    return Scaffold(
      // AppBar with a slightly transparent background
      appBar: AppBar(
        title: Text('Event Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: korazonColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

             // === Event Name ===

                        Padding(
                          padding: const EdgeInsets.only(left: 32,right: 32, top: 16),
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
                  tag: document.id,
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
                            builder: (context) => HostProfileScreen(uid: document['host']))),
                            child: Row(
                            children: [
                              Icon(Icons.person, color: korazonColor),
                          
                              SizedBox(width: 8),
                          
                              Text(
                                'Host Name',
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
                              formattedDate,
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
                              'Age: $eventAge+',
                              style: const TextStyle(
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
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                useSafeArea: true,
                                isScrollControlled: true,
                                context: context,
                                builder: (ctx) => SafeArea(
                                  child: BuyTicketPage(eventID: eventID),
                                ),
                              );
                            },
                            child: const Text(
                              'Buy Ticket',
                              style: TextStyle(
                                fontSize: 16,
                                color: secondaryColor
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