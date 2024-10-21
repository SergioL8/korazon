import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korazon/src/screens/signup_screen.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/cloudresources/authentication.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/data/providers/user_provider.dart';
import 'package:provider/provider.dart';

final _firebase = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() {
    return _Loginscreen();
  }
}

class _Loginscreen extends State<LoginScreen> {
  bool _isLoading = false;

  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';


  void loginUser() async {                  //function from resources/auth_method.dart
      setState(() {
        _isLoading = true;
      });

    String res = await AuthMethods().loginUser(
      email: _enteredEmail,
      password: _enteredPassword,
    );

    setState(() {
      _isLoading = false;
    });

    if(res == 'Que fakin grande'){  //Make sure to change the string in auth_methods.login as well
      showSnackBar(context, res);
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();

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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,

                ),
                width: 200,
                //child: Image.asset('assets/images/image.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty || !value.contains('@')) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredEmail = value!;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,   
                        validator: (value) {
                          if (value == null || value.trim().isEmpty || value.trim().length < 6) {
                            return 'Password must be at least 6 characters long.';
                          }
                          return null;
                        },     
                        onSaved: (value) {
                          _enteredPassword = value!;
                        },                  
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Text('Login'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            navigateToSignUp();
                          });
                        },
                        child: Text(_isLogin ? 'Create account' : 'I already have an account'),
                      ),
                    ],
                  ),
                ),
              ),
              ),
          ]),
        )
      ),
    );
  }
}
