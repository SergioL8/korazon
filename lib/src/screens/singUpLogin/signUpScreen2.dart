import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:wheel_chooser/wheel_chooser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korazon/src/screens/basePage.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/design_variables.dart';



class SignUpScreen2 extends StatefulWidget {
  const SignUpScreen2({super.key, required this.email, required this.password});

  final String email;
  final String password;

  @override
  _SignUpScreen2State createState() => _SignUpScreen2State();
}



class _SignUpScreen2State extends State<SignUpScreen2> {

  // text field controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  // final TextEditingController _ageController = TextEditingController(text: '18');
  final TextEditingController _academicYearController = TextEditingController(text: 'Freshman');

  // focus nodes to detect when the text field is in focus
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();

  // variable declaration
  bool _siningUpLoading = false;



  /// Function to sign up the user
  /// This function validates the fields and then signs up the user.
  /// 
  void signUpUser() async {

    if (_siningUpLoading) return; // check for double tap from the user

    _siningUpLoading = true; // update the variable but don't call setState becayse I don't want the UI to update if there are empty fields

    // check for empty fields
    if (_nameController.text.isEmpty || _lastNameController.text.isEmpty) {
      showErrorMessage(context, title: 'Please fill all fields');
      _siningUpLoading = false;
      return;
    }
    if (_genderController.text.isEmpty) {
      showErrorMessage(context, title: 'Please select a gender');
      _siningUpLoading = false;
      return;
    }

    setState(() {}); // this will update the loading spinner as _signingUpLoading has been set to true above

    try {
       UserCredential credentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password
      );
      print(credentials.user);
      if (credentials.user == null) {
        print('here');
        showErrorMessage(context, content: 'Error creating user. Please try again later');
        return;
      }

      final String? qrCode = await createQRCode(credentials.user!.uid);

      if (qrCode == null) {
        showErrorMessage(context, content: 'Error creating qrCode. Please try again.');
        return;
      }


      await FirebaseFirestore.instance.collection('users').doc(credentials.user!.uid).set({
        'email': widget.email,
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
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const BasePage()));

    } on FirebaseAuthException catch(e) {
      if (e.code == 'email-already-in-use') {
        showErrorMessage(context, content: 'This email address is already in use. Please log in.');
      } else if (e.code == 'invalid-email') {
        showErrorMessage(context, content: 'This email address is invalid. Please try again.');
      } else {
        showErrorMessage(context, content: 'Error creating user. Please try again later');
      }
    } catch (e) {
      showErrorMessage(context, content: 'Error creating user. Please try again later');
    }

    setState(() {
      _siningUpLoading = false;
    });
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



  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32 ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Last Step',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40, 
                fontWeight: FontWeight.w400,
                color: secondaryColor
              ),
            ),

            const SizedBox(height: 30, width: double.infinity,),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    autocorrect: false, // Disable auto-correction
                    controller: _nameController, // set the controller
                    focusNode: _nameFocusNode,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      errorStyle: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      labelStyle: TextStyle(
                        color: _nameFocusNode.hasFocus ? korazonColor : secondaryColor,
                        fontSize: _nameFocusNode.hasFocus ? 18 : 15,
                        fontWeight: _nameFocusNode.hasFocus ? FontWeight.bold : FontWeight.normal,
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
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: TextFormField( 
                    autocorrect: false, // Disable auto-correction
                    controller: _lastNameController, // set the controller
                    focusNode: _lastNameFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      errorStyle: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      labelStyle: TextStyle(
                        color: _lastNameFocusNode.hasFocus ? korazonColor : secondaryColor,
                        fontSize: _lastNameFocusNode.hasFocus ? 18 : 15,
                        fontWeight: _lastNameFocusNode.hasFocus ? FontWeight.bold : FontWeight.normal,
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
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 50, width: double.infinity,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _genderController.text = 'Male';
                        });
                      },
                      child: Icon(
                        Icons.male_rounded,
                        color: _genderController.text == 'Male' ? Colors.blue[900] : const Color.fromARGB(255, 123, 123, 123),
                        size: 50,
                      ),
                    ),
                    Text(
                      'Male',
                      style: TextStyle(
                        color: _genderController.text == 'Male' ? Colors.blue[900] : const Color.fromARGB(255, 123, 123, 123),
                      ),
                    ),
                  ]
                ),

                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _genderController.text = 'Other';
                        });
                      },
                      child: Icon(
                        Icons.transgender,
                        color: _genderController.text == 'Other' ? Colors.purple[600] : const Color.fromARGB(255, 123, 123, 123),
                        size: 50,
                      ),
                    ),
                    Text(
                      'Other',
                      style: TextStyle(
                        color: _genderController.text == 'Other' ? Colors.purple[600] : const Color.fromARGB(255, 123, 123, 123),
                      ),
                    ),
                  ]
                ),

                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _genderController.text = 'Female';
                        });
                      },
                      child: Icon(
                        Icons.female_rounded,
                        color: _genderController.text == 'Female' ? korazonColor : const Color.fromARGB(255, 123, 123, 123),
                        size: 50,
                      ),
                    ),
                    Text(
                      'Female',
                      style: TextStyle(
                        color: _genderController.text == 'Female' ? korazonColor : const Color.fromARGB(255, 123, 123, 123),
                      ),
                    ),
                  ]
                ),
              ],
            ),
            const SizedBox(height: 30, width: double.infinity,),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Adjust as needed
              crossAxisAlignment: CrossAxisAlignment.center, // Adjust as needed
              children: [
                Text(
                  'Academic Year: ',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.start,
                ),
                Expanded(
                  child: SizedBox( // necessary to make the wheel chooser take the full height of the column
                    height: 100,
                    child: WheelChooser.choices(
                      choices: [
                        WheelChoice(value: 'Freshman', title: 'Freshman'),
                        WheelChoice(value: 'Sophmore', title: 'Sophmore'),
                        WheelChoice(value: 'Junior', title: 'Junior'),
                        WheelChoice(value: 'Senior', title: 'Senior'),
                      ],
                      onChoiceChanged: (s) => _academicYearController.text = s.toString(),
                      horizontal: false,
                      selectTextStyle: TextStyle(
                        color: korazonColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50, width: double.infinity,),
            InkWell( // make the container clickable
              onTap: signUpUser,
              child: Container(
                height: 75, // set the container to a height relative to the device
                width: double.infinity, // take the full width of the screen
                padding: EdgeInsets.all(10), // add padding to the container
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), // rounded corners
                  color: korazonColor, // this color will have to be updated to the korazon color
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      'Start Korazon',
                      style: TextStyle(
                        fontWeight: primaryFontWeight,
                        color: secondaryColor,
                        fontSize: 20,
                      ),
                    ),
                    _siningUpLoading ?
                      const CircularProgressIndicator() :
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: secondaryColor,
                      ),
                  ],
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}