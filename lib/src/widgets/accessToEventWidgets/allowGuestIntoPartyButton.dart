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
Future<void> _allowGuestIn(BuildContext context, String userID, String eventID) async {
  final firestore = FirebaseFirestore.instance;
  final eventRef = firestore.collection('events').doc(eventID);
  final userRef = firestore.collection('users').doc(userID);

  try {
    await firestore.runTransaction((transaction) async {
      // Read both documents
      final eventSnap = await transaction.get(eventRef);
      final userSnap = await transaction.get(userRef);

      if (!eventSnap.exists) {
        showErrorMessage(context, content: 'There was an error allowing the guest in. Please restart the app and try again');
      }
      if (!userSnap.exists) {
        showErrorMessage(context, content: 'There was an error allowing the guest in. Please restart the app and try again');
      }

      // Update event's attendees array
      final List<dynamic> attendees = eventSnap.get('attendees') as List<dynamic>? ?? [];
      if (!attendees.contains(userID)) {
        transaction.update(eventRef, {
          'attendees': FieldValue.arrayUnion([userID]),
        });
      }

      // Update user's eventsAttended array
      final List<dynamic> eventsAttended = userSnap.get('eventsAttended') as List<dynamic>? ?? [];
      if (!eventsAttended.contains(eventID)) {
        transaction.update(userRef, {
          'eventsAttended': FieldValue.arrayUnion([eventID]),
        });
      }
    });
  } catch (e) {
    debugPrint('Error allowing guest in: $e');
    showErrorMessage(context, content: 'There was an error allowing the guest in. Please try again');
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
      onTap: () async {
        if (userID != null) {
          await _allowGuestIn(context, userID, eventID); // allow the guest in
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