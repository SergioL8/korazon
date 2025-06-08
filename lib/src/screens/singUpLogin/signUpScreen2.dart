import 'package:flutter/material.dart';
import 'package:korazon/src/screens/singUpLogin/verify_email_page.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/gradient_border_button.dart';
import 'package:wheel_chooser/wheel_chooser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'dart:async';

class SignUpScreen2 extends StatefulWidget {
  const SignUpScreen2({super.key, required this.email, required this.password});

  final String email;
  final String password;

  @override
  SignUpScreen2State createState() => SignUpScreen2State();
}

class SignUpScreen2State extends State<SignUpScreen2> {
  // text field controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  // final TextEditingController _ageController = TextEditingController(text: '18');
  final TextEditingController _academicYearController =
      TextEditingController(text: 'Freshman');
  final TextEditingController _usernameController = TextEditingController();

  // focus nodes to detect when the text field is in focus
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();

  // variable declaration
  bool _siningUpLoading = false;
  Timer? _debounce;
  String? _usernameError;

  /// Function to sign up the user
  /// This function validates the fields and then signs up the user.
  ///
  void signUpUser() async {
    if (_siningUpLoading) return; // check for double tap from the user

    _siningUpLoading = true; // update the variable but don't call setState becayse I don't want the UI to update if there are empty fields

    // check for empty fields
    if (_nameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      showErrorMessage(context, title: 'Please complete all fields');
      _siningUpLoading = false;
      return;
    }
    if (_genderController.text.isEmpty) {
      showErrorMessage(context, title: 'Please select a gender');
      _siningUpLoading = false;
      return;
    }

    // Check if the username is valid
    if (_usernameController.text.length < 6) {
      showErrorMessage(context,title: 'Username must be at least 6 characters long');
      _siningUpLoading = false;
      return;
    } else if (_usernameController.text.length > 30) {
      showErrorMessage(context, title: 'Username must be at most 30 characters long');
      _siningUpLoading = false;
      return;
    }
    final regex = RegExp(r'^[a-z0-9_-]{6,30}$');
    if (!regex.hasMatch(_usernameController.text)) {
      showErrorMessage(context, title: 'Username can only contain a-z, 0-9 and _, - ');
      _siningUpLoading = false;
      return;
    }
    bool usernameexists = await usernameExists(_usernameController.text);
    if (usernameexists) {
      showErrorMessage(context, title: 'Username already exists');
      _siningUpLoading = false;
      return;
    }

    setState(() {}); // this will update the loading spinner as _signingUpLoading has been set to true above

    try {
      UserCredential credentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: widget.email, password: widget.password);
      if (credentials.user == null) {
        showErrorMessage(context,
            content: 'Error creating user. Please try again later');
        setState(() {
          _siningUpLoading = false;
        });
        return;
      }

      final String? qrCode = await createQRCode(credentials.user!.uid);

      if (qrCode == null) {
        showErrorMessage(context,
            content: 'Error creating qrCode. Please try again.');
        setState(() {
          _siningUpLoading = false;
        });
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credentials.user!.uid)
          .set({
        'email': widget.email,
        'username': _usernameController.text,
        'name': _nameController.text,
        'lastName': _lastNameController.text,
        // 'age': double.parse(_ageController.text),
        'academicYear': _academicYearController.text,
        'gender': _genderController.text,
        'isHost': false,
        'qrCode': qrCode,
      });

      // Why is this necessary push needed? Because even though the streambuild of "signedin_logic.dart" is listening to the authentication state, we are
      // not in the same page that the streambuilder has returned. So we need to push the new page to the navigator stack.
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => VerifyEmailPage(
                userEmail: widget.email,
                nextPage: EmailVerificationNextPage.finishUserSetup,
              )));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showErrorMessage(context,
            content: 'This email address is already in use. Please log in.');
      } else if (e.code == 'invalid-email') {
        showErrorMessage(context,
            content: 'This email address is invalid. Please try again.');
      } else {
        showErrorMessage(context,
            content: 'Error creating user. Please try again later');
      }
    } catch (e) {
      showErrorMessage(context,
          content: 'Error creating user. Please try again later');
    }

    setState(() {
      _siningUpLoading = false;
    });
  }


  // This function will check if the username already exists in the database
  Future<bool> usernameExists(String username) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }


  // Initialize the listeners for the focus nodes
  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() {
      setState(() {});
    });
    _lastNameFocusNode.addListener(() {
      setState(() {});
    });
  }


  // check correct form of the username and that it does not already exist in the database
  void _onUsernameChanged(String username) {

    // Cancel any ongoing timer
    _debounce?.cancel();

    final regex = RegExp(r'^[a-z0-9_-]{6,30}$');
    if (!regex.hasMatch(username)) {
      setState(() {
        _usernameError = 'Username can only contain a-z, 0-9 and _, - ';
      });
      return;
    }
    if (username.length < 6) {
      setState(() {
        _usernameError = 'Username must be at least 6 characters long';
      });
      return;
    } else if (username.length > 30) {
      setState(() {
        _usernameError = 'Username must be at most 30 characters long';
      });
      return;
    }
    
    setState(() {
      _usernameError = null; // Reset error if the username is valid before debouncing
    });
    

    _debounce = Timer(Duration(milliseconds: 300), () async {
      final exists = await usernameExists(username);
      setState(() {
        _usernameError = exists ? 'Username already exists' : null;
      });
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColorBM,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: backgroundColorBM,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Last Step', textAlign: TextAlign.center, style: whiteTitle),

            const SizedBox(
              height: 30,
              width: double.infinity,
            ),

            TextFormField(
              autocorrect: false, // Disable auto-correction
              controller: _usernameController, // set the controller
              focusNode: _usernameFocusNode,
              style: whiteBody,
              cursorColor: Colors.white,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
              onChanged: (value) {
                final lower = value.toLowerCase();
                if (value != lower) {
                  // Update controller without triggering another change event
                  _usernameController.value = _usernameController.value.copyWith(
                    text: lower,
                    selection: TextSelection.collapsed(offset: lower.length),
                  );
                }
                _onUsernameChanged(lower);
              }, // Call the function to check username
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                labelText: 'Username',
                errorText: _usernameError,
                errorStyle: whiteBody.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                labelStyle: whiteBody,
                floatingLabelBehavior: FloatingLabelBehavior
                    .always, // Always show label at the top left
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), // rounded corners
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                  borderSide:
                      BorderSide(color: Colors.white), // Color when not focused
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                  borderSide: BorderSide(
                      color: Colors.white, width: 2), // Color when focused
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

            const SizedBox(
              height: 25,
              width: double.infinity,
            ),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    autocorrect: false, // Disable auto-correction
                    controller: _nameController, // set the controller
                    focusNode: _nameFocusNode,
                    style: whiteBody,
                    textCapitalization: TextCapitalization.words,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      labelText: 'First Name',
                      errorStyle: whiteBody,
                      labelStyle: whiteBody,
                      floatingLabelBehavior: FloatingLabelBehavior
                          .always, // Always show label at the top left
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15), // rounded corners
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15), // Rounded corners
                        borderSide: BorderSide(
                            color: Colors.white), // Color when not focused
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15), // Rounded corners
                        borderSide: BorderSide(
                            color: Colors.white,
                            width: 2), // Color when focused
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    autocorrect: false, // Disable auto-correction
                    controller: _lastNameController, // set the controller
                    focusNode: _lastNameFocusNode,
                    style: whiteBody,
                    textCapitalization: TextCapitalization.words,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      labelText: 'Last Name',
                      errorStyle: whiteBody.copyWith(
                          fontWeight: FontWeight.w700, fontSize: 12),
                      labelStyle: whiteBody,
                      floatingLabelBehavior: FloatingLabelBehavior
                          .always, // Always show label at the top left
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15), // rounded corners
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15), // Rounded corners
                        borderSide: BorderSide(
                            color: Colors.white), // Color when not focused
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15), // Rounded corners
                        borderSide: BorderSide(
                            color: Colors.white,
                            width: 2), // Color when focused
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 25,
              width: double.infinity,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _genderController.text = 'Male';
                      });
                    },
                    child: Icon(
                      Icons.male_rounded,
                      color: _genderController.text == 'Male'
                          ? Colors.blue[900]
                          : const Color.fromARGB(255, 123, 123, 123),
                      size: 50,
                    ),
                  ),
                  Text(
                    'Male',
                    style: TextStyle(
                      color: _genderController.text == 'Male'
                          ? Colors.blue[900]
                          : const Color.fromARGB(255, 123, 123, 123),
                    ),
                  ),
                ]),
                Column(children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _genderController.text = 'Other';
                      });
                    },
                    child: Icon(
                      Icons.transgender,
                      color: _genderController.text == 'Other'
                          ? Colors.purple[600]
                          : const Color.fromARGB(255, 123, 123, 123),
                      size: 50,
                    ),
                  ),
                  Text(
                    'Other',
                    style: TextStyle(
                      color: _genderController.text == 'Other'
                          ? Colors.purple[600]
                          : const Color.fromARGB(255, 123, 123, 123),
                    ),
                  ),
                ]),
                Column(children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _genderController.text = 'Female';
                      });
                    },
                    child: Icon(
                      Icons.female_rounded,
                      color: _genderController.text == 'Female'
                          ? korazonColor
                          : const Color.fromARGB(255, 123, 123, 123),
                      size: 50,
                    ),
                  ),
                  Text(
                    'Female',
                    style: TextStyle(
                      color: _genderController.text == 'Female'
                          ? korazonColor
                          : const Color.fromARGB(255, 123, 123, 123),
                    ),
                  ),
                ]),
              ],
            ),
            const SizedBox(
              height: 30,
              width: double.infinity,
            ),
            // Column(
            //   children: [
            //     Text(
            //       'Age',
            //       style: TextStyle(
            //         color: secondaryColor,
            //         fontSize: 20,
            //         fontWeight: FontWeight.bold
            //       ),
            //     ),
            //     SizedBox( // necessary to make the wheel chooser take the full height of the column
            //       height: 45,
            //       child: WheelChooser.integer(
            //         onValueChanged: (s) => _ageController.text = s.toString(),
            //         initValue: 18,
            //         minValue: 1,
            //         maxValue: 99,
            //         horizontal: true,
            //         selectTextStyle: TextStyle(
            //           color: korazonColor,
            //           fontSize: 20,
            //           fontWeight: FontWeight.bold
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Adjust as needed
              crossAxisAlignment: CrossAxisAlignment.center, // Adjust as needed
              children: [
                Text(
                  'Academic Year: ',
                  style: whiteBody.copyWith(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
                Expanded(
                  child: SizedBox(
                    // necessary to make the wheel chooser take the full height of the column
                    height: 100,
                    child: WheelChooser.choices(
                      choices: [
                        WheelChoice(value: 'Freshman', title: 'Freshman'),
                        WheelChoice(value: 'Sophmore', title: 'Sophmore'),
                        WheelChoice(value: 'Junior', title: 'Junior'),
                        WheelChoice(value: 'Senior', title: 'Senior'),
                      ],
                      onChoiceChanged: (s) =>
                          _academicYearController.text = s.toString(),
                      horizontal: false,
                      selectTextStyle: TextStyle(
                          color: korazonColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 50,
              width: double.infinity,
            ),

            GradientBorderButton(
              onTap: signUpUser,
              text: 'Start Korazon',
              loading: _siningUpLoading,
            ),

            // InkWell( // make the container clickable
            //   onTap: signUpUser,
            //   child: Container(
            //     height: 75, // set the container to a height relative to the device
            //     width: double.infinity, // take the full width of the screen
            //     padding: EdgeInsets.all(10), // add padding to the container
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(15), // rounded corners
            //       color: korazonColor, // this color will have to be updated to the korazon color
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //       children: [
            //         const Text(
            //           'Start Korazon',
            //           style: TextStyle(
            //             fontWeight: primaryFontWeight,
            //             color: secondaryColor,
            //             fontSize: 20,
            //           ),
            //         ),
            //         _siningUpLoading ?
            //           const Colorfullspinner() :
            //           const Icon(
            //             Icons.arrow_forward_ios,
            //             color: secondaryColor,
            //           ),
            //       ],
            //     )
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
