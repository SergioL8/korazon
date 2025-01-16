import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/accessToEventWidgets/allowGuestIntoPartyButton.dart';
import 'package:korazon/src/widgets/accessToEventWidgets/denyGuestIntoPartyButton.dart';
import 'package:korazon/src/widgets/accessToEventWidgets/tickCrossAccess.dart';
import 'package:korazon/src/widgets/alertBox.dart';



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
      showErrorMessage(context, content: 'There was an error loading the user. Please try again');
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
              return const Text('An error occurred, try again later');
            } else {
              return Scaffold(
                backgroundColor: snapshot.data! ? allowGreen // set the background color to green
                : denyRed, // set the background color to red
                
                body: Padding(

                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20), // add padding to the body

                  child: Column( // create a column to align the elements vertically
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.10), // set the height of the column to 10% of the screen height to avoid elements under the camera

                      TickCrossAccess(access: snapshot.data!), // show the tick or cross depending on the access

                      SizedBox(height: MediaQuery.of(context).size.height * 0.04), 

                      Text(
                        snapshot.data! ? 'User has access to event' : 'User does not have access to event', // show the message depending on the access
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                      Text('Always remember to check the user\'s ID', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                      Row( // this row contains the user details and the profile picture
                        children: [
                          Column( // this column contains the user details
                            crossAxisAlignment: CrossAxisAlignment.start, // Align elements to the left
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    userData['name'] ?? '',
                                    style: TextStyle(
                                      color: tertiaryColor,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8.0), // Add spacing between name and last name
                                  Text(
                                    userData['lastName'] ?? '',
                                    style: TextStyle(
                                      color: tertiaryColor,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0), 
                              Text(' - Age: ${userData['age'] ?? 'Undefined Age'}', 
                              style: const TextStyle(
                                color: tertiaryColor,
                                fontSize: 16.0,
                              ),),
                              SizedBox(height: 8.0), 
                              Text(' - Gender: ${userData['gender'] ?? 'Undefined Gender'}', 
                              style: const TextStyle(
                                color: tertiaryColor,
                                fontSize: 16.0,
                              ),),
                              SizedBox(height: 8.0), 
                              Text(' - Black listed: No', 
                              style: const TextStyle(
                                color: tertiaryColor,
                                fontSize: 16.0,
                              ),),
                            ],
                          ),

                          const Spacer(), 
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: userData['profilePicUrl'] !=
                                      null
                                  ? NetworkImage(userData['profilePicUrl'])
                                      as ImageProvider
                                  : const AssetImage(
                                      'assets/images/no_profile_picture.webp',
                                    ),
                              radius: 48,
                            ),
                          ),
                        ],
                      ),

                      
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