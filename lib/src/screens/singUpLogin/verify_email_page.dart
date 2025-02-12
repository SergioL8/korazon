import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';



class VerifyEmailPage extends StatelessWidget {

  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColorBM,
      body: Center(
        child: Text(
          'VerifyEmailPage',
          style: whiteTitle,
        ),
      ),
    );
  }
}
 