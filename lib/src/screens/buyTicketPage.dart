import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/design_variables.dart';

void buyTicket(BuildContext context, String eventID) async {
  if (FirebaseAuth.instance.currentUser == null) {
    return;
  }

  final uid = FirebaseAuth.instance.currentUser!.uid;

  try {

    // Reference the user's document
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapShot = await userDoc.get();

    final tickets = snapShot.data()?['tickets'] ?? [];

    if (tickets.contains(eventID)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You already have a ticket for this event')),
      );
      
    } else {

      // Use set() with merge to either create or update the 'tickets' field as an array
      // FieldValue.arrayUnion will append to the array if it exists or create one if it doesn't
      await userDoc.set({
        'tickets': FieldValue.arrayUnion([eventID])
      }, SetOptions(merge: true));

      // Show a snackbar to confirm the ticket purchase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ticket purchased successfully')),
      );
    }

     
  } catch (e) {
    // Handle errors (e.g., permission issues, network errors)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not purchase ticket: $e')),
    );
  }


}

class BuyTicketPage extends StatelessWidget {
  const BuyTicketPage({super.key, required this.eventID}); 
  final String eventID;

  @override
   Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: tertiaryColor,
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Adjust to fit children
          crossAxisAlignment: CrossAxisAlignment.center, // Horizontal centering
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
                buyTicket(context, eventID); // Implement your purchase logic
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