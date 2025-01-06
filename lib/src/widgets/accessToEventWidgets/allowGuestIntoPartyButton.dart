import 'package:flutter/material.dart';



class AllowGuestIn extends StatelessWidget {
  const AllowGuestIn({super.key, required this.userData});
  final Map<String, dynamic> userData;

  @override
  Widget build(context) {
    return InkWell(
      onTap:() {},
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            'Allow in',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 23, 177, 30),
            ),
          ),
        ),
      )
    );
  }
}