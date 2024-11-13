import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data'; // for the Uint8List
import 'package:uuid/uuid.dart'; // for the Uuid
//import 'package:cloud_firestore/cloud_firestore.dart';

class StorageMethods{
  final FirebaseStorage _storage = FirebaseStorage.instance; //instanciating firebase storage
  final FirebaseAuth _auth =FirebaseAuth.instance;

  //adding image to firebase storage 
  Future<String> uploadImageToStorage(String childName, Uint8List file, bool isPost) async {

    Reference storageRef = _storage.ref().child(childName).child(_auth.currentUser!.uid); 

    /*childName is the folder where this will be stored, wether this previously existed or not
    the uploaded image is going to be stored in folder "childName" in a sub folder with the users id
    this method was created to be instantiated somewhere else in order to upload an image to firestore */

    if (isPost) { //with this logic, if the upload is a post the user id will not be kept for that post 
                  //because an account can have many different posts

      String id = const Uuid().v1();
      storageRef = storageRef.child(id);
    }

    try{
    UploadTask uploadTask = storageRef.putData(file); 
    
    // the putData starts the upload and creates the uploadTask object, which measures the progress of the upload 
                                                     
    // (we could also add metadata here)
    
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL(); // we get a url that points to the storage collection where the file is stored
    return downloadUrl; // now we can save it in our users collection

    } catch (e) {
      throw Exception("Failed to upload image");
    }
  }
}
// String photoUrl = await StorageMethods().uploadImageToStorage('profilePics', file, false);

/*Potential improvements:
  Error handling: Add try-catch blocks to handle potential upload failures.
  Progress tracking: Implement a way to track and report upload progress.
  Metadata: Consider adding options to include metadata with the uploads.
  File type checking: Implement checks for file types and sizes before upload.*/