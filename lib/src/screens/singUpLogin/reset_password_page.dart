import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/screens/singUpLogin/landing_page.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/widgets/confirmationMessage.dart';
import 'package:korazon/src/widgets/gradient_border_button.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

final _emailFormKey = GlobalKey<FormState>();
final FocusNode _emailFocusNode = FocusNode();
final TextEditingController _emailController = TextEditingController();

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  void navigateToLandingPage() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LandingPage()));
  }

  void resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isNotEmpty) {
      try {
        // Pass the actual context of the widget to the method
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      showConfirmationMessage(context, message: 'We have sent you a verification email');

        // Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (context) => const LoginSignupPage(parentPage: ParentPage.login,)));

      } catch (e) {
        debugPrint('Error: $e');
        showErrorMessage(context, title: 'An error occurred');
      }
    } else {
      showErrorMessage(context, title: 'Please enter your email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColorBM,
      // This helps automatically adjust body padding when the keyboard shows
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          // Force the column to take up at least the entire screen
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.11,
            ).copyWith(top: screenHeight * 0.11, bottom: screenHeight * 0.02),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Your icon
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return mainGradient.createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: screenHeight * 0.25,
                    ),
                  ),
                  Text(
                    'Reset your password',
                    style: whiteTitle,
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  Text(
                    'Enter your email and we\'ll send you a link to get back into your account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: tertiaryColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  Form(
                    key: _emailFormKey,
                    child: TextFormField(
                      autocorrect: false,
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      cursorColor: Colors.white,
                      validator: (value) {
                        if (value == null ||
                            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      onChanged: (_) => _emailFormKey.currentState!.validate(),
                      style: whiteBody,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.15),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.white,
                        ),
                        hintText: 'example@colorad.edu',
                        hintStyle: whiteBody,
                        errorStyle: whiteBody.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  GradientBorderButton(
                    onTap: () {
                      resetPassword();
                    },
                    text: 'Reset Password',
                  ),

                  // Use Spacer here so that the next widget is pushed to the bottom
                  Spacer(),

                  GestureDetector(
                    onTap: navigateToLandingPage,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Return to landing page',
                        style: TextStyle(
                          color: tertiaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
