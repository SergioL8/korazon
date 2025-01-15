import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/cloudresources/signedin_logic.dart';
import 'dart:convert'; // For base64 decoding
// import 'dart:typed_data'; // For Uint8List


class UserSettings extends StatefulWidget{
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {

  String? qrCodeBase64;

  // DON'T HAVE TO EDIT THIS
  @override
  void initState() {
    super.initState();
    fetchQrCode(); // Fetch QR code when widget loads
  }


  // DON'T HAVE TO EDIT THIS
  Future<void> fetchQrCode() async {
    try {
      
      final user = FirebaseAuth.instance.currentUser; // get instance of the current user

      if (user == null) {  qrCodeBase64 = null; return;  }  // Ensure the user is logged in

      // Fetch data from firestore
      final DocumentReference<Map<String, dynamic>> documentSnapshot = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final data = (await documentSnapshot.get());

      if (!data.exists) {  qrCodeBase64 = null; return;  } // Ensure the user data exists
      if (!data.data()!.containsKey('qrCode')) {  qrCodeBase64 = null; return;  } // Ensure the user data contains a QR code


      setState(() {
        qrCodeBase64 = data['qrCode'];
      });
    } catch (e) {
      throw Exception('Failed to fetch QR code: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('User Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const isSignedLogic()));
            },
          ),
        ],
      ),
      body: Center(
        child: qrCodeBase64 == null
              ?  const CircularProgressIndicator()
              : Image.memory(
                  base64Decode(qrCodeBase64!.split(',')[1]), // Decode the base64 string
                  fit: BoxFit.contain,
                ),
      ),
    );
  }
}