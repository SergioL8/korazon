import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/widgets/selectEventCard.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/utils.dart';



/// This class is used as a previous step for the host to select what event he wants to scan or see the analytics
/// 
/// The user will be able to see a list of events that he has created and select one of them to continue
/// 
/// The action input is an enum defined in the utils file that has two values, scan and analytics
class SelectEventForAction extends StatefulWidget {
  const SelectEventForAction({super.key, required this.action});
  final HostAction action; // this variable is used to differentiate between the scan page and the analytics page

  @override
  _SelectEventForActionState createState() => _SelectEventForActionState();
}




class _SelectEventForActionState extends State<SelectEventForAction> {


  List<String> listOfCreatedEvents = []; // list of the events that the host has created
  bool _isLoading = false; // boolean to check if the events created by the user are still loading




  /// This function retrieves the list of events created by the current user
  /// 
  /// No input, but it uses the current user ID to retrieve the list of events
  /// 
  /// Returns a list of event IDs
  void _getListOfEvents() async {
    setState(() {
      _isLoading = true;
    });
    
    // Get current user ID and check that it is not null
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      showErrorMessage(context, content: 'There was an error loading your user. Please logout and login again.');
      return;
    }

    // Get the user document from Firestore and check that it exists
    final userDocument = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!userDocument.exists) {
      showErrorMessage(context, content: 'There was an error loading your events. Please try again.');
      return;
    }
    
    // Get the list of event IDs from the user document
    setState(() {
      listOfCreatedEvents = List<String>.from(userDocument.data()?['createdEvents'] ?? []);
      _isLoading = false;
    });
  }




  // initialize the list of events created by the user
  @override
  void initState() {
    super.initState();
    _getListOfEvents();
  }





  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
            backgroundColor: korazonColorLP,
            automaticallyImplyLeading: false,
            title: Text(widget.action == HostAction.scan? 'Scan Events' : 'Analytics',
            style: TextStyle(
                  color: secondaryColor,
                  fontWeight: primaryFontWeight,
                  fontSize: 32.0,
                ),
            ), // set the app bar title based on the action
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2.0),
              child: Container(
                color: korazonColor,
                height: 4.0,
              ),
            ),
          ),
      body: _isLoading // dynamically set the loading indicator or show the list of events
        ? const Center(child: CircularProgressIndicator()) 
        : listOfCreatedEvents.isEmpty  // check if the user has created any events
            ? Text("You don't have any events created") 
            : ListView.builder(
              itemCount: listOfCreatedEvents.length,
              itemBuilder: (context, index) {
                return SelectEventCard(eventID: listOfCreatedEvents[index], action: widget.action); // display the list of events
              },
            )
    );
  }

}