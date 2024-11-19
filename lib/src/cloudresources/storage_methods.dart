import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data'; // for the Uint8List
import 'package:uuid/uuid.dart'; // for the Uuid
//import 'package:logger/logger.dart'; reduces debugging messages


class StorageMethods {
  final FirebaseStorage _storage =
      FirebaseStorage.instance; //instanciating firebase storage
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage(
      String childName, String uid, Uint8List file, bool isPost) async {
    if (_auth.currentUser == null) {
      print( 'USER IS NOT AUTHENTICATED');
      throw Exception("STORAGE METHODS: User is not authenticated");
    }
    if (file.isEmpty) {
      throw Exception("UPLOAD IMAGE TO STORAGE: EMPTY FILE");
    }
    print('FILE SIZE: ${file.lengthInBytes}');

    Reference storageRef = _storage.ref().child('$childName/$uid/example.jpg');

    if (isPost) {
      String id = const Uuid().v1();
      storageRef = storageRef.child(id);
      print('Generated ID for post: $id');
    }
    print('UPLOADING TO PATH: ${storageRef.fullPath}');

    try {
      print('post try upload started');

      final metadata = SettableMetadata(contentType: 'image/jpeg');
      UploadTask uploadTask = storageRef.putData(file, metadata);
      await uploadTask.whenComplete(() => null);

      final TaskSnapshot snap = await uploadTask;

      if (snap.state != TaskState.success) {
        throw Exception("Failed to upload image: ${snap.state}");
      }

      final String downloadUrl = await snap.ref.getDownloadURL();
      return downloadUrl;

    } on FirebaseException catch (e) {
        print('Firebase Exception: ${e.code} - ${e.message}');
        throw Exception("Firebase error: ${e.message}");

    } catch (e) {
      print('Error uploading image: $e');
      throw Exception("Failed to upload image: $e");
    }
  }
}
