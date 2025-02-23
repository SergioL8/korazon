import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:korazon/src/screens/singUpLogin/verify_email_page.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korazon/src/screens/singUpLogin/signUpScreen2.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/screens/basePage.dart';
import 'package:korazon/src/widgets/gradient_border_button.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key, required this.parentPage});

  final ParentPage parentPage;

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  // text field controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // focus nodes to detect when the text field is in focus
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // keys for the forms to validate the email and password
  final _passwordFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();

  // variable declaration
  bool obscureText = false;
  bool isLoading = false;
  bool _emailVerified = false;

  // initialize listeners to know when the text field is in focus
  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      // when focus updated, update the UI
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      // when focus updated, update the UI
      setState(() {});
    });
  }

  /// Function that is executed when clicking the sign up button
  /// This function validates the email and password and then navigates to the next screen
  ///
  /// No input (but the email and password controllers are being used)
  ///
  /// No output (the result is the navigation to the next screen)
  void _submitSignUpForm() async {
    // Even though emial and password are validated when changed, there is the change that the user clicks sinup without having changed any field. So we need to validate
    if (!_emailFormKey.currentState!.validate() ||
        !_passwordFormKey.currentState!.validate()) {
      return;
    }

    // Navigate to the next screen passing as variables the email and password
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return SignUpScreen2(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }),
    );
  }

  Future<void> checkEmailVerified() async {
    // We reload the current user
    await FirebaseAuth.instance.currentUser?.reload();

    if (!mounted) return; // Check if the widget is still active
    setState(() {
      _emailVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      // emailVerified is a boolean that returns true if the user's email is verified
    });
  }

  /// Function that is executed when clicking the login button
  /// This function validates the email and password and then logs the user in
  ///
  /// No input (but the email and password controllers are being used)
  ///
  /// No output (the result is the login of the user)

  void _login() async {
    isLoading = true; // set the loading state to true

    // validate that the email and password are correct
    if (!_emailFormKey.currentState!.validate() ||
        !_passwordFormKey.currentState!.validate()) {
      isLoading = false; // set the loading state to false
      return;
    }

    // set the loading state to true
    setState(() {});

    // try to log the user in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          // log the user in
          email: _emailController.text,
          password: _passwordController.text);

      // Checking if the user's email is verified
      await checkEmailVerified();

      // if the email is verified, navigate to the base page. Otherwise, navigate to the verify email page.
      // _ emailVerified comes from checkEmailVerified

      if (_emailVerified) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const BasePage()));
      } else {
        // We don't want to do push replacement for the verify email page 
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => VerifyEmailPage(userEmail: _emailController.text)));
      }
    } catch (e) {
      if (e is FirebaseAuthException && e.message != null) {
        // handle the error
        if (e.code == 'invalid-credential') {
          showErrorMessage(context,
              title: 'Invalid Credentials',
              content: 'Invalid email or password. Please try again.');
        } else {
          showErrorMessage(context, content: e.message!);
        }
      } else {
        showErrorMessage(context,
            content: 'An error occurred. Please try again later.');
      }
    }

    // set the loading state to false
    setState(() {
      isLoading = false;
    });
  }

  // dispose the controllers and nodes to avoid memory leaks
  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientAlignment = Alignment(-0.65, -0.715);
    double iconSize = MediaQuery.of(context).size.width * 0.11;

    // Convert gradientAlignment into pixel coordinates
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double gradientCenterX = screenWidth *
        (0.5 +
            gradientAlignment.x *
                0.5); // Convert alignment to pixel coordinates
    double gradientCenterY = screenHeight *
        (0.5 +
            gradientAlignment.y *
                0.5); // Convert alignment to pixel coordinates

    bool login = widget.parentPage == ParentPage.login;

    return Scaffold(
        backgroundColor: backgroundColorBM,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Background gradient
            Hero(
              tag: 'gradientTag',
              child: Container(
                decoration: BoxDecoration(
                  gradient: SweepGradient(
                    colors: mainGradient.colors,
                    stops: mainGradient.stops,
                    center: gradientAlignment,
                  ),
                ),
              ),
            ),

            // Absolute Positioning of Icon (Perfectly Matches Gradient Center)
            Positioned(
              left: gradientCenterX -
                  (iconSize / 2), // Offset by half the icon size (50/2)
              top: gradientCenterY -
                  (iconSize / 2), // Offset by half the icon size (50/2)
              child: Hero(
                tag: 'korazonIconTag',
                child: Icon(FaIcon(FontAwesomeIcons.solidHeart).icon,
                    size: iconSize, color: Colors.white),
              ),
            ),

            // Text Positioned Next to Icon (Without Affecting Its Position)
            Positioned(
              left: gradientCenterX +
                  MediaQuery.of(context).size.width *
                      0.077, // Space text right of the icon
              top: gradientCenterY - (iconSize), // Align with the icon
              child: Hero(
                tag: 'korazonLogoTag',
                child: Material(
                  type: MaterialType.transparency,
                  child: Text("Korazon",
                      style: GoogleFonts.josefinSans(
                          fontSize: MediaQuery.of(context).size.width * 0.155,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
            ),

            // Fixed Modal Bottom Sheet with Rounded Top Borders
            Align(
              alignment: Alignment.bottomCenter,
              child: Hero(
                tag: 'modalBottomSheet',
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                      width: double.infinity,
                      height:
                          screenHeight * 0.78, // Adjust modal height as needed
                      decoration: BoxDecoration(
                        color: backgroundColorBM, // Solid background color
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                              60), // Adjust the radius as needed
                          topRight: Radius.circular(60),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.11,
                          right: MediaQuery.of(context).size.width * 0.11,
                          top: MediaQuery.of(context).size.height * 0.025,
                          bottom: MediaQuery.of(context).size.height * 0.055,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    widget.parentPage == ParentPage.login
                                        ? "Login"
                                        : "Sign Up",
                                    style: whiteTitle,
                                  ),
                                  Spacer(),
                                  SizedBox(
                                      width:
                                          48), // compensate the size of the icon
                                ],
                              ),
                              SizedBox(height: 50),
                              Form(
                                key:
                                    _emailFormKey, // key to control the email validation
                                child: TextFormField(
                                  autocorrect: false, // Disable auto-correction
                                  controller:
                                      _emailController, // set the controller
                                  focusNode:
                                      _emailFocusNode, // set the focus node
                                  cursorColor: Colors.white,

                                  validator: (value) {
                                    // validate the email
                                    if (value == null ||
                                        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                            .hasMatch(value)) {
                                      // has the form (text)@(text).(text) and no spaces
                                      return 'Please enter a valid email address';
                                    }
                                    return null; // if everything ok
                                  },

                                  onChanged: (value) {
                                    // validate email for every change
                                    _emailFormKey.currentState!.validate();
                                  },

                                  style: whiteBody,

                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.15),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: Colors.white,
                                    ),
                                    hintText: 'example@colorad.edu',
                                    hintStyle: whiteBody,
                                    errorStyle: whiteBody.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12),
                                    // border styles
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          15), // rounded corners
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          15), // Rounded corners
                                      borderSide: BorderSide(
                                          color: Colors
                                              .white), // Color when not focused
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          15), // Rounded corners
                                      borderSide: BorderSide(
                                          color: Colors.white,
                                          width: 2), // Color when focused
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .white), // Same as enabledBorder
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                          color: Colors.white,
                                          width: 2), // Same as focusedBorder
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 25),
                              Form(
                                key:
                                    _passwordFormKey, // key to control the email validation
                                child: TextFormField(
                                  autocorrect: false, // Disable auto-correction
                                  controller:
                                      _passwordController, // set the controller
                                  focusNode:
                                      _passwordFocusNode, // set the focus node
                                  cursorColor: Colors.white,
                                  obscureText: obscureText, // hide the password

                                  validator: (val) {
                                    // validate the password
                                    if (val != null && val.contains(' ')) {
                                      // check password has no spaces
                                      return 'Password cannot contain spaces.';
                                    }
                                    if (val == null || val.length < 6) {
                                      // check password is at least 6 characters long
                                      return 'Password must be at least 6 characters long.';
                                    }
                                    return null;
                                  },

                                  onChanged: (value) {
                                    // validate password for every change
                                    _passwordFormKey.currentState!.validate();
                                  },

                                  style: whiteBody,

                                  decoration: InputDecoration(
                                    // icon to hide and show password
                                    suffixIcon: InkWell(
                                      highlightColor: Colors
                                          .transparent, // Remove highlight color
                                      splashColor: Colors
                                          .transparent, // Remove splash color
                                      onTap: () {
                                        setState(() {
                                          obscureText =
                                              !obscureText; // change the state of the password visibility
                                        });
                                      },
                                      child: Icon(
                                        // icon to show or hide the password
                                        obscureText
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white,
                                      ),
                                    ),

                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.15),
                                    hintText: 'Password',
                                    hintStyle: whiteBody,
                                    errorStyle: whiteBody.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12),
                                    // border styles
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          15), // rounded corners
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          15), // Rounded corners
                                      borderSide: BorderSide(
                                          color: Colors
                                              .white), // Color when not focused
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          15), // Rounded corners
                                      borderSide: BorderSide(
                                          color: Colors.white,
                                          width: 2), // Color when focused
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .white), // Same as enabledBorder
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                          color: Colors.white,
                                          width: 2), // Same as focusedBorder
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.15),
                              GradientBorderButton(
                                onTap: login
                                    ? _login
                                    : _submitSignUpForm, // call the function to submit the form
                                text: login
                                    ? 'Login'
                                    : 'Continue', // change the text depending on the login or sign up state
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.04),
                              Text(
                                "Boulder, CO",
                                style: whiteBody,
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).viewInsets.bottom,
                              )
                            ],
                          ),
                        ),
                      )),
                ),
              ),
            ),
          ],
        ));
  }
}
