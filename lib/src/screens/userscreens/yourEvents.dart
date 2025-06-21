import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:korazon/src/widgets/eventCard.dart';
import 'package:korazon/src/widgets/qrcodeImage.dart';
import 'dart:typed_data';


class YourEvents extends StatefulWidget {
  const YourEvents({super.key});

  @override
  State<YourEvents> createState() => _YourEventsState();
}

class _YourEventsState extends State<YourEvents> {

  List<String> eventUids = []; // List to store event UIDs
  List<DocumentSnapshot> events = []; // List to store event details as DocumentSnapshots
  UserModel? usermodel;
  String? qrCodeBase64;
  Uint8List? profilePic;
  bool _qrCodeLoading = true;
  bool _isLoading = true;
  

  @override
  void initState() {
    super.initState();
    getEvents();
  }


  // Fetch the user's tickets and retrieve event details
  Future<void> getEvents() async {
    setState(() {
      _isLoading = true;
    });

    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      showErrorMessage(context, content: 'There was an error loading your user. Please logout and login back again.', errorAction: ErrorAction.logout);
      return;
    }
    try {
      // Get the current user's document
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      usermodel = UserModel.fromDocumentSnapshot(userDoc);

      if (usermodel == null) {
        showErrorMessage(context, content: 'There was an error loading your user. Please logout and login back again.', errorAction: ErrorAction.logout);
        return;
      }

      

      setState(() {
        setState(() { // the qrCode widgets needs the user info, so once we have the info we can se the loading state to false
          _qrCodeLoading = false;
        });
        eventUids = usermodel!.tickets.map((ticket) => ticket.eventID).toList();
        qrCodeBase64 = usermodel!.qrCode;
      });

      profilePic = await getImage(usermodel!.profilePicPath);
      // Fetch event details for each event UID
      // This goes to the list of all events to find if they match any of the ones in your tickets list.
      for (String uid in eventUids) {
        var eventDoc = await FirebaseFirestore.instance
            .collection('events') 
            .doc(uid)
            .get();
        
        EventModel? tempEvent = EventModel.fromDocumentSnapshot(eventDoc);

        if (tempEvent != null) {
          setState(() {
            // Add event details to the list
            // Here we are passing the event info as a snapshot which is the default setting
            events.add(eventDoc);
          }); 
        }
      } 
    } catch (e) {
      showErrorMessage(context, content: e.toString());
    }
    setState(() {
        _isLoading = false;
      });
  }



  // When child regenerates the QR code, update the parent’s state here
  void _updateQrCodeInParent(String newQrCode) {
    setState(() {
      qrCodeBase64 = newQrCode;
    });
  }




  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: backgroundColorBM,
      appBar: AppBar(
        title: Text(
          'Your Events',
          style: TextStyle(
                  color: secondaryColor,
                  fontWeight: primaryFontWeight,
                  fontSize: 32.0,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: dividerColor,
            height: barThickness,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: events.length + 2,
        itemBuilder: (context, index) {
          if (index == 0){
            if (_qrCodeLoading) {
              return SpinKitThreeBounce(color: Colors.white, size: 30);
            } else {
              return QrCodeImage(user: usermodel!, profilePic: profilePic, onQrCodeUpdated: _updateQrCodeInParent,);
            }
          } else if (index == 1) {
            if (events.isEmpty) {
              return Text(
                " No incoming events! \n "
                " Find events in the homepage!",
                style: whiteSubtitle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              );
            } else{
              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "Your Incoming Events",
                  style: whiteSubtitle,
                ),
              );
            }
          } else { 
            if (_isLoading) {
              return SpinKitThreeBounce(color: Colors.white, size: 30);
            } else {
              final eventIndex = index - 2;
              return EventCard(document: events[eventIndex], parentPage: ParentPage.yourEvents,);
            }
          }
        },
      )
    );
  }
}




  

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: tertiaryColor,
//       appBar: AppBar(
//         backgroundColor: appBarColor,
//         title: Text(
//           'Your Events',
//           style: TextStyle(
//                   color: secondaryColor,
//                   fontWeight: primaryFontWeight,
//                   fontSize: 32.0,
//                 ),
//           ),
//           bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(2.0),
//             child: Container(
//               color: dividerColor,
//               height: barThickness,
//             ),
//           ),
//       ),
//       body: _isLoading 
//       ? const Center(
//         child: ColorfulSpinnerl(),
//       )
//       :eventUids.isEmpty
//       ? const Center(
//         child: Text('You dont have any events yet, lets find some'), // Show a loader while fetching data
//       )
//       : Column(
//         children: [
//           // QR Code Container
//           Padding(
//             padding: const EdgeInsets.only(bottom: 10, top: 40, right: 40, left: 40),
//             child: usermodel!.qrCode == ''
//                   ? const Text('Error fetching QR Code')
//                   : Image.memory(
//                       base64Decode(qrCodeBase64!.split(',')[1]),
//                       fit: BoxFit.contain,
//                     ),
//             ),
//           const SizedBox(height: 20,),
//           ElevatedButton(
//             style: ButtonStyle(
//               backgroundColor: WidgetStatePropertyAll<Color>(korazonColor),
//               shape: WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               )),
//             ),
//             onPressed: () async {
//               if (_qrCodeLoading == true) { return; } // avoid multiple classs
//               _qrCodeLoading = true;
//               final temp = await createQRCode(usermodel!.userID);
//               await FirebaseFirestore.instance.collection('users').doc(usermodel!.userID).update({
//                 'qrCode': temp,
//               });
//               setState(() {
//                 qrCodeBase64 = temp;
//               });
//               _qrCodeLoading = false;
//             },
//             child: Text(
//               'Regenerate QR code',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 17,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
          
//           ListView.builder(
//             // Remember the index is what changes in the ListView.builder, 
//             // along the count of itemCount, then we just display each Card
//             // according to the info of that specific index in your list
          
//               itemCount: events.length,
//               itemBuilder: (context, index) {
//               final event = events[index];
          
//                 //! Fill with the list of your events
//               // The event card needs to take a document snapshot 
//               return EventCard(
//                 document: event,
//               );
//               },
//             ),
//         ],
//       ),
//     );
//   }
// }

