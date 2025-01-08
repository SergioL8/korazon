import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korazon/src/screens/basePage.dart';
import 'package:korazon/src/screens/signup_screen.dart';
import 'package:korazon/src/screens/singUpLogin/signUpScreen1.dart';
import 'package:korazon/src/utilities/design_variables.dart';


class isSignedLogic extends StatelessWidget {
  const isSignedLogic({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(), // This line records whenver the authentication state changes (users sings in or out)
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) { // From the snapshot, we can identify if the the user is signed in, in the process of signing in or signed out
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
            ),
          );
        }
        if (snapshot.hasData) {
          return const BasePage(); 
          // Base page is the widget where all the different pages of the app are displayed
        } else {
          return const SignUpScreen(); // This is the widget where the user can sign in
        }
      },
    );
  }
}

//! THIS PAGE SHOULD BE PART OF THE basePage.dart file