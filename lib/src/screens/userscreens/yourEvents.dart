import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/eventCard.dart';

class YourEvents extends StatefulWidget {
  const YourEvents({super.key});

  @override
  State<YourEvents> createState() => _YourEventsState();
}

class _YourEventsState extends State<YourEvents> {
  List<String> eventUids = []; // List to store event UIDs
  List<DocumentSnapshot> events = []; // List to store event details as DocumentSnapshots
  
  @override
  void initState() {
    super.initState();
    getEvents();
  }

  // Fetch the user's tickets and retrieve event details
  Future<void> getEvents() async {
    try {
      // Get the current user's document
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        // Extract the 'tickets' array from the user document
        List<dynamic> tickets = userDoc.data()?['tickets'] ?? [];

        setState(() {
          // Convert the retrieved tickets into List<String>
          eventUids = tickets.cast<String>(); 
        });

        // Fetch event details for each event UID
        // This goes to the list of all events to find if they match any of the ones 
        // in your tickets list.

        for (String uid in eventUids) {
          var eventDoc = await FirebaseFirestore.instance
              .collection('events')
              .doc(uid)
              .get();

          if (eventDoc.exists) {
            setState(() {
              // Add event details to the list
              // Here we are passing the event info as a snapshot which is the default setting
              events.add(eventDoc); 
            }); 
          } 
        } 
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: eventUids.isEmpty
          ? const Center(
            child: Text('You dont have any events yet, lets find some'), // Show a loader while fetching data
            )
          : ListView.builder(
            // Remember the index is what changes in the ListView.builder, 
            // along the count of itemCount, then we just display each Card
            // according to the info of that specific index in your list

              itemCount: events.length,
              itemBuilder: (context, index) {
              final event = events[index];

                //! Fill with the list of your events
              // The event card needs to take a document snapshot 
              return EventCard(
                document: event,
              );
              },
            ),
    );
  }
}

