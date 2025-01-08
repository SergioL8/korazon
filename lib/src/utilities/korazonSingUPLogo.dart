import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';


class KorazonSignUpLogo extends StatelessWidget {
  const KorazonSignUpLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Stack(
          alignment: Alignment.center, // Center all children within the Stack
          children: [
            Icon(
              Icons.favorite, // Heart icon
              color: const Color.fromARGB(255, 3, 0, 58),
              size: 200, // Size of the icon
            ),
            Text(
              'K',
              style: TextStyle(
                fontSize: 90,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pacifico',
              ),
            )
          ]
        ),
        // Bubbles
        Positioned(
          top: 0,
          left: 150,
          child: Icon(
            Icons.circle,
            color: const Color.fromARGB(255, 241, 177, 201),
            size: 50,
          ),
        ),
        Positioned(
          top: 50,
          right: 50,
          child: Icon(
            Icons.circle,
            color: const Color.fromARGB(255, 241, 177, 201),
            size: 30,
          ),
        ),
        Positioned(
          bottom: 30,
          left: 60,
          child: Icon(
            Icons.circle,
            color: const Color.fromARGB(255, 241, 177, 201),
            size: 30,
          ),
        ),
      ],
    );
  }
}