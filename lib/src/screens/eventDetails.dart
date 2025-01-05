import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:korazon/src/screens/buyTicketPage.dart';



class EventDetails extends StatelessWidget {

  const EventDetails({super.key, required this.document, required this.imageData});
  final DocumentSnapshot document;
  final Uint8List? imageData;



  @override
  Widget build(BuildContext context) {

    final String eventName = document['title'];
    final String eventDescription = document['description'];
    final double eventAge = document['age'];

    final String eventID = document.id;

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05), // 10% horizontal padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: document.id,
                child: imageData != null
                  ? Image.memory(imageData!)
                  : Image.asset('assets/images/pary.jpg'),
              ),
              Text(eventName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10), 
              Text(eventDescription),
              SizedBox(height: 10), 
              Text('Event Age: $eventAge'),
              SizedBox(height: 10), 
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: TextButton(
                    onPressed: () { 
                      showModalBottomSheet(
                        useSafeArea: true,
                        isScrollControlled: true,
                        context: context,
                        builder: (ctx) => SafeArea(child: BuyTicketPage(eventID: eventID))

                      );
                     },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 241, 177, 201)), // light pink background
                      foregroundColor: WidgetStatePropertyAll(Colors.white), // white text
                    ),
                    child: Text('Buy Ticket'), 
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}