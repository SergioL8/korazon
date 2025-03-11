import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class ConfirmIdentityPage extends StatefulWidget {

  const ConfirmIdentityPage({super.key});

  @override
  State<ConfirmIdentityPage> createState() => _ConfirmIdentityPageState();
}

class _ConfirmIdentityPageState extends State<ConfirmIdentityPage> {

  final TextEditingController _pinController = TextEditingController();
  // bool _loading = false; // STILL NEED TO IMPLEMENT LOADING
  bool _error = false;


  // Dispose controllers
  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }


  // this function checks if the code is valid, 
  // updates the user's document to mark the account as verified
  // and updates the code document to store who and when the code was used
  void checkCode(String code) async {

    // search for the code in the database
    final querySnapShot = await FirebaseFirestore.instance.collection('users').where('codes', isEqualTo: code).limit(1).get();

    // if the code is not found, show an error message
    if (querySnapShot.docs.isEmpty) {
      setState(() {
        _error = true; // error should be used to display visual feedback to the user
      });
      showErrorMessage(context, content: 'Invalid code. Please try again');
      return;
    }

    // get the user document
    String? currentUser = FirebaseAuth.instance.currentUser?.uid;
    if (currentUser == null) {
      showErrorMessage(context, content: 'Error loading user. Please logout and login again', errorAction: ErrorAction.logout);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColorBM,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 20), // add the notch padding
            Text(
              'Confirm Identity',
              style: whiteTitle,
            ),
            const SizedBox(height: 20),
            Text(
              'If you have already received a key, please enter it below.',
              style: whiteBody,
              textAlign: TextAlign.center,
            ),
            PinCodeTextField( // pin code field imported from pin_code_fields package
              appContext: context,
              length: 6, // length of the pin code
              controller: _pinController,
              keyboardType: TextInputType.text,
              animationType: AnimationType.fade, // animation of numbers when they are entered
              textStyle: whiteBody,
              textCapitalization: TextCapitalization.characters, // set the keyboard to uppercase
              enableActiveFill: true, // enable fill in the boxes
              inputFormatters: [ // force the input to be uppercase when entered
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return newValue.copyWith(text: newValue.text.toUpperCase());
                }),
              ],
              pinTheme: PinTheme( // theme of the individual boxes
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10), // make the boxes rounded
                borderWidth: 0, // no border
                inactiveFillColor: Colors.white.withOpacity(0.15),
                activeFillColor: Colors.white.withOpacity(0.15),
                selectedFillColor: Colors.white.withOpacity(0.15),
                activeColor: _error ? Colors.red : Colors.transparent,
                inactiveColor: _error ? Colors.red : Colors.transparent,
                selectedColor: _error ? Colors.red : Colors.transparent,
              ),
            )
          ],
        ),
      )
    );
  }
}
 