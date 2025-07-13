import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/widgets/colorfulSpinner.dart';
import 'package:korazon/src/widgets/selectEventCard.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:korazon/src/screens/hostscreens/accessToEvent/scanner.dart';



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
  String? selectedEventID; // variable to store the event ID selected by the user
  String? selectedEventTitle;
  DateTime? selectedEventDateAndTime;



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
      showErrorMessage(context, content: 'There was an error loading your user. Please logout and login again.', errorAction: ErrorAction.logout);
      return;
    }

    // Get the user document from Firestore and check that it exists
    final userDocument = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    UserModel? user = UserModel.fromDocumentSnapshot(userDocument);

    if (user == null) {
      showErrorMessage(context, content: 'There was an error loading your user. Please logout and login again.', errorAction: ErrorAction.logout);
      return;
    }
    
    // Get the list of event IDs from the user document
    setState(() {
      listOfCreatedEvents = user.createdEvents;
      _isLoading = false;
    });
  }


  void onSelectedEvent(String? eventID, String? eventTitle, DateTime? eventDateAndTime) {
    setState(() {
      selectedEventID = eventID; // set the selected event ID
      selectedEventTitle = eventTitle; // set the selected event title
      selectedEventDateAndTime = eventDateAndTime; // set the selected event date and
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
      backgroundColor: backgroundColorBM,
      appBar: AppBar(
            backgroundColor: backgroundColorBM,
            automaticallyImplyLeading: false,
            title: Text(widget.action == HostAction.scan? 'Select an event to start scannig' : 'Analytics',
            style: whiteSubtitle,
            ),
            centerTitle: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2.0),
              child: Container(
                color: dividerColor,
                height: barThickness,
              ),
            ),
          ),
      body: _isLoading // dynamically set the loading indicator or show the list of events
        ? const Center(child: ColorfulSpinner()) 
        : listOfCreatedEvents.isEmpty  // check if the user has created any events
            ? Text(
              "You don't have any upcoming events!",
              style: whiteBody,
            ) 
            : Stack(
              children: [
                ListView.builder(
                  itemCount: listOfCreatedEvents.length,
                  itemBuilder: (context, index) {
                    return SelectEventCard(eventID: listOfCreatedEvents[index], action: widget.action, onSelectedEvent: onSelectedEvent, selectedEventID: selectedEventID,); // display the list of events
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: selectedEventID == null ? linearGradientOff : linearGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () { 
                          if (selectedEventID == null) {
                            return;
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) { return ScannerScreen(eventID: selectedEventID!, eventTitle: selectedEventTitle, eventDateAndTime: selectedEventDateAndTime,); },) // navigate to the scanner screen
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 56),
                          splashFactory: selectedEventID == null ? NoSplash.splashFactory : null,
                          overlayColor: selectedEventID == null ? Colors.transparent: null,
                          shadowColor: selectedEventID == null ? Colors.transparent: null,
                          surfaceTintColor: selectedEventID == null ? Colors.transparent: null,
                        ),
                        child: Text(
                          'Start Scanning',
                          style: whiteSubtitle.copyWith(
                            color: selectedEventID == null
                              ? Colors.grey[700]
                              : Colors.white,
                          ),
                        ),
                      ),
                    )
                  ),
                )
              ]
            )
    );
  }
}