import 'package:flutter/material.dart';



class DenyGuestIn extends StatelessWidget {
  const DenyGuestIn({super.key});

  @override
  Widget build(context) {
    return InkWell(
      onTap:() {
        Navigator.of(context).pop();
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            'Deny in',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 199, 3, 3),
            ),
          ),
        ),
      )
    );
  }
}