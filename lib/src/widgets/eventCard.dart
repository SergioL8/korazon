import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:typed_data';
import 'package:korazon/src/screens/eventDetails.dart';
import 'package:korazon/src/utilities/utils.dart';








class EventCard extends StatelessWidget {

  const EventCard({super.key, required this.document});
  final DocumentSnapshot document;
  


  @override
  Widget build (context) {

    

    final String eventName = document['title'];
    final double eventAge = document['age'];
    final String eventImage = document['photoPath'];


    return FutureBuilder<Uint8List?>(
      future: getImage(eventImage),
      builder: (context, snapshot) {

        return Card(
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          clipBehavior: Clip.hardEdge, // this gives the borders a nice, curved look
          elevation: 2, // this gives a bit of elevation to the card with respect the background (shadow of the card) 
          child: InkWell(
            onTap: () { 
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EventDetails(
                    document: document,
                    imageData: snapshot.data,
                  )
                )
              );

             },
            child: Stack(
              children: [
                Hero(
                  tag: document.id,
                  child: FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    // image: snapshot.data ?? 'https://cdn.pixabay.com/photo/2017/07/21/23/57/concert-2527495_640.jpg',
                    image: snapshot.data != null
                          ? MemoryImage(snapshot.data!)
                          : AssetImage('assets/images/pary.jpg'),
                    fit: BoxFit.cover, // make sure that the image is properly fittet
                    height: 200,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container( // this container shows the preview information (how had and expensie the recipe is) 
                    color: Colors.black54,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 44),
                    child: Text('Event Name: $eventName, Age: $eventAge', style: const TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
                  ),
                ),
              ],
            )
          )    
        );
      },
    );
  }
}