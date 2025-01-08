import 'package:flutter/material.dart';



class SignUpScreen2 extends StatefulWidget {
  const SignUpScreen2({super.key, required this.email, required this.password});

  final String email;
  final String password;

  @override
  _SignUpScreen2State createState() => _SignUpScreen2State();
}


class _SignUpScreen2State extends State<SignUpScreen2> {

  @override
  Widget build(context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50),
          Text('Email: ${widget.email} Password: ${widget.password}'),
        ],
      ),
    );
  }
}