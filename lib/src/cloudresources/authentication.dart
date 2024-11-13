import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korazon/src/data/models/user.dart' as model;

//Functions: getUserDetails, signUpUser, loginUser
class AuthMethods{
  final FirebaseAuth _auth = FirebaseAuth.instance; //FirebaseAuth is already a class, we are instanciating it now to create multiple functions with it
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance; //Provides access to Firestore DB

  static const String defaultError = "An unexpected error occurred";
  static const String invalidEmail = "The email address is invalid";
  static const String weakPassword = "Password should be at least 6 characters long";

  Future<model.User?> getUserDetails() async{
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
    print("No user is currently signed in");
    return null;
    }

    try {
    DocumentSnapshot snap = await _firebaseFirestore.collection('users').doc(currentUser.uid).get();
    //this function gives us the info of the authenticated user
    return model.User.fromSnap(snap);
    } catch (e){
      print("Error fetching user details: $e");
      return null;
    }
  }

  Future<String> signUpUser({  //constructor function that it is called to authenticate the user
    required String email,
    required String password,
    required String username,
    required bool isHost,
    required String name,
    required int age,
    
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || username.isEmpty || name.isEmpty) {
        return "Please fill all the fields";
      }

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
        isHost: isHost,
        name: name,
        age: age,
      );

      await _firebaseFirestore.collection('users').doc(credentials.user!.uid).set(user.toJson(), SetOptions(merge: true));


      //await _firebaseFirestore.collection('users').doc(credentials.user!.uid).set(user.toJson());//this creates a document in the users collection in firestore
        //to Json means that the data in the document is in a map structured format.
        //CONSIDER: using transaction
        
      return 'success';

    }on FirebaseAuthException catch (err) {
      switch (err.code) {
        case 'invalid-email':
          return invalidEmail;
        case 'weak-password':
          return weakPassword;
        case 'email-already-in-use':
          return "This email is already registered";
        default:
          return "Authentication error: ${err.message}";
      }
    }
  }

    //logging in user

    Future<String> loginUser({
      required String email,
      required String password,
    }) async { 
      String res = 'An error occurred';
     try {
      if (email.isNotEmpty && password.isNotEmpty){
        await _auth.signInWithEmailAndPassword(email: email, password: password); // no user credentials needed because they are already in the DB
        res = "success";
      } else {
        res = "Please fill all fields";
      } 

    } on FirebaseAuthException catch (e) {  // to give custom messages depending on the error
      if (e.code == 'user-not-found'){
        res = 'User not found';
      }
      if (e.code == 'A network error has occured'){
        res = 'A network error has occured';
      }
    }
    
     catch (err) {
      res = err.toString();
    } return res;
  } 

 Future<void> signOut() async {
    await _auth.signOut();

    // Clear any stored user data
    // For example, if you're using shared preferences:
    // await SharedPreferences.getInstance().then((prefs) => prefs.clear());
  }
}