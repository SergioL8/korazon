import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/screens/eventDetails.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:transparent_image/transparent_image.dart';

class EventCard2 extends StatefulWidget {

  const EventCard2({super.key, required this.document});
  final DocumentSnapshot document;

  // this is the standard way of defining the key in a widget

  @override
  State<EventCard2> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard2> {
  bool isLikeAnimating = false;

  @override
  Widget build(BuildContext context) {
    //final User? user = Provider.of<UserProvider>(context).getUser;
    // we imported the user data

     return FutureBuilder<Uint8List?>(
      future: getImage(widget.document['photoPath']),
      // TODO: Add another future builder for the profile picture of the host
      builder: (context, snapshot) {
        
    return InkWell(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: korazonColor,
                    backgroundImage: AssetImage('assets/images/no_profile_picture.webp'),
                    //TODO: Make it NetworkImage(profileImageUrl),
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Text('Host Name',
                  //TODO: ADD the hosts name to the event document
                    //widget.document['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
      
            // Post Image
            Hero(
              tag: widget.document.id,
              // I think the tag can just be something random
              child: FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    // image: snapshot.data ?? 'https://cdn.pixabay.com/photo/2017/07/21/23/57/concert-2527495_640.jpg',
                    image: snapshot.data != null
                          ? MemoryImage(snapshot.data!)
                          : AssetImage('assets/images/pary.jpg'),
                    fit: BoxFit.cover, // make sure that the image is properly fittet
                    height: 400,
                    width: double.infinity,
                  ),
            ),
      
            // Title and Description Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.document['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
      
            // Date and Time Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'date',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'time',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => EventDetails(document: widget.document, imageData: snapshot.data,
),),
      )
    );
      }
    );
    
  }
}

