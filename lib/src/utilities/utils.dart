import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'design_variables.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';


// This enum is used to determine if the user is in the scan page or the analytics page
// It is used to render the correct icon button and the correct onTap action when selecting an event in these pages
enum HostAction {
  scan,
  analytics,
}

enum ErrorAction {
  none,
  logout,
}


// Used to let certain pages like event details where they have been called
enum ParentPage {
  homePage,
  yourEvents,
  ownProfile,
  userProfile,
  hostProfile,
  blacklistPage,
  other,
  login,
  signup
}


// for picking up image from galleryc

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



/// This function retrieves an image from the storage
/// 
/// Input: the path to the image in the storage
/// Output: the image as a Uint8List
Future<Uint8List?> getImage(imagePath) async{

  if (imagePath == '') {

    return null;

  } else {
    // get the storage reference
    Reference storageRef = FirebaseStorage.instance.ref();

    // get the file reference
    Reference fileRef = storageRef.child(imagePath);

    Uint8List? imageData = await fileRef.getData();

    return imageData;
  }
}





Future<String?> createQRCode(String uid) async {

  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final qrData = '$uid,$timestamp';

  final qrValidationResult = QrValidator.validate( // validate data and produce the qrCode
    data: qrData,
    version: QrVersions.auto, // set the version to auto
    errorCorrectionLevel: QrErrorCorrectLevel.L // set the correction levle to low so the qr is as small as possible
  );

  if (qrValidationResult.status != QrValidationStatus.valid) { // validate qr code
    return null;
  }

  final qrCode = qrValidationResult.qrCode!; // get the actual qrCode

  // Create a QrPainter to render the QR code as an image
  final painter = QrPainter.withQr(
    eyeStyle: QrEyeStyle(
      eyeShape: QrEyeShape.square, // You can change this to QrEyeShape.circle for rounded eyes
      color: korazonColor, // Color of the eyes
    ),
    qr: qrCode,
    gapless: true, // no gaps between squares of the qrcode
  );

  // Convert the QR code to image data
  final picData = await painter.toImageData(500, format: ui.ImageByteFormat.png); // format the qrcode as a png with format 
  
  final uint8List =  picData?.buffer.asUint8List(); // convert to uint8lsit to store

  // Convert the Uint8List to a base64 string
  if (uint8List != null) {
    return 'data:image/png;base64,${base64Encode(uint8List)}';
  } else {
    return null;
  }

}