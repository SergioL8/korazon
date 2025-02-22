import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/gradient_border_button.dart';
import 'dart:typed_data';




class FinishUserSetup extends StatefulWidget {

  const FinishUserSetup({super.key});

  @override
  State<FinishUserSetup> createState() => _FinishUserSetupState();
}

class _FinishUserSetupState extends State<FinishUserSetup> {

  Widget addSmallPicWidget() {
    return InkWell(
      onTap: () async {
        Uint8List? memoryImage = await selectImage(context);
        setState(() {
          _imageController = memoryImage;
        });
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



  final _instaGramController = TextEditingController();
  final _bioController = TextEditingController();
  final FocusNode _instaGramFocusNode = FocusNode();
  final FocusNode _bioFocusNode = FocusNode();
  Uint8List? _imageController;

  bool infoAdded = false;





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
                  child: addSmallPicWidget(),
                ),
                // Expanded(
                //   child: 
                  // Padding(
                    // padding: const EdgeInsets.only(left: 0, right: 0),
                    // child: addSmallPicWidget(),
                    // GridView.count(
                    //   crossAxisCount: 2,  // 2 columns
                    //   mainAxisSpacing: 20,
                    //   crossAxisSpacing: 20,
                    //   childAspectRatio: 3 / 4, // 3:4 proportion
                    //   children: [
                    //     addSmallPicWidget(),
                    //     addSmallPicWidget(),
                    //     addSmallPicWidget(),
                    //     addSmallPicWidget(),
                    //   ],
                    // ),
                  // ),
                // ),
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
                  onTap: () {
                    print('Tapped');
                  },
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
 