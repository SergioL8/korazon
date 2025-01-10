import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/screens/login_screen.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/screens/singUpLogin/hostSignUp.dart';
import 'package:korazon/src/screens/singUpLogin/signUpScreen2.dart';



class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final _passwordFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  
  bool obscureText = false;
  bool login = false;
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
 
  }

  void _submitForm() async {

    // validate that the email and password are correct
    if (!_emailFormKey.currentState!.validate() || !_passwordFormKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return SignUpScreen2(email: _emailController.text, password: _passwordController.text,);
      }),
    );
  }


  void _login() async {

    // validate that the email and password are correct
    if (!_emailFormKey.currentState!.validate() || !_passwordFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text
      );
    } catch(e) {
      print('Error logging in: $e. In the future use an alert box');
    }

    setState(() {
      isLoading = false;
    });
    
  }

  

  void navigateToLogin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32 ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [              
            SizedBox(height: MediaQuery.of(context).size.height * 0.12), // set the height of the column to 10% of the screen height to avoid elements under the camera
        
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
        
            const SizedBox(height: 30,),
        
        
            Form(
              key: _emailFormKey,
              child: TextFormField( // LOCATION text field
                controller: _emailController, // set the controller
                focusNode: _emailFocusNode,
                validator: (value) {
                  if (value == null || !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onChanged: (value) {
                  _emailFormKey.currentState!.validate();
                },
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  errorStyle: TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  labelStyle: TextStyle(
                    color: _emailFocusNode.hasFocus ? korazonColor : secondaryColor,
                    fontSize: _emailFocusNode.hasFocus ? 18 : 15,
                    fontWeight: _emailFocusNode.hasFocus ? FontWeight.bold : FontWeight.normal,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always, // Always show label at the top left
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
              key: _passwordFormKey,
              child: TextFormField( 
                controller: _passwordController, // set the controller
                focusNode: _passwordFocusNode,
                validator: (val) {
                  if (val != null && val.contains(' ')) {
                    return 'Password cannot contain spaces.';
                  }
                  if (val == null || val.length < 6) {
                    return 'Password must be at least 6 characters long.';
                  }
                  return null;
                },
                onChanged: (value) {
                  _passwordFormKey.currentState!.validate();
                },
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: _passwordFocusNode.hasFocus ? korazonColor : secondaryColor,
                    ),
                  ),

                  errorStyle: TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: _passwordFocusNode.hasFocus ? korazonColor : secondaryColor,
                    fontSize: _passwordFocusNode.hasFocus ? 18 : 15,
                    fontWeight: _passwordFocusNode.hasFocus ? FontWeight.bold : FontWeight.normal,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always, // Always show label at the top left
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
                obscureText: obscureText,

              ),
            ),
            
            const SizedBox(height: 20,),
        
        
            InkWell(
              onTap: login ? _login : _submitForm, // call the function to submit the form
              child: Container(
                height: 60, // set the container to a height relative to the device
                width: double.infinity, // take the full width of the screen
                padding: EdgeInsets.all(10), // add padding to the container
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), // rounded corners
                  color: korazonColor, // this color will have to be updated to the korazon color
                ),
                child: Center(
                  child: Text(
                    login ? 'Login'
                    : 'Sign up',
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
                login ? const Text('Don\'t have an account? ') 
                : const Text('Already have an account? '),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      login = !login;
                    });
                  },
                  child: Text(
                    login ? 'Sign up'
                    : 'Login',
                    style: TextStyle(
                      fontWeight: primaryFontWeight,
                      color: korazonColor
                    ),),
                ),
              ],
            ),
            
            const SizedBox(height: 15,),
        
            Row(
              children: [
                Text('Are you a host? '),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {return const HostSignUp();})),
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
