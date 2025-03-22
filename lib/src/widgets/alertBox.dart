import 'package:flutter/material.dart';
import 'package:korazon/src/screens/singUpLogin/hostSignUpExperience/confirm_identity_page.dart';
import 'package:korazon/src/screens/singUpLogin/landing_page.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';


void showErrorMessage(BuildContext context, {String title = 'Something went wrong...', String content = '', errorAction = ErrorAction.none, }) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Icon(Icons.heart_broken, color: korazonColor),
          const SizedBox(width: 8,),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontSize: 20,
                color: secondaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      content: content == '' ? null 
      : Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          color: secondaryColor,
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: [
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(korazonColor),
            shape: WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            )),
          ),
          onPressed: errorAction == ErrorAction.logout ? () async {
            await FirebaseAuth.instance.signOut();
            // if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const LandingPage(),
              ),
            );
          } : errorAction == ErrorAction.verify ? () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ConfirmIdentityPage(),
              ),
            );          }
          :() {
            Navigator.of(context).pop();
          },
          child: Text(
            errorAction == ErrorAction.logout ? 'Log Out' : 'Close',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}