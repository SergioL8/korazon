import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/cloudresources/signedin_logic.dart';
import 'dart:convert';

import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/utils.dart'; // For base64 decoding
// import 'dart:typed_data'; // For Uint8List


class UserSettings extends StatefulWidget{
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {

  String? qrCodeBase64;
  var userData = {}; 
  bool _isLoading = false;


  // DON'T HAVE TO EDIT THIS
  @override
  void initState() {
    super.initState();
    fetchQrCode(); // Fetch QR code when widget loads
  }


  // DON'T HAVE TO EDIT THIS
  Future<void> fetchQrCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      
      final user = FirebaseAuth.instance.currentUser; // get instance of the current user

      if (user == null) {  qrCodeBase64 = null; return;  }  // Ensure the user is logged in

      // Fetch data from firestore
      //final DocumentReference<Map<String, dynamic>> userDocument = FirebaseFirestore.instance.collection('users').doc(user.uid);
      //final data = (await userDocument.get());

      var userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDocument.exists) {  
        qrCodeBase64 = null; return;  
        } // Ensure the user data exists

      if (!userDocument.data()!.containsKey('qrCode')) {  
        qrCodeBase64 = null; return;  
         // Ensure the user data contains a QR code
      } else {
        userData = userDocument.data()!;
      }
      qrCodeBase64 = userDocument['qrCode'];

    } catch (e) {
      //TODO: Alert box in the future
      showSnackBar(context, e.toString());
      //throw Exception('Failed to fetch QR code: $e');
    }
    setState(() {
        _isLoading = false;
      });
  }


  @override
  Widget build(BuildContext context) {
  // For illustration purposes, let’s assume you already have values for:
  // final String userName = 'John Doe';
  // final String userSex = 'Male';
  // final int userAge = 25;

  return Scaffold(
    backgroundColor: tertiaryColor,
    appBar: AppBar(
      backgroundColor: korazonColorLP,
      title: const Text(
        'Profile',
        style: TextStyle(
          color: secondaryColor,
          fontWeight: primaryFontWeight,
          fontSize: 32.0,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2.0),
        child: Container(
          color: korazonColor,
          height: barThickness,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: IconButton(
            icon: const Icon(Icons.login_outlined),
            iconSize: 32.0,
            color: secondaryColor,
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const isSignedLogic()),
              );
            },
          ),
        ),
      ],
    ),
    body: _isLoading 
    ? Center(
       child: CircularProgressIndicator(),
    )
    : SingleChildScrollView(
      child: Padding(
        // You can adjust horizontal padding to your liking
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title or username
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userData['name'] ?? '',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.0), // Add spacing between name and last name
                Text(
                  userData['lastName'] ?? '',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // QR Code Container
            SizedBox(
              width: double.infinity, // Occupies entire width
              // Optional: you can set a max height if desired
              // height: MediaQuery.of(context).size.width * 0.8,
              child: qrCodeBase64 == null
                  ? const Text('Error fetching QR Code')
                  : Image.memory(
                      base64Decode(qrCodeBase64!.split(',')[1]),
                      fit: BoxFit.contain,
                    ),
            ),

            // Display other user info
            Text(
              userData['gender']?? 'Undefined Gender', 
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8.0),
            Text( userData['age'] != null?
              userData['age'].toString(): 'Undefined Age',
              // I am guessing 
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}