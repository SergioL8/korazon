import 'package:flutter/material.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:korazon/src/utilities/design_variables.dart';


class AllowGuestIn extends StatefulWidget {
  const AllowGuestIn({super.key, required this.userData, required this.eventID});
  final UserModel? userData;
  final String eventID;

  @override
  State<AllowGuestIn> createState() => _AllowGuestInState();
}

class _AllowGuestInState extends State<AllowGuestIn> {

  bool _isLoading = false; // to show a loading indicator when the user is being allowed in


  /// This function adds the user to the list of atendees of the event
  /// 
  /// The input is the user ID and the event ID
  /// 
  /// No output but the result is that the user is added to the list of atendees of the event
  Future<void> _allowGuestIn(BuildContext context, String userID, String eventID) async {

    setState(() {
      _isLoading = true; // set loading to true to show a loading indicator
    });

    final firestore = FirebaseFirestore.instance;
    final eventRef = firestore.collection('events').doc(eventID);
    final userRef = firestore.collection('users').doc(userID);

    try {
      await firestore.runTransaction((transaction) async {
        // Read both documents
        final eventSnap = await transaction.get(eventRef);
        final userSnap = await transaction.get(userRef);

        // Get the user gender of the user being allowed in
        final user = UserModel.fromDocumentSnapshot(userSnap);
        String userGender = 'Unknown';
        if (user != null) {
          userGender = user.gender;
        }
        
        // Update event's attendees array
        final attendees = (eventSnap.data()?['attendees'] as List<dynamic>?) ?? [];
        if (!attendees.contains(userID)) {
          if (userGender == 'Male') {
            transaction.update(eventRef, {
              'attendees': FieldValue.arrayUnion([userID]),
              'totalMaleAttendees': FieldValue.increment(1),
            });
          } else if (userGender == 'Female'){
            transaction.update(eventRef, {
              'attendees': FieldValue.arrayUnion([userID]),
              'totalFemaleAttendees': FieldValue.increment(1),
            });
          } else {
            transaction.update(eventRef, {
              'attendees': FieldValue.arrayUnion([userID]),
            });
          }
        }

        // Update user's eventsAttended array
        final eventsAttended = (userSnap.data()?['eventsAttended'] as List<dynamic>?) ?? [];
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

    debugPrint('Guest allowed in successfully');

    setState(() {
      _isLoading = false; // set loading to true to show a loading indicator
    });

    if (context.mounted) {
      Navigator.of(context).pop(); // Close the modal bottom sheet after allowing the guest in
    }
  }


  @override
  Widget build(context) {

    final String? userID = widget.userData?.userID; // get the user ID from the user data

    return InkWell(
      onTap: () async {
        if (userID != null) {
          await _allowGuestIn(context, userID, widget.eventID); // allow the guest in
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
            child: _isLoading
                ? SpinKitThreeBounce(color: Color.fromARGB(255, 40, 142, 35), size: 30)
                : Text(
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