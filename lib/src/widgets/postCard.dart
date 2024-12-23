import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';



class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.eventName, required this.eventAge, required this.eventImage});
  final String eventName;
  final String eventAge;
  final String eventImage;

  @override
  Widget build (context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.hardEdge, // this gives the borders a nice, curved look
      elevation: 2, // this gives a bit of elevation to the card with respect the background (shadow of the card) 
      child: InkWell(
        onTap: () { print('Card tapped'); },
        child: Stack(
          children: [
            FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              image: AssetImage('assets/images/pary.jpg'),
              fit: BoxFit.cover, // make sure that the image is properly fittet
              height: 200,
              width: double.infinity,
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
  }
}