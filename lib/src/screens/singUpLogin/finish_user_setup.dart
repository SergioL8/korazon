import 'package:flutter/material.dart';
import 'package:korazon/src/screens/basePage.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/gradient_border_button.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class FinishUserSetup extends StatefulWidget {

  const FinishUserSetup({super.key});

  @override
  State<FinishUserSetup> createState() => _FinishUserSetupState();
}

class _FinishUserSetupState extends State<FinishUserSetup> {


  final _instaGramController = TextEditingController();
  final _bioController = TextEditingController();
  final FocusNode _instaGramFocusNode = FocusNode();
  final FocusNode _bioFocusNode = FocusNode();
  Uint8List? _imageController;
  UserModel? user;
  bool infoAdded = false;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  bool _isLoading = false;




  Widget _addPicture() {
    return InkWell(
      onTap: () async {
        Uint8List? memoryImage = await selectImage(context);
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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 306.66, // 70,
          width: 230, // 52.5,
          decoration: BoxDecoration(
            image: _imageController == null ?
              DecorationImage(
                image: AssetImage('assets/images/addImagePlaceHolder.jpeg'),
                fit: BoxFit.cover,
              ) : DecorationImage(
                image: MemoryImage(_imageController!),
                fit: BoxFit.cover,
              ),
          ),
        ),
      ),
    );
  }




  void skipPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BasePage()
      )
    );
  }

  

  void submitProfileCompletion() async {

    String? refPath;
    
    if (uid == null) {
      showErrorMessage(context, content: 'There was an error loading your user, please logout and login again', errorAction: ErrorAction.logout);
      return;
    }
    
    var userDocument = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    user = UserModel.fromDocumentSnapshot(userDocument);
    
    if (user == null) {
      showErrorMessage(context, content: 'There was an error loading your user, please logout and login again', errorAction: ErrorAction.logout);
      return;
    }

    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    if (_imageController != null) {
      // compress the image (compressImage is a helper function that can be found under the utils folder)
      _imageController = await compressImage(_imageController!, 50);

      // specify the path and name of the image
      Reference storageRef = FirebaseStorage.instance.ref(); // create storage reference (basically the root of the storage bucket on the cloud)
      Reference fileRef = storageRef.child('images/usersPictures/$uid/${uid}_profilePic1_${DateTime.now()}.png');

      // save the image to firebase storage
      UploadTask imageUploadTask = fileRef.putData(_imageController!); // here uploadtask is a variable that stores information about how the upload is going

      // This line will wait the execution of the function until the upload has completed (success or failure).
      TaskSnapshot imageTaskSnapshot = await imageUploadTask;

      // check for success or failure of the image upload
      if (imageTaskSnapshot.state != TaskState.success) {
        showErrorMessage(context, content: 'There was an error uploading the image. Please try again');
      } else {
        refPath = fileRef.fullPath;
      }
    }

    // Trim the text from the controllers
    String instagram = _instaGramController.text.trim();
    String bio = _bioController.text.trim();

    // Add to the updateData map any fields that have been filled
    Map<String, dynamic> updateData = {};
    if (refPath != null) {
      updateData['profilePicturesPath'] = FieldValue.arrayUnion([refPath]);
    }
    if (instagram.isNotEmpty) {
      updateData['instaAcc'] = instagram;
    }
    if (bio.isNotEmpty) {
      updateData['bio'] = bio;
    }
    
    // upload the data to the database if any data has been added
    if (updateData.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update(updateData);
      } catch (e) {
        showErrorMessage(context, content: 'There was an error saving your profile. Please try again');
      }
    }


    // clear controllers
    _bioController.clear();
    _instaGramController.clear();
    _imageController = null;

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BasePage()
      )
    );
  }








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColorBM,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 30, right: 30, bottom: 20),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Complete your profile',
                  style: whiteSubtitle,
                ),
                SizedBox(height: 15),
                SizedBox(
                  child: _addPicture(),
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return linearGradient.createShader(bounds);
                      },
                      child: FaIcon(
                          FontAwesomeIcons.instagram,
                          size: 40,
                          color: Colors.white,
                        ), 
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        autocorrect: false, // Disable auto-correction
                        controller: _instaGramController, // set the controller
                        focusNode: _instaGramFocusNode,
                        style: whiteBody,
                        cursorColor: Colors.white,
                        onChanged: (value) {
                          setState(() {
                            infoAdded = _instaGramController.text.isNotEmpty || _bioController.text.isNotEmpty || _imageController != null;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          isDense: true,
                          fillColor: Colors.white.withOpacity(0.15),
                          labelText: 'insta acc.',
                          labelStyle: whiteBody,
                          floatingLabelBehavior: FloatingLabelBehavior.always, // Always show label at the top left
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15), // rounded corners
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15), // Rounded corners
                            borderSide: BorderSide(color: Colors.white), // Color when not focused
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15), // Rounded corners
                            borderSide: BorderSide(color: Colors.white, width: 2), // Color when focused
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  maxLines: 2,
                  autocorrect: false, // Disable auto-correction
                  controller: _bioController, // set the controller
                  focusNode: _bioFocusNode,
                  style: whiteBody,
                  cursorColor: Colors.white,
                  onChanged: (value) {
                    setState(() {
                      infoAdded = _instaGramController.text.isNotEmpty || _bioController.text.isNotEmpty || _imageController != null;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    isDense: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    labelText: 'Your Bio',
                    labelStyle: whiteBody,
                    floatingLabelBehavior: FloatingLabelBehavior.always, // Always show label at the top left
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15), // rounded corners
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                      borderSide: BorderSide(color: Colors.white), // Color when not focused
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                      borderSide: BorderSide(color: Colors.white, width: 2), // Color when focused
                    ),
                  ),
                ),

                SizedBox(height: 20),

                GradientBorderButton(
                  onTap: infoAdded ? submitProfileCompletion : skipPage,
                  text: infoAdded ? 'Save' : 'Skip',
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
 