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
  final _formKey = GlobalKey<FormState>();
  
  bool isHost = false;


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

  

  void navigateToLogin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: 
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32 ),
            child: Form(
              key: _formKey,
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
              
              
                  TextFormField( // LOCATION text field
                    controller: _emailController, // set the controller
                    focusNode: _emailFocusNode,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Email must not be null';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _formKey.currentState!.validate();
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
                     
                  const SizedBox(height: 20,),
              
                  TextFormField( 
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
                      _formKey.currentState!.validate();
                    },
                    decoration: InputDecoration(
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
                  ),
                    const SizedBox(height: 20,),
              
              
                  InkWell(
                    onTap: () {
              
                      
              
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return SignUpScreen2(email: _emailController.text, password: _passwordController.text,);
                        }),
                      );
                    },
              
                    child: Container(
                      height: 60, // set the container to a height relative to the device
                      width: double.infinity, // take the full width of the screen
                      padding: EdgeInsets.all(10), // add padding to the container
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15), // rounded corners
                        color: korazonColor, // this color will have to be updated to the korazon color
                      ),
                      child: Center(
                        child: const Text(
                        'Sign up',
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
                      Text('Already have an account? '),
                      GestureDetector(
                        onTap: navigateToLogin,
                        child: const Text(
                          'Login',
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
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) {return const HostSignUp();}));
                        },
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
          ),
        );
  }
}
