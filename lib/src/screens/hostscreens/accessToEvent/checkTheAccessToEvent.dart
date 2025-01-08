import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/widgets/accessToEventWidgets/allowGuestIntoPartyButton.dart';
import 'package:korazon/src/widgets/accessToEventWidgets/denyGuestIntoPartyButton.dart';
import 'package:korazon/src/widgets/accessToEventWidgets/tickCrossAccess.dart';



class CheckForAccessToEvent extends StatefulWidget {
  const CheckForAccessToEvent({super.key, required this.guestID, required this.eventID});
  final String guestID;
  final String eventID;

  @override
  State<CheckForAccessToEvent> createState() => _CheckForAccessToEventState();
}



class _CheckForAccessToEventState extends State<CheckForAccessToEvent> {
  
  Map<String, dynamic> userData = {};


  /// This function wll check if a user has in his list of events the event he is trying to access
  Future<bool> _checkAccessToEvent() async {

    // Get the user document and the user data
    final userDocument = await FirebaseFirestore.instance.collection('users').doc(widget.guestID).get();
    userData = userDocument.data() ?? {};
    
    // check that the user data is not empty
    if (userData.isEmpty) {
      print('There was an error loading the user, try again later. In the future use an alert box');
      return false;
    }

    // get the list of events that the user is attending 
    final List<String> eventsAttending = List<String>.from(userData['tickets'] ?? []);

    // check if the event ID is in the list of events the user is attending and return the result
    return eventsAttending.contains(widget.eventID);
  }


  @override
  Widget build(BuildContext context) {

    return Center(
      child: FutureBuilder<bool>(
        future: _checkAccessToEvent(), // check if the user has access to the event and store the result in snapshot
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) { // if checking is still in progress show a loading indicator
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasError) { // if there is an error show an error message
              return const Text('An error occurred, try again later'); // in the future change this to an alert box
            } else {

              return Scaffold(
                backgroundColor: snapshot.data! ? const Color.fromARGB(255, 23, 177, 30) // set the background color to green
                : const Color.fromARGB(255, 177, 23, 23), // set the background color to red
                
                body: Padding(

                  padding: const EdgeInsets.all(20.0), // add padding to the body

                  child: Column( // create a column to align the elements vertically
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.10), // set the height of the column to 10% of the screen height to avoid elements under the camera

                      TickCrossAccess(access: snapshot.data!), // show the tick or cross depending on the access

                      SizedBox(height: MediaQuery.of(context).size.height * 0.04), 

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

                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                      Text('User has access to event', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                      Text('Always remember to check the user\'s ID', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      
                      SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                      Row( // this row contains the buttons to allow or deny the user access to the event
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space elements evenly
                        children: [
                          AllowGuestIn(userData: userData, eventID: widget.eventID), // button to allow guest in

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
        },
      ),
    );
  }
}