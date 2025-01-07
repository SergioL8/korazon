import 'package:flutter/material.dart';
import 'package:korazon/src/widgets/accessToEventWidgets/allowGuestIntoPartyButton.dart';
import 'package:korazon/src/widgets/accessToEventWidgets/denyGuestIntoPartyButton.dart';


class UserDoesntHaveAccess extends StatelessWidget {

  const UserDoesntHaveAccess({super.key, required this.userData, required this.eventID});
  final Map<String, dynamic> userData;
  final String eventID;

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 177, 23, 23), // set the background color to red
      body: Padding(
        padding: const EdgeInsets.all(20.0), // add padding to the body
        child: Column( // create a column to align the elements vertically
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.10), // set the height of the column to 10% of the screen height to avoid elements under the camera
            
            Stack( // this is the "image" of the cross at the top of the screen
              alignment: Alignment.center, // aling the cross and the circle
              children: [
                CircleAvatar( // a circle to contain the cross
                  radius: 40,
                  backgroundColor: Colors.white,
                ),
                Icon(Icons.close, // the cross itself
                  color: const Color.fromARGB(255, 177, 23, 23),
                  size: 50,
                ),
              ],
            ),

            const SizedBox(height: 30),

            Row( // this row contains the user details and the profile picture
              children: [
                Column( // this column contains the user details
                  crossAxisAlignment: CrossAxisAlignment.start, // Align elements to the left
                  children: [
                    Text(userData['name'] ?? 'No name', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(' - Age: ${userData['age'] ?? 'No age'}', style: const TextStyle(color: Colors.white)),
                    Text(' - Gender: ${userData['gender'] ?? 'No gender'}', style: const TextStyle(color: Colors.white)),
                    Text(' - Black listed:', style: const TextStyle(color: Colors.white)),
                  ],
                ),

                const Spacer(),

                Image.asset('assets/images/profilePicture.jpeg', scale: 10,), // add the profile picture
              ],
            ),

            const SizedBox(height: 20),

            Text('User DOES NOT have access to event', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            
            const SizedBox(height: 20),
            
            Text('Always remember to check the user\'s ID', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            
            const SizedBox(height: 50),
            
            Row( // this row contains the buttons to allow or deny the user access to the event
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space elements evenly
              children: [
                AllowGuestIn(userData: userData, eventID: eventID), // button to allow guest in
               
                const SizedBox(width: 10),
                
                DenyGuestIn(), // button to deny guest in
              ],
            )
          ]
        ),
      ),
    );
  }
  
}