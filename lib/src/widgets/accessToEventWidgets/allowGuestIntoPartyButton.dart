import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/widgets/alertBox.dart';


/// This function adds the user to the list of atendees of the event
/// 
/// The input is the user ID and the event ID
/// 
/// No output but the result is that the user is added to the list of atendees of the event
void _allowGuestIn(BuildContext context, String userID, String eventID) async {
  try {
    await FirebaseFirestore.instance.collection('events').doc(eventID).update({
      'atendees': FieldValue.arrayUnion([userID]),
    });
  } catch (e) {
    showErrorMessage(context, content: 'There was an error allowing the guest in.');
  }
}



class AllowGuestIn extends StatelessWidget {
  const AllowGuestIn({super.key, required this.userData, required this.eventID});
  final Map<String, dynamic> userData;
  final String eventID;

  

  @override
  Widget build(context) {

    final String userID = userData['uid']; // get the user ID from the user data

    return InkWell(
      onTap:() {
        _allowGuestIn(context, userID, eventID); // allow the guest in
        Navigator.of(context).pop(); // close the modal bottom sheet to go the scanner screen
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            'Allow in',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 23, 177, 30),
            ),
          ),
        ),
      )
    );
  }
}