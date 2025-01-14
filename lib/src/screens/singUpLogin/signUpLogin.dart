import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/screens/login_screen.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/screens/singUpLogin/hostSignUp.dart';
import 'package:korazon/src/screens/singUpLogin/signUpScreen2.dart';
import 'package:korazon/src/utilities/utils.dart';



class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

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
  bool login = false;
  bool isLoading = false;



  // initialize listeners to know when the text field is in focus
  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() { // when focus updated, update the UI
      setState(() {});
    });
    _passwordFocusNode.addListener(() { // when focus updated, update the UI
      setState(() {});
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



  /// Function that is executed when clicking the sign up button
  /// This function validates the email and password and then navigates to the next screen
  /// 
  /// No input (but the email and password controllers are being used)
  /// 
  /// No output (the result is the navigation to the next screen)
  void _submitForm() async {

    // Even though emial and password are validated when changed, there is the change that the user clicks sinup without having changed any field. So we need to validate
    if (!_emailFormKey.currentState!.validate() || !_passwordFormKey.currentState!.validate()) {
      return;
    }

    // Navigate to the next screen passing as variables the email and password
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return SignUpScreen2(email: _emailController.text, password: _passwordController.text,);
      }),
    );
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
    if (!_emailFormKey.currentState!.validate() || !_passwordFormKey.currentState!.validate()) {
      isLoading = false; // set the loading state to false
      return;
    }

    // set the loading state to true
    setState(() {});

    // try to log the user in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword( // log the user in
        email: _emailController.text,
        password: _passwordController.text
      );
      
    } catch(e) {
      if (e is FirebaseAuthException && e.message != null) { // handle the error
        if (e.code == 'invalid-credential') {
          showSnackBar(context, 'Invalid email or password. Please try again.');
        } else {
          showSnackBar(context, e.message!);
        }
      } else {
        showSnackBar(context, 'An error occurred. Please try again later.');
      }
    }

    // set the loading state to false
    setState(() {
      isLoading = false;
    });
    
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32 ), // add padding to the screen
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // center the elements
          children: [              
            SizedBox(height: MediaQuery.of(context).size.height * 0.12), // set the height of the column to 10% of the screen height to avoid elements under the camera
        
            // This is the logo of the app. For the moment commented because we don't have a design for it
            // Icon(
            //   Icons.account_balance, // Greek temple-like icon
            //   size: 100,
            //   color: secondaryColor,
            // ),
            // Text(
            //   'Greek Life',
            //   style: TextStyle(
            //     color: secondaryColor,
            //   ),
            // ),
        
            // const SizedBox(height: 30,),
        

            Text(
              'Welcome to',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40, 
                fontWeight: FontWeight.w400,
                color: secondaryColor
              ),
            ),
            Text(
              'Korazon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40, 
                fontWeight: primaryFontWeight,
                color: secondaryColor
              ),
            ),
            

            const SizedBox(height: 10,),
        

            Text(
              'different beats, one rhythm',
              style: TextStyle(
                color: secondaryColor,
              ),
            ),
        

            const SizedBox(height: 45,),


            // This is another design option to clarify login or sign up state
            // Row(
            //   children: [
            //     Text(
            //       login ? ' Login'
            //       : ' Sing Up',
            //       style: TextStyle(
            //         fontSize: 20,
            //         fontWeight: primaryFontWeight,
            //         color: secondaryColor,
            //       ),
            //     ),
            //     Text(
            //       ' to continue',
            //       style: TextStyle(
            //         fontSize: 20,
            //         fontWeight: FontWeight.w400,
            //         color: secondaryColor,
            //       ),
            //     ),
            //   ],
            // ),

            // const SizedBox(height: 25,),
        

            Form(
              key: _emailFormKey, // key to control the email validation
              child: TextFormField(
                autocorrect: false, // Disable auto-correction
                controller: _emailController, // set the controller
                focusNode: _emailFocusNode, // set the focus node

                validator: (value) { // validate the email
                  if (value == null || !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) { // has the form (text)@(text).(text) and no spaces
                    return 'Please enter a valid email address';
                  }
                  return null; // if everything ok
                },

                onChanged: (value) { // validate email for every change
                  _emailFormKey.currentState!.validate();
                },

                decoration: InputDecoration(

                  labelText: 'Email Address',

                  labelStyle: TextStyle( // style for the label
                    color: _emailFocusNode.hasFocus ? korazonColor : secondaryColor,
                    fontSize: _emailFocusNode.hasFocus ? 18 : 15,
                    fontWeight: _emailFocusNode.hasFocus ? FontWeight.bold : FontWeight.normal,
                  ),

                  errorStyle: TextStyle( // style for the error message
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),

                  floatingLabelBehavior: FloatingLabelBehavior.always, // Always show label at the top left

                  // border styles
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), // rounded corners
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                    borderSide: BorderSide(color: secondaryColor), // Color when not focused
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                    borderSide: BorderSide(color: korazonColor, width: 2), // Color when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: secondaryColor), // Same as enabledBorder
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: korazonColor, width: 2), // Same as focusedBorder
                  ),
                ),
              ),
            ),
                

            const SizedBox(height: 20,),
        

            Form(
              key: _passwordFormKey, // key to control the password validation
              child: TextFormField( 
                autocorrect: false, // Disable auto-correction
                controller: _passwordController, // set the controller
                focusNode: _passwordFocusNode, // set the focus node
                obscureText: obscureText, // hide the password

                validator: (val) { // validate the password
                  if (val != null && val.contains(' ')) { // check password has no spaces
                    return 'Password cannot contain spaces.';
                  }
                  if (val == null || val.length < 6) { // check password is at least 6 characters long
                    return 'Password must be at least 6 characters long.';
                  }
                  return null;
                },

                onChanged: (value) { // validate password for every change
                  _passwordFormKey.currentState!.validate();
                },

                decoration: InputDecoration(

                  // icon to hide and show password
                  suffixIcon: InkWell (
                    highlightColor: Colors.transparent, // Remove highlight color
                    splashColor: Colors.transparent, // Remove splash color
                    onTap: () {
                      setState(() {
                        obscureText = !obscureText; // change the state of the password visibility
                      });
                    },
                    child: Icon( // icon to show or hide the password
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: _passwordFocusNode.hasFocus ? korazonColor : secondaryColor,
                    ),
                  ),

                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: _passwordFocusNode.hasFocus ? korazonColor : secondaryColor,
                    fontSize: _passwordFocusNode.hasFocus ? 18 : 15,
                    fontWeight: _passwordFocusNode.hasFocus ? FontWeight.bold : FontWeight.normal,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always, // Always show label at the top left

                  errorStyle: TextStyle( // style for the error message
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  
                  // border styles
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), // rounded corners
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                    borderSide: BorderSide(color: secondaryColor), // Color when not focused
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                    borderSide: BorderSide(color: korazonColor, width: 2), // Color when focused
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: secondaryColor), // Same as enabledBorder
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: korazonColor, width: 2), // Same as focusedBorder
                  ),
                ),
              ),
            ),
            

            const SizedBox(height: 20,),
        

            InkWell(
              onTap: login ? _login : _submitForm, // call the function to submit the form
              child: Container(
                height: 60,
                width: double.infinity, 
                padding: EdgeInsets.all(10), // add padding to the container
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), // rounded corners
                  color: korazonColor,
                ),
                child: Center(
                  child: Text(
                    login ? 'Login' : 'Sign up', // change the text depending on the login or sign up state
                  style: TextStyle(
                    fontWeight: primaryFontWeight,
                    color: secondaryColor,
                    fontSize: 20,
                  ),
                ),
                )
              ),
            ),
        

            const SizedBox(height: 30,),
        

            Row(
              children: [
                login ? const Text('Don\'t have an account? ') // change the text depending on the login or sign up state
                : const Text('Already have an account? '),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      login = !login; // switch the login or sign up state
                    });
                  },
                  child: Text(
                    login ? 'Sign up' // change the text depending on the login or sign up state
                    : 'Login',
                    style: TextStyle(
                      fontWeight: primaryFontWeight,
                      color: korazonColor
                    ),),
                ),
              ],
            ),
            

            const SizedBox(height: 15,),
        
        
            login ? Text('') // if in login state, then don't show anything
            : Row( // if in sign up state, show the host sign up option
              children: [
                Text('Are you a host? '),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {return const HostSignUp();})), // navigate to the host sign up screen
                  child: const Text(
                    'Host sign up',
                    style: TextStyle(
                      fontWeight: primaryFontWeight,
                      color: korazonColor
                    ),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
