import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/utilities/models/userModel.dart';


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
  final UserModel? userData;
  final String eventID;

  

  @override
  Widget build(context) {

    final String? userID = userData?.userID; // get the user ID from the user data

    return InkWell(
      onTap: () {
        if (userID != null) {
          // _allowGuestIn(context, userID, eventID); // allow the guest in
        } else {
          showErrorMessage(context, content: 'User ID is not available.');
        }
      },
      child: Card(
        color: const Color.fromARGB(255, 217, 255, 215),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color.fromARGB(255, 40, 142, 35),
            width: 1,
          ),
        ),
        child: SizedBox(
          height: 50,
          child: Center(
            child: Text(
              'Accept',
              style: whiteBody.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 40, 142, 35),
              )
            ),
          ),
        ),
      ),
    );
  }
}