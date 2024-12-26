import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void buyTicket(BuildContext context, String eventID) async {
  if (FirebaseAuth.instance.currentUser == null) {
    return;
  }

  final uid = FirebaseAuth.instance.currentUser!.uid;

  try {

    // Reference the user's document
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid);
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buy Ticket'),
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text('Are you sure you want to buy this ticket?'),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  buyTicket(context, eventID);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 241, 177, 201)), // light pink background
                  foregroundColor: WidgetStatePropertyAll(Colors.white), // white text
                ),
                child: Text('Buy'),
              ),
            ]
          ),
        ),
      )
    );
  }
}