import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korazon/src/screens/basePage.dart';
import 'package:korazon/src/screens/singUpLogin/landing_page.dart';
import 'package:korazon/src/screens/singUpLogin/verify_email_page.dart';
import 'package:korazon/src/widgets/colorfulSpinner.dart';

class IsSignedLogic extends StatelessWidget {
  const IsSignedLogic({super.key});

  Future<Widget> checkAuthStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LandingPage();
    }

    // Reload to ensure latest emailVerified state
    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser!;

    if (refreshedUser.emailVerified) {
      return const BasePage();
    } else {
      return VerifyEmailPage(
        userEmail: refreshedUser.email,
        isHost: false,
        isLogin: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Not a StreamBuilder anymore because we only want to check auth status once then user will
    // navigate through the app to the correct page, we don't want the logic to retrigger when a
    // user verifies their email
    return FutureBuilder<Widget>(
      future: checkAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: ColorfulSpinner());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('An error occurred'));
        }
        return snapshot.data!;
      },
    );
  }
}
