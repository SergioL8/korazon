import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/widgets/eventCard.dart';

class YourEvents extends StatefulWidget {
  const YourEvents({super.key});

  @override
  State<YourEvents> createState() => _YourEventsState();
}

class _YourEventsState extends State<YourEvents> {

  List<String> eventUids = []; // List to store event UIDs
  List<DocumentSnapshot> events = []; // List to store event details as DocumentSnapshots
  bool _isLoading = true;
  

  @override
  void initState() {
    super.initState();
    getEvents();
  }



  // Fetch the user's tickets and retrieve event details
  Future<void> getEvents() async {
    setState(() {
      _isLoading = true;
    });

    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      showErrorMessage(context, content: 'There was an error loading your user. Please logout and login back again.', errorAction: ErrorAction.logout);
      return;
    }
    try {
      // Get the current user's document
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      final UserModel? user = UserModel.fromDocumentSnapshot(userDoc);

      if (user == null) {
        showErrorMessage(context, content: 'There was an error loading your user. Please logout and login back again.', errorAction: ErrorAction.logout);
        return;
      }


      setState(() {
        // Extract the fetched tickets array and turn them into a list 
        eventUids = user.tickets;
      });

      // Fetch event details for each event UID
      // This goes to the list of all events to find if they match any of the ones in your tickets list.
      for (String uid in eventUids) {
        var eventDoc = await FirebaseFirestore.instance
            .collection('events')
            .doc(uid)
            .get();
        
        EventModel? tempEvent = EventModel.fromDocumentSnapshot(eventDoc);

        if (tempEvent != null) {
          setState(() {
            // Add event details to the list
            // Here we are passing the event info as a snapshot which is the default setting
            events.add(eventDoc); 
          }); 
        }
      } 
      
    } catch (e) {
      showErrorMessage(context, content: e.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tertiaryColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          'Your Events',
          style: TextStyle(
                  color: secondaryColor,
                  fontWeight: primaryFontWeight,
                  fontSize: 32.0,
                ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(
              color: dividerColor,
              height: barThickness,
            ),
          ),
      ),
      body: _isLoading 
      ? const Center(
        child: CircularProgressIndicator(),
      )
      :eventUids.isEmpty
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

