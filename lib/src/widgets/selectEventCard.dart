import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';
import 'package:korazon/src/widgets/loading_place_holders.dart';



class SelectEventCard extends StatefulWidget {
  const SelectEventCard({super.key, required this.eventID, required this.action, required this.onSelectedEvent, required this.selectedEventID});

  final String eventID;
  final HostAction action; // used to render the correct icon button and the correct onTap action
  final Function onSelectedEvent; // callback function to notify the parent widget when an event is selected
  final String? selectedEventID; // the event ID that is currently selected, used to highlight the card if it is selected

  @override
  State<SelectEventCard> createState() => _SelectEventCardState();
}



class _SelectEventCardState extends State<SelectEventCard> {
  
  // variable declaration
  String? eventTitle;
  DateTime? eventDateAndTime;
  int? expectedAttendance;
  Uint8List? dataSnapShot;

  // we use two laoding variables, one for the data and one for the image
  bool _dataLoading = true;
  bool _errorLoading = false;
  late bool _isSelected;



  /// This function retrieves the event details from Firestore from a given specific eventID
  void _getEventDetails() async {
    
    // get the event document from Firestore and check that it exists
    final eventDocument = await FirebaseFirestore.instance.collection('events').doc(widget.eventID).get();
    
    EventModel? event = EventModel.fromDocumentSnapshot(eventDocument);

    if (event == null) {
      setState(() {
        _dataLoading = false;
        _errorLoading = true;
      });
      return;
    }
    setState(() {
      // get the event name and date from the event data
      eventTitle = event.title;
      eventDateAndTime = event.startDateTime.toDate();    
      expectedAttendance = event.eventTicketHolders?.length ?? 0;  
      _dataLoading = false; // data has been loaded so set the loading variable to false
    });
  }


  // initilize the state getting the event details
  @override
  void initState() {
    super.initState();
    
    _getEventDetails();
  }


  @override
  Widget build(BuildContext context) {
    _isSelected = widget.selectedEventID != null && widget.eventID == widget.selectedEventID;
    return _errorLoading
      ? SizedBox(height: 0, width: 0,)
      : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: _dataLoading // if the data is still loading then the image is still loading so set the card to a loading state
          ? LoadingTextPlaceHolder(height: 150)
          : InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if(_isSelected) {
                widget.onSelectedEvent(null, null, null);
                setState(() {
                  _isSelected = false;
                });
              } else {
                widget.onSelectedEvent(widget.eventID, eventTitle, eventDateAndTime);
                setState(() {
                  _isSelected = true;
                });
              }
            },
            child: Container(
              height: 125,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: _isSelected ? korazonColor : Colors.transparent, // highlight the card if selected
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      eventTitle ?? 'No event title',
                      style: whiteSubtitle,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          // Format: Thu, FEB 14, 20:00
                          '${DateFormat('EEE').format(eventDateAndTime!)}'
                          ', ${DateFormat('MMM').format(eventDateAndTime!).toUpperCase()}'
                          ' ${DateFormat('d').format(eventDateAndTime!)}, '
                          '${DateFormat('h:mm a').format(eventDateAndTime!)}',
                          style: whiteBody,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.people_outline, color: Colors.white, size: 20,),
                        const SizedBox(width: 4,),
                        Text(
                          '$expectedAttendance Expected Attendance',
                          style: whiteBody,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
    );
  }
}