import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'design_variables.dart';

// for picking up image from gallery

pickImage(ImageSource source) async { //To instanciate this: Uint8List image = await pickImage(ImageSource.gallery);
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source);
  if (file != null) {
    return await file.readAsBytes();
  }
}

showSnackBar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: Text(
          text,
          style: TextStyle(
            color: tertiaryColor,
            fontSize: primaryFontSize,
          ),
        ),
      ),
      backgroundColor: secondaryColor,
      elevation: 100,
      padding: EdgeInsets.symmetric(vertical: 20),
    ),
  );
}