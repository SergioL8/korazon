import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korazon/src/screens/basePage.dart';
import 'package:korazon/src/screens/noConnectionPage.dart';
import 'package:korazon/src/screens/singUpLogin/landing_page.dart';
import 'package:korazon/src/screens/singUpLogin/verify_email_page.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/colorfulSpinner.dart';

class IsSignedLogic extends StatelessWidget {
  const IsSignedLogic({super.key});

  Future<Widget> checkAuthStatus() async {
    try {
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
    } catch (e) {
      debugPrint("❌ Error in checkAuthStatus: $e");
      return const NoConnectionPage();
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
        // We do not check for snapshot.hasError because we are already handling errors in the checkAuthStatus function
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: backgroundColorBM,
            body: Center(child: ColorfulSpinner()),
          );
        }
        return snapshot.data!;
      },
    );
  }
}
