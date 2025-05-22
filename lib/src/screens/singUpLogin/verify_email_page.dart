import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:korazon/src/screens/basePage.dart';
import 'package:korazon/src/screens/singUpLogin/hostSignUpExperience/confirm_identity_page.dart';
import 'package:korazon/src/screens/singUpLogin/landing_page.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/screens/singUpLogin/finish_user_setup.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/widgets/confirmationMessage.dart';
import 'package:korazon/src/widgets/customPinInput.dart';
import 'package:korazon/src/widgets/gradient_border_button.dart';

class VerifyEmailPage extends StatefulWidget {
  final String? userEmail;
  final EmailVerificationNextPage nextPage;

  const VerifyEmailPage({
    super.key,
    required this.userEmail,
    required this.nextPage,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _pinController = TextEditingController();
  late String _generatedCode;
  late DateTime _codeGeneratedAt;
  final Duration _codeExpiryDuration = Duration(minutes: 5);
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // Only send the verification email once in initState in case it is triggered multiple times
    // Schedule sending the email to happen after the widget is fully built once
    Future.microtask(() {
      sendVerificationEmail();
    });
  }

  // Checks whether the code is expired or not
  bool _isCodeExpired() {
    final currentTime = DateTime.now();
    return currentTime.difference(_codeGeneratedAt) > _codeExpiryDuration;
  }

  /// Sends a verification email to the user using Firebase Cloud Functions.
  /// Every time this function is called a new 6 digit verification code is generated and sent.
  /// Only the last code is valid, the previous ones are invalidated.
  Future<void> sendVerificationEmail() async {
    _loading = true;
    debugPrint("📧 Sending verification email to ${widget.userEmail}");

    // Generate a random 6-digit code
    _generatedCode = (100000 + Random().nextInt(900000)).toString();
    _codeGeneratedAt = DateTime.now();
    debugPrint("🔐 Generated code: $_generatedCode at $_codeGeneratedAt");

    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('VerificationEmail');

      final result = await callable.call({
        "recipientEmail": widget.userEmail,
        "verificationCode": _generatedCode,
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
    _loading = false;
  }

  Future<void> verifyAndRouteUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

    final response = await http.post(
      Uri.parse(
          'https://us-central1-korazon-dc77a.cloudfunctions.net/verifyUserEmailManuallyHttp'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: '{}',
    );

    final data = jsonDecode(response.body);

    if (!mounted) return;

    if (data['success'] == true) {
      showConfirmationMessage(context, message: 'Email verified successfully');

      switch (widget.nextPage) {
        case EmailVerificationNextPage.basePage:
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const BasePage()));
          break;

        case EmailVerificationNextPage.hostConfirmIdentityPage:
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const HostConfirmIdentityPage()));
          break;

        case EmailVerificationNextPage.finishUserSetup:
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const FinishUserSetup()));
          break;
      }

      // 🔄 Reload silently (not blocking UX)
      FirebaseAuth.instance.currentUser?.reload();
    } else {
      showErrorMessage(context, title: 'An error occurred');
      debugPrint("❌ Error verifying email: ${data['error']}");
    }
  }

  @override
  void dispose() {
    //_timer.cancel();
    _pinController.dispose();
    super.dispose();
  }

  void navigateToLandingPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LandingPage()));
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
                        ),
                        Text(
                          'and introduce the 6 digit code below.',
                          style: whiteBody,
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
                  onTap: () {
                    final enteredCode = _pinController.text.trim();

                    if (_isCodeExpired()) {
                      showErrorMessage(context,
                          title: 'Code expired. Please request a new one.');
                      debugPrint(
                          "❌ Code expired. Generated at $_codeGeneratedAt");
                      return;
                    }

                    if (enteredCode == _generatedCode) {
                      verifyAndRouteUser();
                    } else {
                      showErrorMessage(context,
                          title: 'Invalid verification code');
                      debugPrint(
                          "❌ Entered code $enteredCode does not match $_generatedCode");
                    }
                  },
                  loading: _loading,
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
                      // Code has to match and not be expired currently 5 minutes for expiration
                      onTap: () => sendVerificationEmail()),
                ),
                SizedBox(height: 6),
                // Spacer(),
                GestureDetector(
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
