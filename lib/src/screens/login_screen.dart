import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korazon/src/screens/signup_screen.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/cloudresources/authentication.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/textfield.dart';
import 'package:korazon/src/screens/basePage.dart';

final _firebase = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _Loginscreen();
  }
}

class _Loginscreen extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void loginUser() async {                  
    //function from resources/auth_method.dart
      setState(() {
        _isLoading = true;
      });

    String res = await AuthMethods().loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if(res == 'success'){  
      //Make sure to change the string in auth_methods.login as well
      //TODO: change this method, checking with Strings is not a good practice.
      
      showSnackBar(context, 'Glad to have you back');
      
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const BasePage()));

    } else {
      showSnackBar(context, res);
    }
  }

  void navigateToSignUp() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32 ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [              
              const SizedBox(height: 128,),
              Text(
                'Welcome back',
                textAlign: TextAlign.center,
                style: TextStyle(
                fontSize: 40, 
                fontWeight: primaryFontWeight,
                 ),),
              
              const SizedBox(height: 20,),

              TextFieldInput(
                textEditingController: _emailController, 
                hintText: 'email',
                textInputType: TextInputType.emailAddress),
              
              const SizedBox(height: 20,),

              TextFieldInput(
                textEditingController: _passwordController, 
                hintText: 'password ',
                textInputType: TextInputType.text,
                isPass: true),
              
              const SizedBox(height: 20,),


              InkWell(
              onTap: loginUser,          
              child: Container(
                width: double.infinity,
                color:  secondaryColor,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),  
                child: _isLoading ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(tertiaryColor),
                  ),
                ) : const Text(
                  'Log In',
                  style: TextStyle(
                    fontWeight: primaryFontWeight,
                    color: tertiaryColor,
                  ),
                  ),
                ),
              ),
              const SizedBox(height: 30,),
              Row(
                children: [
                  Text('No account? '),
                  GestureDetector(
                    onTap: navigateToSignUp,
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: primaryFontWeight,
                      ),),
                  ),
                ],
              ),
            ],
          ),
        )
      );
  }
}
