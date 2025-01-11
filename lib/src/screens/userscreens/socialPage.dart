import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/screens/singUpLogin/signUpScreen1.dart';
import 'package:korazon/src/utilities/design_variables.dart';

class SocialPage extends StatelessWidget{
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
            backgroundColor: korazonColorLP,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Row(
                  children: [
                    const Text('Create an Event',
                    style: TextStyle(
                      color: secondaryColor,
                      fontWeight: primaryFontWeight,
                      fontSize: 32.0,
                    ),
                    ),
                  
                    InkWell(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Icon(
                          Icons.login_outlined,
                          color: secondaryColor,
                          size: 32,
                        ),
                    ),
                  ],
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2.0),
              child: Container(
                color: korazonColor,
                height: 4.0,
              ),
            ),
          ),
      body: Center(child: Text('Social Page')),
    );
  }
}