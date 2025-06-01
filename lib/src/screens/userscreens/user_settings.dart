import 'package:flutter/material.dart';
import 'package:korazon/src/screens/singUpLogin/landing_page.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColorBM,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            )),
        backgroundColor: backgroundColorBM,
        title: Text(
          'User Settings',
          style: whiteTitle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(
                        const Color.fromARGB(255, 181, 22, 11)),
                    minimumSize: WidgetStatePropertyAll<Size>(
                        const Size(double.infinity, 45)),
                  ),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    // This has to be a push replacement because their is no use in having a previous stack
                    // after logging out because you need to log in again to use any of the pages anyway
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          // Navigate to the landing page instead of IsSignedLogic because it is the only option now
                          builder: (context) => const LandingPage()),
                    );
                  },
                  child: Text(
                    "Log Out",
                    style: whiteSubtitle,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
