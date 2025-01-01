import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'design_variables.dart';
import 'dart:typed_data';


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



/// This function prompts the user a menu ("Dialog") for the user to select wheter the image 
/// he is going to submit will come from the camera or the gallery
/// 
/// The result is that when the user has selected that image, it will now be a Uint8List 
/// stored as _photofile
Future<Uint8List?> selectImage(BuildContext context) async {
  return showDialog<Uint8List?>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: [
            SimpleDialogOption( // the camera button
              padding: const EdgeInsets.all(20),
              child: Text('Take Photo'),
              onPressed: () async {
                Uint8List file = await pickImage(ImageSource.camera); //pickimage is a function from utils.
                Navigator.of(context).pop(file); // Pop with the file (basically return the file but while closing the dialog)
                
              },
            ),
            SimpleDialogOption( // the gallery button
              padding: const EdgeInsets.all(20),
              child: Text('From Gallery'),
              onPressed: () async {
                Uint8List file = await pickImage(ImageSource.gallery); //pickimage is a function from utils.
                Navigator.of(context).pop(file); // Pop with the file (basically return the file but while closing the dialog)
                
              },
            ),
            SimpleDialogOption( // this is the cancel button
                padding: const EdgeInsets.all(20),
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(null); //closes the dialog when pressed somewhere else and return null
                }),
          ],
        );
      });
}



/// Compresses the image to reduce the size
/// 
/// Parameters: [image] image to be compressed and [quality] integer between 0 and 100 to set the quality of the image
/// 
/// Output: Compressed image as Uint8List
Future<Uint8List> compressImage(Uint8List image, int quality) async {
    final result = await FlutterImageCompress.compressWithList(
      image,
      minHeight: 720,
      minWidth: 720,
      quality: quality,
      rotate: 0,
    );

    return result;
}