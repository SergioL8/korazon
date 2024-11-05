import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/cloudresources/storage_methods.dart';
import 'dart:typed_data'; // for the Uint8List
import 'package:korazon/src/data/models/event.dart' as model;
import 'package:uuid/uuid.dart'; //? Investigate uuid


class FirestoreMethods{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Method for uploading a post

  Future<String> uploadPost(
    String uid,
    String username,
    String eventName,
    Uint8List eventImageFile, //This is the actual raw data of the file
    String description,
    String? accountImage,
    String? eventAge,


  ) async{
    String result = "some error occurred";
    try{
      String imageUrl = await StorageMethods().uploadImageToStorage('postImages', eventImageFile, true);
      //Instead of storing the actual data of the image in firestore, we take a refence of where that file
      //is loacated within the firestore storage

      String postId = const Uuid().v1(); // creates a unique id for the post every time

      model.Event post = model.Event(
        uid: uid,
        username: username,
        eventName: eventName,
        description: description,
        eventImage: imageUrl,
        eventAge: eventAge,
        profilePicUrl: accountImage,
      );

      await _firestore.collection('posts').doc(postId).set(post.toJson(),); //we can format the document
      result = 'success';
      print('Document added/updated successfully');
    } catch(error){
      result = error.toString();
      print('Error adding/updating document: $error');
    }
    print(result);
    return result;
  } 

  //Updating likes and comments will also be here
}