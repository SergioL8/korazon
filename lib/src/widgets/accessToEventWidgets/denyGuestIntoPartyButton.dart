import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';



class DenyGuestIn extends StatelessWidget {
  const DenyGuestIn({super.key});

  @override
  Widget build(context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Card(
        color: const Color.fromARGB(255, 255, 215, 215,),
        // margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color.fromARGB(255, 202, 45, 45),
            width: 1,
          ),
        ),
        child: SizedBox(
          height: 50,
          child: Center(
            child: Text(
              'Deny',
              style: whiteBody.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 202, 45, 45),
              )
            ),
          ),
        ),
      ),
    );
  }
}