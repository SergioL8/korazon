import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/gradient_border_button.dart';




class HostRequiredDetails extends StatefulWidget {
  const HostRequiredDetails({super.key, required this.email, required this.password});
  final String email;
  final String password;

  @override
  State<HostRequiredDetails> createState() => _HostRequiredDetailsState();
}

class _HostRequiredDetailsState extends State<HostRequiredDetails> {

  final orgNameController = TextEditingController();
  final FocusNode orgNameFocusNode = FocusNode();
  Uint8List? _imageController;
  bool infoAdded = false;
  bool isOrgNameFocused = false;

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
        borderRadius: BorderRadius.circular(250),
        child: Container(
          height: 175, // 70,
          width: 175, // 52.5,
          decoration: BoxDecoration(
            image: _imageController == null ?
              DecorationImage(
                image: AssetImage('assets/images/no_profile_picture_place_holder.png'),
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
        title: Text(
          'Required Details',
          style: whiteSubtitle
        ),
      ),
      backgroundColor: backgroundColorBM,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32 ),
        child: SizedBox(
          width: double.infinity,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - kToolbarHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 35),
                  SizedBox(
                    child: _addPicture(),
                  ),
                  const SizedBox(height: 35),
                  TextFormField( 
                    autocorrect: false, // Disable auto-correction
                    controller: orgNameController, // set the controller
                    focusNode: orgNameFocusNode,
                    style: whiteBody,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      labelText: 'Organization\'s Name',
                      errorStyle: whiteBody.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12
                      ),
                      labelStyle: isOrgNameFocused
                      ? whiteBody.copyWith(
                        fontWeight: FontWeight.w800,
                      )
                      : whiteBody,
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
                  Spacer(),
                  GradientBorderButton(
                    onTap: () {},
                    text: 'Create Account',
                  ),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}