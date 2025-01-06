import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korazon/src/widgets/accessToEventWidgets/selectEventCard.dart';
import 'package:flutter/material.dart';






class SelectEventPage extends StatefulWidget {
  const SelectEventPage({super.key});

  @override
  _SelectEventPageState createState() => _SelectEventPageState();
}


class _SelectEventPageState extends State<SelectEventPage> {

  List<String> listOfCreatedEvents = [];
  bool _isLoading = true;


  /// This function retrieves the list of events created by the current user
  /// 
  /// No input, but it uses the current user ID to retrieve the list of events
  /// 
  /// Returns a list of event IDs
  void _getListOfEvents() async {
    
    // Get current user ID and check that it is not null
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print('Something went wrong please log out and login again. In the future use an alert box');
      return;
    }

    // Get the user document from Firestore and check that it exists
    final userDocument = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    print('userDocument ${userDocument.data()}');
    if (!userDocument.exists) {
      print('There was an error loading the events, try again later. In the future use an alert box');
      return;
    }
    
    // Get the list of event IDs from the user document
    setState(() {
      listOfCreatedEvents = List<String>.from(userDocument.data()?['createdEvents'] ?? []);
      _isLoading = false;
    });
  }



  @override
  void initState() {
    super.initState();
    _getListOfEvents();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : listOfCreatedEvents.isEmpty 
            ? Text("You don't have any events created") 
            : ListView.builder(
              itemCount: listOfCreatedEvents.length,
              itemBuilder: (context, index) {
                return SelectEventCard(eventID: listOfCreatedEvents[index]);
              },
            )
    );
  }

}