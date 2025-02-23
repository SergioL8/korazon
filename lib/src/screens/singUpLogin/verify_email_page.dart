import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/screens/singUpLogin/finish_user_setup.dart';



class VerifyEmailPage extends StatelessWidget {

  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColorBM,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'VerifyEmailPage',
              style: whiteTitle,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const FinishUserSetup()));
              },
              child: Text('Temp Skip Verification'),
            )
          ],
        ),
      ),
    );
  }
}
 