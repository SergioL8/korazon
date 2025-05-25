import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/screens/singUpLogin/verify_email_page.dart';
import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/widgets/gradient_border_button.dart';
import 'package:korazon/src/widgets/selectAddressBox.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';

class HostRequiredDetails extends StatefulWidget {
  const HostRequiredDetails(
      {super.key, required this.email, required this.password});
  final String email;
  final String password;

  @override
  State<HostRequiredDetails> createState() => _HostRequiredDetailsState();
}

class _HostRequiredDetailsState extends State<HostRequiredDetails> {
  // variable declaration
  final orgNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final FocusNode orgNameFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  Uint8List? _imageController;
  LocationModel? _selectedLocation;
  String? _usernameError;
  Timer? _debounce;
  bool infoAdded = false;
  bool isOrgNameFocused = false;
  bool addressError = false;
  bool nameError = false;
  bool _signingUpLoading = false;
  

  // call back function from the select address box
  void _onAddressSelected(LocationModel location) {
    setState(() {
      _selectedLocation = location; // update the selected location
      if (addressError) {
        // this variable is used to show an error in the address box. So we update it to false here if it was true and if the address is verified now
        if (_selectedLocation!.verifiedAddress == true) {
          addressError = false;
        }
      }
    });
  }

  // function that creates the host account
  void signUpHost() async {
    String? refPath;

    if (_signingUpLoading)
      return; // break the function if the user is already signing up

    _signingUpLoading = true; // set the loading variable to true

    if (_imageController == null) {
      // if no image has been seleced, show an error message
      _signingUpLoading = false;
      showErrorMessage(context, content: 'Please add a profile picture');
      return;
    }

    if (orgNameController.text.isEmpty) {
      // if no organization name has been entered, show an error message
      setState(() {
        nameError =
            true; // variable used to set the color of the text field to red
      });
      _signingUpLoading = false;
      showErrorMessage(context,
          content: 'Please enter your organization\'s name');
      return;
    }

    if (_selectedLocation == null) {
      // if no address has been selected, show an error message
      setState(() {
        addressError = true;
      });
      _signingUpLoading = false;
      showErrorMessage(context, content: 'Please select an address');
      return;
    }

    setState(
        () {}); // this will update the loading spinner as _signingUpLoading has been set to true above

    try {
      // create the accoutn with auth
      UserCredential credentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: widget.email, password: widget.password);

      // check if the user was created
      if (credentials.user == null) {
        showErrorMessage(context,
            content: 'Error creating user. Please try again later');
        setState(() {
          _signingUpLoading = false;
        });
        return;
      }

      // compress the image
      Uint8List comrpressedImage = await compressImage(_imageController!, 50);

      // specify the path and name of the image
      Reference storageRef = FirebaseStorage.instance
          .ref(); // create storage reference (basically the root of the storage bucket on the cloud)
      Reference fileRef = storageRef.child(
          'images/usersPictures/${credentials.user!.uid}/${credentials.user!.uid}_profilePic1_${DateTime.now()}.png');

      // save the image to firebase storage
      UploadTask imageUploadTask = fileRef.putData(
          comrpressedImage); // here uploadtask is a variable that stores information about how the upload is going

      // This line will wait the execution of the function until the upload has completed (success or failure).
      TaskSnapshot imageTaskSnapshot = await imageUploadTask;

      // check for success or failure of the image upload
      if (imageTaskSnapshot.state != TaskState.success) {
        showErrorMessage(context,
            content:
                'There was an error uploading the image. Please try again');
        setState(() {
          _signingUpLoading = false;
        });
        return;
      } else {
        refPath = fileRef.fullPath;
      }

      // create the host document in the database
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credentials.user!.uid)
          .set({
        'email': widget.email.trim(),
        'name': orgNameController.text.trim(),
        'isHost': true,
        'hostIdentityVerified': false,
        'location': _selectedLocation!.toMap(),
        'profilePicPath': refPath,
      });

      // push the confirm identity page
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => VerifyEmailPage(
                userEmail: widget.email.trim(),
                nextPage: EmailVerificationNextPage.hostConfirmIdentityPage,
              )));
    } on FirebaseAuthException catch (e) {
      // catch any errors that may occur during the creation of the user
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
      // catch any other errors that may occur
      showErrorMessage(context,
          content: 'Error creating user. Please try again later');
    }
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

  // This function will check if the username already exists in the database
  Future<bool> usernameExists(String username) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }



  // widget that adds the profile picture
  Widget _addPicture() {
    return InkWell(
      onTap: () async {
        Uint8List? memoryImage =
            await selectImage(context); // function from utils
        if (memoryImage != null) {
          setState(() {
            _imageController = memoryImage;
            infoAdded = true;
          });
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(250),
        child: Container(
          height: 175,
          width: 175,
          decoration: BoxDecoration(
            image: _imageController == null
                ? DecorationImage(
                    image: AssetImage(
                        'assets/images/add_image_mountains_placeholder.png'),
                    fit: BoxFit.cover,
                  )
                : DecorationImage(
                    image: MemoryImage(_imageController!),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ),
    );
  }

  // intiailize the focus for the org name
  @override
  void initState() {
    super.initState();
    orgNameFocusNode.addListener(() {
      setState(() {
        isOrgNameFocused = orgNameFocusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text('Required Details', style: whiteSubtitle),
        ),
        backgroundColor: backgroundColorBM,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            width: double.infinity,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      kToolbarHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    SizedBox(
                      child: _addPicture(),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      autocorrect: false, // Disable auto-correction
                      controller: orgNameController, // set the controller
                      focusNode: orgNameFocusNode,
                      style: whiteBody,
                      cursorColor: Colors.white,
                      onChanged: (s) {
                        if (nameError) {
                          setState(() {
                            nameError = false;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.15),
                        labelText: 'Organization\'s Name',
                        labelStyle: isOrgNameFocused
                            ? whiteBody.copyWith(
                                color: nameError ? Colors.red : Colors.white,
                                fontWeight: FontWeight.w800,
                              )
                            : whiteBody.copyWith(
                                color: nameError ? Colors.red : Colors.white,
                              ),
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
                              color: nameError
                                  ? Colors.red
                                  : Colors.white), // Color when not focused
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(15), // Rounded corners
                          borderSide: BorderSide(
                              color: nameError ? Colors.red : Colors.white,
                              width: 2), // Color when focused
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
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
                    SizedBox(height: 20),
                    SelectAddressBox(
                      onAddressSelected: _onAddressSelected,
                      error: addressError,
                    ), // select address box widget
                    const SizedBox(height: 35),
                    Spacer(),
                    GradientBorderButton(
                      onTap: signUpHost,
                      text: 'Create Account',
                      loading: _signingUpLoading,
                    ),
                    const SizedBox(height: 45),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
