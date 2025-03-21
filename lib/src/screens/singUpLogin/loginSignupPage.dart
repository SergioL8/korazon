import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:korazon/src/screens/singUpLogin/hostSignUpExperience/hostRequiredDetails.dart';
import 'package:korazon/src/screens/singUpLogin/verify_email_page.dart';
import 'package:korazon/src/screens/singUpLogin/reset_password_page.dart';
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
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  /// Function that is executed when clicking the sign up button
  void _submitSignUpForm() async {
    if (!_emailFormKey.currentState!.validate() ||
        !_passwordFormKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        if (widget.parentPage == ParentPage.createHostAcc) {
          return HostRequiredDetails(
            email: _emailController.text,
            password: _passwordController.text,
          );
        } else {
          return SignUpScreen2(
            email: _emailController.text,
            password: _passwordController.text,
          );
        }
        
      }),
    );
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    if (!mounted) return;

    setState(() {
      _emailVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });
  }

  /// Function that is executed when clicking the login button
  void _login() async {
    setState(() {
      isLoading = true;
    });
    
    if (!_emailFormKey.currentState!.validate() ||
        !_passwordFormKey.currentState!.validate()) {
      isLoading = false;
      return;
    }

    setState(() {});

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await checkEmailVerified();

      if (_emailVerified) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BasePage()),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VerifyEmailPage(
              userEmail: _emailController.text,
              isHost: false,
              isLogin: true,
            ),
          ),
        );
      }
    } catch (e) {
      if (e is FirebaseAuthException && e.message != null) {
        if (e.code == 'invalid-credential') {
          showErrorMessage(
            context,
            title: 'Invalid Credentials',
            content: 'Invalid email or password. Please try again.',
          );
        } else {
          showErrorMessage(context, content: e.message!);
        }
      } else {
        showErrorMessage(context,
            content: 'An error occurred. Please try again later.');
      }
    }

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
    final gradientAlignment = const Alignment(-0.65, -0.715);
    double iconSize = MediaQuery.of(context).size.width * 0.11;

    // Convert gradientAlignment into pixel coordinates
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double gradientCenterX = screenWidth * (0.5 + gradientAlignment.x * 0.5);
    double gradientCenterY = screenHeight * (0.5 + gradientAlignment.y * 0.5);

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

          // Heart icon
          Positioned(
            left: gradientCenterX - (iconSize / 2),
            top: gradientCenterY - (iconSize / 2),
            child: Hero(
              tag: 'korazonIconTag',
              child: Icon(
                FaIcon(FontAwesomeIcons.solidHeart).icon,
                size: iconSize,
                color: Colors.white,
              ),
            ),
          ),

          // "Korazon" text next to icon
          Positioned(
            left: gradientCenterX + MediaQuery.of(context).size.width * 0.077,
            top: gradientCenterY - iconSize,
            child: Hero(
              tag: 'korazonLogoTag',
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  "Korazon",
                  style: GoogleFonts.josefinSans(
                    fontSize: MediaQuery.of(context).size.width * 0.155,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Fixed modal bottom sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Hero(
              tag: 'modalBottomSheet',
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: double.infinity,
                  height: screenHeight * 0.78,
                  decoration: const BoxDecoration(
                    color: backgroundColorBM,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * 0.11,
                      right: screenWidth * 0.11,
                      top: screenHeight * 0.025,
                      bottom: screenHeight * 0.055,
                    ),
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: screenHeight * 0.70),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    widget.parentPage == ParentPage.login
                                        ? "Login"
                                        : widget.parentPage == ParentPage.signup
                                          ? "Sign Up"
                                          : 'Crendentials',
                                    style: widget.parentPage == ParentPage.createHostAcc
                                      ? whiteSubtitle
                                      : whiteTitle,
                                  ),
                                  const Spacer(),
                                  const SizedBox(width: 48),
                                ],
                              ),
                              const SizedBox(height: 50),
                          
                              // Email form
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
                                  onChanged: (_) =>
                                      _emailFormKey.currentState!.validate(),
                                  style: whiteBody,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.15),
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                      color: Colors.white,
                                    ),
                                    hintText: widget.parentPage == ParentPage.createHostAcc
                                      ? 'Frat\'s Email'
                                      :  'example@colorad.edu',
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
                              const SizedBox(height: 25),
                          
                              // Password form
                              Form(
                                key: _passwordFormKey,
                                child: TextFormField(
                                  autocorrect: false,
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  cursorColor: Colors.white,
                                  obscureText: obscureText,
                                  validator: (val) {
                                    if (val != null && val.contains(' ')) {
                                      return 'Password cannot contain spaces.';
                                    }
                                    if (val == null || val.length < 6) {
                                      return 'Password must be at least 6 characters long.';
                                    }
                                    return null;
                                  },
                                  onChanged: (_) =>
                                      _passwordFormKey.currentState!.validate(),
                                  style: whiteBody,
                                  decoration: InputDecoration(
                                    suffixIcon: InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () =>
                                          setState(() => obscureText = !obscureText),
                                      child: Icon(
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
                          
                              if (login)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ResetPasswordPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: whiteBody.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                          
                              SizedBox(height: screenHeight * 0.05),
                              Spacer(),
                              GradientBorderButton(
                                onTap: login ? _login : _submitSignUpForm,
                                text: login ? 'Login' : 'Continue',
                                loading: isLoading,
                              ),
                              SizedBox(height: 25),
                              Text(
                                "Boulder, CO",
                                style: whiteBody,
                              ),
                              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ); // <-- Only ONE parenthesis before semicolon
  }
}
