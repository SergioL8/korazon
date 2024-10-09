import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../lib1/models/user.dart' as model;

class AuthMethods{
  final FirebaseAuth _auth = FirebaseAuth.instance; //FirebaseAuth is already a class, we are instanciating it now to create multiple functions with it
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance; //Provides access to Firestore DB

Future<String> signUpUser({ 
   //constructor function that it is called to authenticate the user
    required String email,
    required String password,
    required String username,
    
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        return "Please fill all the fields";
      }
      print('Paso al otro lado');

      UserCredential? credentials = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      //the line above creates a variable credentials of Class UserCredential which will store the information that the firebase auth gives it such as the userid or 'uid'
      if (credentials.user == null) {
        return "Failed to create user";
      }
      // add user to database as a model within this file

      model.User user = model.User(
        username: username,
        uid: credentials.user!.uid,
        email:email,
        //usersFollowing: following [],
      );

      await _firebaseFirestore.collection('users').doc(credentials.user!.uid).set(user.toJson());//this creates a document in the users collection in firestore
        //to Json means that the data in the document is in a map structured format.
        //CONSIDER: using transaction
      return 'succcess';

    }on FirebaseAuthException catch (err) {
      switch (err.code) {
        case 'invalid-email':
          return 'invalid-email';
        case 'weak-password':
          return 'invalid-password';
        case 'email-already-in-use':
          return "This email is already registered";
        default:
          return "Authentication error: ${err.message}";
      }
    }
  }
}