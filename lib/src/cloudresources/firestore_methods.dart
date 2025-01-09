import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/data/models/event.dart' as model;
import 'package:uuid/uuid.dart'; 

class FireStoreMethods{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Method for uploading a post

  Future<String> uploadPost(
    String uid,
    String? username,
    String? eventName,
    String imageUrl,
    // Uint8List eventImageFile, //This is the actual raw data of the file
    String? description,
    String? accountImage,
    String? eventAge,


  ) async{
    String result = "some error occurred";
      try{
      //String imageUrl = await StorageMethods().uploadImageToStorage('postImages', uid, eventImageFile, false);
      String postId = const Uuid().v1(); // creates a unique id for the post every time

      model.Event post = model.Event(
        accountId: uid,
        postId: postId,
        username: username,
        eventName: eventName,
        description: description,
        eventImageUrl: imageUrl,
        eventAge: eventAge,
        profilePicUrl: accountImage,
      );

      await _firestore.collection('posts').doc(postId).set(post.toJson(),); 
      //we can format the document
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

  Future<void> followUser(
    String uid,
    String followingUserId, // This is the user of the profile you are in 
  ) async {
    try{
      DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followingUserId)) {
        await _firestore.collection('users').doc(followingUserId).update({
          'followers': FieldValue.arrayRemove([uid]),
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followingUserId]),
        });

      } else {
        await _firestore.collection('users').doc(followingUserId).update({
          'followers': FieldValue.arrayUnion([uid]),
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followingUserId]),
        });
      }
    } catch (e){
      print(e.toString());
    }
  }

}