import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';



class ResetPasswordPage extends StatelessWidget {

  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColorBM,
      body: Center(
        child: Text(
          'ResetPasswordPage',
          style: whiteTitle,
        ),
      ),
    );
  }
}
 