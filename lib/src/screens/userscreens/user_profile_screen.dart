import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/cloudresources/signedin_logic.dart';
import 'dart:convert';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/alertBox.dart'; // For base64 decoding
import 'package:korazon/src/utilities/models/userModel.dart';


class UserSettings extends StatefulWidget{
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {

  String? qrCodeBase64;
  bool _isLoading = false;
  UserModel? usermodel;


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


      usermodel = UserModel.fromDocumentSnapshot(userDocument);

      if (usermodel == null) { // Ensure the user data exists
        qrCodeBase64 = null; return;  
      }
      qrCodeBase64 = usermodel!.qrCode;

    } catch (e) {
      showErrorMessage(context, content: e.toString());
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
      backgroundColor: appBarColor,
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
          color: dividerColor,
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
    : usermodel == null ? Center (child: Text('Error Loading User. Logout and login.'),) 
    : SingleChildScrollView(
      child: Padding(
        // You can adjust horizontal padding to your liking
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title or username
            SizedBox(height: 16.0), // Add spacing between name and last name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  usermodel!.name,
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.0), // Add spacing between name and last name
                Text(
                  usermodel!.lastName,
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
              child: qrCodeBase64 == ''
                  ? const Text('Error fetching QR Code')
                  : Image.memory(
                      base64Decode(qrCodeBase64!.split(',')[0]),
                      fit: BoxFit.contain,
                    ),
            ),
            const Text(
              'Use this QR Code to access all your events',
              style: TextStyle(
                color: secondaryColor,
                fontSize: 16.0,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 16.0),

            // USER INFO

            Text(
              usermodel!.gender, 
              style: const TextStyle(
                    color: secondaryColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text( 
              usermodel!.age == -1 ? 'Undefined Age' : (usermodel!.age).toString(),
              style: const TextStyle(
                    color: secondaryColor,
                    fontSize: 24.0,
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