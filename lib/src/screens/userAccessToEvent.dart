import 'package:flutter/material.dart';

class UserAccessToEvent extends StatelessWidget {
  const UserAccessToEvent({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Access To Event'),
        ),
        body: Center(
          child: Text('URLScanned: $code'),
        ),
      ),
    );
  }
}