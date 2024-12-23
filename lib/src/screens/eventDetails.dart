import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';



class EventDetails extends StatelessWidget {

  const EventDetails({super.key, required this.document, required this.imageData});
  final DocumentSnapshot document;
  final Uint8List? imageData;



  @override
  Widget build(BuildContext context) {

    final String eventName = document['eventName'];
    final String eventDescription = document['description'];
    final String eventAge = document['eventAge'];

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
            ],
          ),
        ),
      ),
    );
  }
}