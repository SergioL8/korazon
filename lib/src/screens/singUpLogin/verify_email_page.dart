import 'dart:async';
import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:korazon/src/screens/basePage.dart';
import 'package:korazon/src/screens/singUpLogin/hostSignUpExperience/confirm_identity_page.dart';
import 'package:korazon/src/screens/singUpLogin/landing_page.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/screens/singUpLogin/finish_user_setup.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/widgets/confirmationMessage.dart';
import 'package:korazon/src/widgets/customPinInput.dart';
import 'package:korazon/src/widgets/gradient_border_button.dart';

class VerifyEmailPage extends StatefulWidget {
  final String? userEmail;
  final bool isHost;
  final bool isLogin;

  const VerifyEmailPage({
    super.key,
    required this.userEmail,
    required this.isHost,
    required this.isLogin,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _pinController = TextEditingController();
  bool _emailVerified = false;
  bool _hasSentEmail = false;
  late Timer _timer;
  bool _error = false;

  @override
  void initState() {
    super.initState();

    // Only send the verification email once in initState in case it is triggered multiple times
    if (!_hasSentEmail) {
      sendVerificationEmail();
      _hasSentEmail = true;
    }
    _timer =
        Timer.periodic(Duration(seconds: 5), (timer) => checkEmailVerified());
  }

  Future<void> sendVerificationEmail() async {
    debugPrint("📧 Sending verification email to ${widget.userEmail}");

    // Generate a random 6-digit code
    final String code = (100000 + Random().nextInt(900000)).toString();
    debugPrint("🔐 Generated code: $code");

    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('VerificationEmail');

      final result = await callable.call({
        "recipientEmail": widget.userEmail,
        "verificationCode": code,
      });

      if (result.data['success'] == true) {
        showConfirmationMessage(
          context,
          message: 'We have sent you a verification email with your code',
        );
      }
    } catch (error) {
      showErrorMessage(context, title: 'An error occurred');
      debugPrint("❌ Error calling Firebase Function: $error");
    }
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    if (!mounted) return;
    setState(() {
      _emailVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      // emailVerified is a boolean that returns true if the user's email is verified
    });
    // If email is not verified, we do nothing, we keep waiting
    if (!_emailVerified) {
      return;
    } else {
      _timer.cancel();
      // Here is where the widget info is useful, we have 3 possible scenarios:

      if (widget.isLogin == true) {
        // 1. User has already created his account but left before verifying his/her email but
        // is already logged in or it just logged in in the Landing page

        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const BasePage()));
      } else if (widget.isHost == true) {
        // 2. New Host creating his account

        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const ConfirmIdentityPage()));
      } else {
        // 3. New User creating his account
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const FinishUserSetup()));
      }
    }
  }

  Future<void> verifyEmailManually(BuildContext context) async {
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('verifyUserEmailManually');

      final result = await callable();

      if (result.data['success'] == true) {
        showConfirmationMessage(
          context,
          message: 'Email verified successfully!',
        );
        // You can also navigate or update state here
      } else {
        showErrorMessage(context, title: 'An error occurred');
        debugPrint("❌ Error calling Firebase Function: $result");
      }
    } catch (e) {
      showErrorMessage(context, title: 'An error occurred');
      debugPrint("❌ Error calling Firebase Function: $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pinController.dispose();
    super.dispose();
  }

  void navigateToLandingPage() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LandingPage()));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    String? userEmail = widget.userEmail;

    return Scaffold(
      backgroundColor: backgroundColorBM,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.11,
              right: screenWidth * 0.11,
              top: screenHeight * 0.11,
              bottom: screenHeight * 0.07,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return mainGradient.createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Image.asset(
                    'assets/icons/love-letter.png',
                    height: screenHeight * 0.22,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.05,
                  ),
                  child: Text(
                    'Verify your email',
                    style: whiteSubtitle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Aligns text to the start
                      children: [
                        Text(
                          'We have sent you a verification email, please check the inbox of:',
                          style: whiteBody,
                        ),
                        Text(
                          userEmail!, //user email must exist, otherwise it would have thrown an error before.
                          style: whiteBody.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          // TextStyle(
                          //   color: tertiaryColor,
                          //   fontSize: 20,
                          //   fontWeight: FontWeight.w900, // Bold for emphasis
                          // ),
                          // textAlign: TextAlign.center, // Centers the email
                        ),
                        Text(
                          'and introduce the 6 digit code below.',
                          style: whiteBody,
                          // TextStyle(
                          //   color: tertiaryColor,
                          //   fontSize: 18,
                          //   fontWeight: FontWeight.w500,
                          // ),
                          // textAlign: TextAlign.justify,
                        ),
                      ],
                    )),
                SizedBox(height: screenHeight * 0.05),

                // This is our custom pin input

                CustomPinInput(
                  controller: _pinController,
                  useNumericKeyboard: true,
                ),

                GradientBorderButton(
                  text: 'Continue',
                  onTap: () => verifyEmailManually(context),
                ),

                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: GestureDetector(
                    child: Text(
                      'Resend verification email',
                      style: whiteBody.copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white, // Underline color
                        decorationThickness: 1, // Thickness of the underline
                      ),
                    ),
                    onTap: () async {
                      if (mounted) {
                        await sendVerificationEmail();
                        //showSnackBar(context, 'Email de verificación reenviado');
                      }
                    },
                  ),
                ),
                SizedBox(height: 6),
                // Spacer(),
                GestureDetector(
                  // TODO: make this a pop if you come from the landing page

                  onTap: navigateToLandingPage,
                  child: Text(
                    'Return to landing page',
                    style: whiteBody.copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white, // Underline color
                      decorationThickness: 1, // Thickness of the underline
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
