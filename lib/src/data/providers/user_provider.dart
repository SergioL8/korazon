import 'package:flutter/material.dart';
import 'package:korazon/src/data/models/user.dart';
import 'package:korazon/src/cloudresources/authentication.dart';

//Functions refreshUser () & getUser
  class UserProvider with ChangeNotifier {
    User? _user; //user is a  private nullable variable that will hold the current user's data

    final AuthMethods _authMethods = AuthMethods(); //AuthMethods is a class that contains methods to get user details

    User? get getUser => _user; //the function user will return _user when called outside of the class, besides _user being a private variable
    //it is a function that returns _user as a nullable User object 

    Future<void> refreshUser() async{// Implementation to refresh user data goes here
      User? user = await _authMethods.getUserDetails(); //getUserDetails is defined in auth_method file 
      _user = user;
      notifyListeners(); // notify listeners that the user has been updated
    }
  }

  /*  UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      User? currentUser = userProvider.getUser;

      that is how you instantiate this class, first the provider then the function

  */