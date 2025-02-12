import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';



class FinishUserSetup extends StatelessWidget {

  const FinishUserSetup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColorBM,
      body: Center(
        child: Text(
          'FinishUserSetup',
          style: whiteTitle,
        ),
      ),
    );
  }
}
 