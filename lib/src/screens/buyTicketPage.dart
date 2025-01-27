import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/utilities/models/userModel.dart';

void buyTicket(BuildContext context, EventModel event) async {
  // We might not need the entire document snapshot but we might aswell right now

  if (FirebaseAuth.instance.currentUser == null) {
    return;
  }

  final uid = FirebaseAuth.instance.currentUser!.uid;

  try {
    // Reference the user's document
    final userReference = FirebaseFirestore.instance.collection('users').doc(uid);
    final userDoc = await userReference.get();

    final UserModel? user = UserModel.fromDocumentSnapshot(userDoc);

    if (user == null) {
      showErrorMessage(context,
          content: 'Error loading your user. Logout and login.',
          errorAction: ErrorAction.logout);
    }

    // Check if user already has the event
    if (user!.tickets.contains(user.userID)) {
        showErrorMessage(context,
            title: 'Not that fast!',
            content: 'You already have a ticket for this event.');

      } else {
        
        final eventReference = FirebaseFirestore.instance.collection('events').doc(event.documentID);

        // We are updating the list of tickets sold of the event with the users id
        // This is what is going to be used for the social page to see who is attending the event
        eventReference.set({
          'ticketsSold': FieldValue.arrayUnion([userDoc.id])
        }, SetOptions(merge: true));

        // Use set() with merge to either create or update the 'tickets' field as an array
        // FieldValue.arrayUnion will append to the array if it exists or create one if it doesn't
        await userReference.set({
          'tickets': FieldValue.arrayUnion([event.documentID])
        }, SetOptions(merge: true));

        // Show a snackbar to confirm the ticket purchase
        showSnackBar(context, 'Ticket purchased successfully');
      
    }
  } catch (e) {
    showErrorMessage(context,
        content: 'There was an error purchasing the ticket. Please try again.');
  }
}

class BuyTicketPage extends StatelessWidget {
  const BuyTicketPage({super.key, required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tertiaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Adjust to fit children
            crossAxisAlignment:
                CrossAxisAlignment.center, // Horizontal centering
            children: [
              // Modal Header
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Confirm Ticket Purchase',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to buy this ticket?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // Buy Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: korazonColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  //We pass the event model to the function to update soldTickets and the user's tickets
                  buyTicket(
                      context, event); 
                },
                child: const Text(
                  'Confirm Purchase',
                  style: TextStyle(
                    fontSize: 24,
                    color: secondaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Cancel Button
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the modal
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
