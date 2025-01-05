import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/screens/hostscreens/accessToEvent/scanner.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';


class SelectEventCard extends StatefulWidget {
  SelectEventCard({super.key, required this.eventID});

  final String eventID;

  @override
  State<SelectEventCard> createState() => _SelectEventCardState();
}

class _SelectEventCardState extends State<SelectEventCard> {
  

  String? imagePath;
  String? eventTitle;
  String? eventDateAndTime;
  Uint8List? dataSnapShot;
  Uint8List? imageData;

  bool _dataLoading = true;
  bool _imageLoading = true;



  @override
  void initState() {
    super.initState();
    _getEventDetails();
  }




  void _getEventDetails() async {
    
    // get the event document from Firestore and check that it exists
    final eventDocument = await FirebaseFirestore.instance.collection('events').doc(widget.eventID).get();
    if (!eventDocument.exists) {
      print('There was an error loading an event, try again later. In the future use an alert box');
      return;
    }

    // get the event data from the event document and check that it exists
    final documentData = eventDocument.data() ?? {};
    if (documentData.isEmpty) {
      print('There was an error loading an event, try again later. In the future use an alert box');
      return;
    }


    setState(() {
      // get the event name and date from the event data
      eventTitle = documentData['title'] ?? 'Untitled';
      eventDateAndTime = documentData['dateTime'] ?? 'Unknown date/time';
      imagePath = documentData['photoPath'] ?? 'no_path';
      
      _dataLoading = false;
    });
    
    // get the image data from firestore storage
    dataSnapShot = await getImage(imagePath) ?? Uint8List(0);

    setState(() {
      imageData = dataSnapShot;
      _imageLoading = false;
    });
    
  }





  @override
  Widget build(BuildContext context) {
    return Card(
      child: _dataLoading
        ? const Center(child: CircularProgressIndicator())
        : ListTile(
          leading: _imageLoading
            ? const CircularProgressIndicator()
            : Image.memory(imageData!),
          title: Text(eventTitle!),
          subtitle: Text(eventDateAndTime!),
          trailing: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) { return const ScannerScreen(); },)
              );
            },
            child: Text('Start Scanning')
          )
        ),
    );
  }
}