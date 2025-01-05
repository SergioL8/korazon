import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserAccessToEvent extends StatelessWidget {
  const UserAccessToEvent({super.key, required this.code});
  final String code;


  Future<String> getUserInfo() async {
    final DocumentReference<Map<String, dynamic>> documentSnapshot = FirebaseFirestore.instance.collection('users').doc(code);
    final data = (await documentSnapshot.get());
    return code;
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Access To Event'),
        ),
        body: Center(
          child: Text(getUserInfo().toString()),
        ),
      ),
    );
  }
}