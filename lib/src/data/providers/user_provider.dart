import 'package:flutter/material.dart';
import 'package:korazon/src/data/models/user.dart';
import 'package:korazon/src/cloudresources/authentication.dart';

//Functions refreshUser () & getUser
  class UserProvider with ChangeNotifier {
    User? _user; //user is a  private nullable variable that will hold the current user's data

    final AuthMethods _authMethods = AuthMethods(); //AuthMethods is a class that contains methods to get user details

    User? get getUser => _user; 
    //the function user will return _user when called outside of the class, besides _user being a private variable
    //it is a function that returns _user as a nullable User object 

    Future<void> refreshUser() async{
      print('Refreshing user data in user provider...');

      User? user = await _authMethods.getUserDetails(); 
      //getUserDetails is defined in auth_method file 
      if (user != null) {
        print('User data fetched in provider: ${user.username}');
        _user = user;
        notifyListeners(); 
      // notify listeners that the user has been updated
      }else {
        print('Failed to fetch user data in provider');
  }
    }
  }

  /* final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false); 
        with this line you instanciate the class 
     final User? currentUser = userProvider.getUser;
        with this one you give the variable curretUser all the information of the current user model 
      that is how you instantiate this class, first the provider then the function

  */