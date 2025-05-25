import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:korazon/src/screens/basePage.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/identityCodeModel.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/widgets/customPinInput.dart';
import 'package:korazon/src/widgets/gradient_border_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HostConfirmIdentityPage extends StatefulWidget {
  const HostConfirmIdentityPage({super.key});

  @override
  State<HostConfirmIdentityPage> createState() => _ConfirmIdentityPageState();
}

class _ConfirmIdentityPageState extends State<HostConfirmIdentityPage> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
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
    setState(() => _isLoading = true);

    try {
      // 1) Search for the code in the database
      final codeQuery = await FirebaseFirestore.instance
          .collection('codes')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      // 2) Check if no documents were found
      if (codeQuery.docs.isEmpty) {
        showErrorMessage(context, content: 'Invalid code');
        return;
      }

      // 3) Extract the first document
      final codeDocument = codeQuery.docs.first;

      // 4) Convert the document to our model
      final IdentityCodeModel? codeModel =
          IdentityCodeModel.fromDocumentSnapshot(codeDocument);

      // If model creation failed, notify user
      if (codeModel == null) {
        showErrorMessage(context, content: 'Invalid code, contact support');
        return;
      }

      // 5) Check if user is signed in
      final currentUser = FirebaseAuth.instance.currentUser?.uid;
      if (currentUser == null) {
        showErrorMessage(
          context,
          content: 'Error loading user. Please log out and log in again',
          errorAction: ErrorAction.logout,
        );
        return;
      }

      // 6) Mark the code as used and log the user id
      await FirebaseFirestore.instance
          .collection('codes')
          .doc(codeModel.documentID)
          .update({
        'used': true,
        'dateUsed': DateTime.now(),
        'fratUID': currentUser,
      });

      // 7) Mark the user as verified
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser)
          .update({
        'isVerifiedHost': true,
      });

      // TODO: Create and store a new random code for verification,
      //       and email Korazon.dev with the new code.

      // 8) Let's get out of this godamm page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BasePage()),
      );
    } on FirebaseException catch (firebaseError) {
      debugPrint('Firebase error: ${firebaseError.message}');
      showErrorMessage(context, content: 'An unexpected error occurred');

      // Handle specific Firebase errors
    } catch (error, stacktrace) {
      // Handle any generic errors, log them or send them to a monitoring service
      debugPrint('Error checking code: $error\nStacktrace: $stacktrace');
      showErrorMessage(context,
          content: 'An unexpected error occurred. Please try again.');
    } finally {
      // 9) Make sure to stop loading in every scenario
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: backgroundColorBM,
        resizeToAvoidBottomInset: true,
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                // IntrinsicHeight is what makes the widget not explode when the keyboard pops up
                // while allowing us to use a Spacer.

                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // 20 pixels from the beginning of the safe area (outside battery and time bar)
                      SizedBox(
                          height: MediaQuery.of(context).padding.top +
                              screenHeight * 0.15),
                      Text(
                        'Confirm Identity',
                        style: whiteTitle,
                      ),
                      SizedBox(height: screenHeight * 0.1),
                      Text(
                        'If you have already received a key, please enter it below. Otherwise, you can skip it by now.',
                        style: whiteBody,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      CustomPinInput(controller: _pinController),
                      PinCodeTextField(
                        // pin code field imported from pin_code_fields package
                        appContext: context,
                        length: 6, // length of the pin code
                        controller: _pinController,
                        keyboardType: TextInputType.text,
                        animationType: AnimationType
                            .fade, // animation of numbers when they are entered
                        textStyle: whiteBody,
                        textCapitalization: TextCapitalization
                            .characters, // set the keyboard to uppercase
                        enableActiveFill: true, // enable fill in the boxes
                        inputFormatters: [
                          // force the input to be uppercase when entered
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            return newValue.copyWith(
                                text: newValue.text.toUpperCase());
                          }),
                        ],
                        pinTheme: PinTheme(
                          // theme of the individual boxes
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(
                              10), // make the boxes rounded
                          borderWidth: 0, // no border
                          inactiveFillColor: Colors.white.withOpacity(0.15),
                          activeFillColor: Colors.white.withOpacity(0.15),
                          selectedFillColor: Colors.white.withOpacity(0.15),
                          activeColor: _error ? Colors.red : Colors.transparent,
                          inactiveColor:
                              _error ? Colors.red : Colors.transparent,
                          selectedColor:
                              _error ? Colors.red : Colors.transparent,
                        ),
                      ),
                      //! Needs change
                      Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => const BasePage())),
                        child: Text(
                          'Skip identity verification',
                          style: whiteBody.copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white, // Underline color
                            decorationThickness:
                                1, // Thickness of the underline
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Warning: If you do not confirm your identity, you will not be able to access certain features of the app. (Learn more)',
                        style: GoogleFonts.josefinSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color.fromARGB(255, 134, 134, 134)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      GradientBorderButton(
                          loading: _isLoading,
                          onTap: () => checkCode(_pinController.text),
                          text:
                              'Verify Code'), // Use () => to pass the function reference
                      SizedBox(
                        height: screenHeight * 0.1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
