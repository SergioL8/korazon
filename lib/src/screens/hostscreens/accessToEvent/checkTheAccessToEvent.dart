import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/screens/hostscreens/accessToEvent/userDoesntHaveAccess.dart';
import 'package:korazon/src/screens/hostscreens/accessToEvent/userHasAccess.dart';



class CheckForAccessToEvent extends StatefulWidget {
  const CheckForAccessToEvent({super.key, required this.guestID, required this.eventID});
  final String guestID;
  final String eventID;

  @override
  State<CheckForAccessToEvent> createState() => _CheckForAccessToEventState();
}



class _CheckForAccessToEventState extends State<CheckForAccessToEvent> {
  
  Map<String, dynamic> userData = {};


  /// This function wll check if a user has in his list of events the event he is trying to access
  Future<bool> _checkAccessToEvent() async {

    // Get the user document and the user data
    final userDocument = await FirebaseFirestore.instance.collection('users').doc(widget.guestID).get();
    userData = userDocument.data() ?? {};
    
    // check that the user data is not empty
    if (userData.isEmpty) {
      print('There was an error loading the user, try again later. In the future use an alert box');
      return false;
    }

    // get the list of events that the user is attending 
    final List<String> eventsAttending = List<String>.from(userData['tickets'] ?? []);

    // check if the event ID is in the list of events the user is attending and return the result
    return eventsAttending.contains(widget.eventID);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: FutureBuilder<bool>(
          future: _checkAccessToEvent(), // check if the user has access to the event and store the result in snapshot
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) { // if checking is still in progress show a loading indicator
              return const CircularProgressIndicator();
            } else {
              if (snapshot.hasError) { // if there is an error show an error message
                return const Text('An error occurred, try again later'); // in the future change this to an alert box
              } else {
                if (snapshot.data == true) { // if the user has access to the event show the user access to event widget
                  return UserHasAccess(userData: userData, eventID: widget.eventID);
                } else { // if the user doesn't have access to the event show the user doesn't have access widget
                  return UserDoesntHaveAccess(userData: userData, eventID: widget.eventID);
                }
              }
            }
          },
        ),
      ),
    );
  }
}