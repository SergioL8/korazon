import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/screens/hostscreens/accessToEvent/userDoesntHaveAccess.dart';
import 'package:korazon/src/screens/hostscreens/accessToEvent/userHasAccess.dart';


class UserAccessToEvent extends StatelessWidget {
  UserAccessToEvent({super.key, required this.guestID, required this.eventID});
  final String guestID;
  final String eventID;
  Map<String, dynamic> userData = {};


  Future<bool> checkAccessToEvent() async {

    final userDocument = await FirebaseFirestore.instance.collection('users').doc(guestID).get();
    userData = userDocument.data() ?? {};
    
    if (userData.isEmpty) {
      print('There was an error loading the user, try again later. In the future use an alert box');
      return false;
    }

    final List<String> eventsAttending = List<String>.from(userData['tickets'] ?? []);

    if (eventsAttending.contains(eventID)) {
      return true;
    } else {
      return false;
    }
  }

  

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: FutureBuilder<bool>(
          future: checkAccessToEvent(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              if (snapshot.hasError) {
                return const Text('An error occurred, try again later');
              } else {
                if (snapshot.data == true) {
                  return UserHasAccess(userData: userData);
                } else {
                  return UserDoesntHaveAccess(userData: userData);
                }
              }
            }
          },
        ),
      ),
    );
  }
}