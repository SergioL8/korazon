import 'package:flutter/material.dart';
import 'package:korazon/src/screens/basePage.dart';
import 'package:korazon/src/screens/login_screen.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/textfield.dart';
import 'package:korazon/src/cloudresources/authentication.dart';
import 'package:korazon/src/widgets/togglebutton.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  bool isHost = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

  void signUpUser() async {                      //function from resources/auth_method.dart
      setState(() {
        _isLoading = true;
      });

    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      isHost: isHost,
    );

    setState(() {
      _isLoading = false;
    });

    if(res == 'success'){
      showSnackBar(context, 'Glad you joined us');
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => BasePage()));
    } else {
      showSnackBar(context, 'Error: $res');
    }
  }

  void navigateToLogin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
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
              const SizedBox(height: 64,),
              const SizedBox(height: 64,),
              Text(
                'Welcome to Korazon',
                textAlign: TextAlign.center,
                style: TextStyle(
                fontSize: 40, 
                fontWeight: primaryFontWeight,
                 ),),
              
              const SizedBox(height: 20,),

              Togglebutton(selectionNumber: (bool isFirstSelected){
                print(isFirstSelected);
                isHost = isFirstSelected;
              },), // variable isFirstSelected is true if Host is selected

              const SizedBox(height: 20,),

              TextFieldInput(
                textEditingController: _usernameController, 
                hintText: 'username',
                textInputType: TextInputType.emailAddress),

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
              onTap: signUpUser,          
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
                  'Sign up',
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
                  Text('Already have an account? '),
                  GestureDetector(
                    onTap: navigateToLogin,
                    child: const Text(
                      'Login',
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
