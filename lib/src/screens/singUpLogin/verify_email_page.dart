import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/screens/singUpLogin/landing_page.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/screens/singUpLogin/finish_user_setup.dart';
import 'package:korazon/src/widgets/gradient_border_button.dart';

class VerifyEmailPage extends StatefulWidget {
  final String? userEmail;

  const VerifyEmailPage({super.key, required this.userEmail});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _emailVerified = false;
  //final bool _isLoading = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    sendVerificationEmail();
    _timer =
        Timer.periodic(Duration(seconds: 5), (timer) => checkEmailVerified());
  }

  Future<void> sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      _emailVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      // emailVerified is a boolean that returns true if the user's email is verified
    });
    // IF EMAIL IS NOT VERIFIED WE DO NOTHING, WE KEEP WAITING
    if (!_emailVerified) {
      return;

      // IF THE AUTHENTICATED USE IS NOT AN ASSOCIATION WE LOG HIM IN BECAUSE HE ALREADY HAS A FIRESTORE DOCUMENT
    } else {
      _timer.cancel();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const FinishUserSetup()));
    }
  }

  @override
  void dispose() {
    _timer.cancel();
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
        child: Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.11,
            right: screenWidth * 0.11,
            top: screenHeight * 0.075,
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
                  height: screenHeight * 0.25,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.05,
                ),
                child: Text(
                  'Verify your email',
                  style: whiteTitle,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'We have sent  you  a  verification  email,  please  check  the  inbox of $userEmail and  click  the verification link.',
                  style: TextStyle(
                    color: tertiaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              GradientBorderButton(
                text: 'I have verified my email',
                onTap: () async {
                  await FirebaseAuth.instance.currentUser?.reload();
                  setState(
                      () {}); // Trigger a rebuild to check the latest state
                },
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: GestureDetector(
                  child: Text(
                    'Resend verification email',
                    style: TextStyle(
                      color: tertiaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
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
              SizedBox(height: 16),
                            Spacer(),

              GestureDetector(
                // TODO: make this a pop if you come from the landing page

                onTap: navigateToLandingPage,
                child: Text(
                  'Return to landing page',
                  style: TextStyle(
                    color: tertiaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
