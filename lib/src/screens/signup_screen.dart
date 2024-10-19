import 'package:flutter/material.dart';
//import 'package:openuc3m_application/responsive/responsive_layout.dart';
import 'package:korazon/src/screens/login_screen.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/utils.dart';
//import 'package:openuc3m_application/widgets/input_text_field.dart';
import 'package:korazon/src/cloudresources/authentication.dart';
//import 'package:openuc3m_application/responsive/mobilescreen_layout.dart';
//import 'package:openuc3m_application/responsive/webscreen_layout.dart';

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
      isHost: isHost,
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if(res != 'success'){
      showSnackBar(context, res);
    } else {
   //   Navigator.of(context).push(MaterialPageRoute(
 //       builder: (context) => const ResponsiveLayout(
  //        webScreenLayout: WebScreenLayout(), mobileScreenLayout: MobileScreenLayout())));
    }
  }

  void navigateToLogin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       
      body: Container(
          color: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 32 ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [              
              const SizedBox(height: 64,),
              //Image.asset('assets/appstore.png'),
              const SizedBox(height: 64,),
              Text(
                'Welcome to Korazon',
                textAlign: TextAlign.center,
                style: TextStyle(
                fontSize: 40, 
                fontWeight: primaryFontWeight,
                 ),),
              TextFormField(
                decoration: const InputDecoration(labelText: 'username'),
                        obscureText: false,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'email'),
                        obscureText: false,
              ),
               TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
              ),

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
