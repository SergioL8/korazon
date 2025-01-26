import 'package:korazon/src/screens/hostscreens/accessToEvent/scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/screens/hostscreens/hostAnalytics.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:korazon/src/utilities/models/eventModel.dart';



class SelectEventCard extends StatefulWidget {
  const SelectEventCard({super.key, required this.eventID, required this.action});

  final String eventID;
  final HostAction action; // used to render the correct icon button and the correct onTap action

  @override
  State<SelectEventCard> createState() => _SelectEventCardState();
}



class _SelectEventCardState extends State<SelectEventCard> {
  
  // variable declaration
  String? imagePath;
  String? eventTitle;
  String? eventDateAndTime;
  Uint8List? dataSnapShot;
  Uint8List? imageData;

  // we use two laoding variables, one for the data and one for the image
  bool _dataLoading = true;
  bool _imageLoading = true;
  bool _errorLoading = false;



  // initilize the state getting the event details
  @override
  void initState() {
    super.initState();
    _getEventDetails();
  }



  /// This function retrieves the event details from Firestore from a given specific eventID
  void _getEventDetails() async {
    
    // get the event document from Firestore and check that it exists
    final eventDocument = await FirebaseFirestore.instance.collection('events').doc(widget.eventID).get();

    EventModel? event = EventModel.fromDocumentSnapshot(eventDocument);

    if (event == null) {
      setState(() {
        _dataLoading = false;
        _imageLoading = false;
        _errorLoading = true;
      });
      return;
    }


    setState(() {
      // get the event name and date from the event data
      eventTitle = event.title;
      eventDateAndTime = event.dateTime;
      imagePath = event.photoPath;
      
      _dataLoading = false; // data has been loaded so set the loading variable to false
    });
    
    // get the image data from firestore storage
    dataSnapShot = await getImage(imagePath) ?? Uint8List(0);

    setState(() {
      imageData = dataSnapShot; // update the image data
      _imageLoading = false;
    });
    
  }





  @override
  Widget build(BuildContext context) {
    return _errorLoading ? SizedBox() : Card(
      child: _dataLoading // if the data is still loading then the image is still loading so set the card to a loading state
        ? const Center(child: CircularProgressIndicator())
        : ListTile( // if the data has been loaded then show the card with the event details
          leading: _imageLoading // if the image is still loading then show a circular progress indicator only for the image
            ? const CircularProgressIndicator()
            : Image.memory(imageData!), // once the data has been loaded show the image
          
          title: Text(eventTitle!),

          subtitle: Text(eventDateAndTime!),

          trailing: widget.action == HostAction.scan  // if the host is in the scan page then show the scan icon button

            ? IconButton( 
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) { return ScannerScreen(eventID: widget.eventID,); },) // navigate to the scanner screen
                );
              },
              icon: Icon(Icons.qr_code_scanner_rounded),
            )

            : IconButton(  // else show the analytics icon button
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) { return HostanAlytics(); },) // navigate to the analytics screen
                );
              },
              icon: Icon(Icons.analytics),
            ),
        ),
    );
  }
}