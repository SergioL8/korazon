import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:korazon/src/cloudresources/firestore_methods.dart';
import 'package:korazon/src/data/providers/user_provider.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:provider/provider.dart';

class EventCreationScreen extends StatefulWidget {
  const EventCreationScreen({super.key});

  @override
  State<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {

  Uint8List? _photofile; 
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventAgeController = TextEditingController();

  bool _isLoading = false;

  final user = FirebaseAuth.instance.currentUser; // get instance of the current user


  @override
  void initState() {
    super.initState();
    // Refresh user data when the screen initializes
    //TODO context.read<UserProvider>().refreshUser();
  }

  void postEvent(
    String uid, 
    String username,
    String? accountImage,
    

  ) async{
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreMethods().uploadPost( //1.uid, 2.username, 3.description, 4.accountImage, 5.file
        uid, 
        username,
        _eventNameController.text,
        _photofile!,
        _descriptionController.text,
        accountImage,
        _eventAgeController.text,
        //we can use the null asertion because to press the button you must have already selected the photofile
      );

      if(res == "success"){
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context,'Posted');
        clearImage();
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context, res);
      }
    
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  _selectImage(BuildContext context) async {
    return showDialog(context: context, builder: (context) {
      return SimpleDialog(
        title: const Text('Create a Post'),
        children: [
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: Text('Take Photo'),
            onPressed:() async{
              Navigator.of(context).pop();
              Uint8List file = await pickImage(ImageSource.camera); 
              //pickimage is a function from utils.

              setState(() {
                _photofile = file; 
              });
            },
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: Text('From Gallery'),
            onPressed:() async{
              Navigator.of(context).pop();
              Uint8List file  = await pickImage(ImageSource.gallery); //pickimage is a function from utils.

              setState(() {
                _photofile = file; 
                //photofile is now the picture we selected
              });
            },
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: Text('Cancel'),
            onPressed:() {
              Navigator.of(context).pop(); 
              //closes the dialog when pressed somewhere else
            }
          ),
        ],
      );
    }
    );
  }

  void clearImage() {
    setState(() {
      _photofile = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.getUser;

    if (user != null) {
      print('User data refreshed: ${user.username}');
    } else {
      print('No user data available');
    }

    return _photofile == null? Center( //mucho que mejorar aquí antes de poner el post
      child: IconButton(
        icon: Icon(Icons.upload),
        onPressed: () => _selectImage(context),
        ),
    ): Scaffold(
        appBar: AppBar(
         backgroundColor: primaryColor,
         leading: IconButton(
          color: secondaryColor,
          onPressed: clearImage,
          icon: Icon(Icons.arrow_back),
          ),
         title: const Text('Add Post',
           style: TextStyle(
            color: secondaryColor,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              if (user != null) {
                postEvent(
                  user.uid,
                  user.username!,
                  user.profilePicUrl,
                );
              } else {
                // Handle the case where user is null
                showSnackBar(context, 'User not logged in');
              }
            },
             child: const Text ('POST EVENT',
             style: TextStyle(
              color: secondaryColor,
             ),
             ),
          ),
        ],
      ),
      body: Column(
        children: [
          _isLoading? const LinearProgressIndicator() : Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 80,
                child: Image.asset('assets/images/starship.jpg'), // TODO: make this snap['userImage']
              )
            ],
          ),
          Container(
            width: double.infinity,
            height: 300, //TODO set as function of the image
            decoration: BoxDecoration(
              image: DecorationImage(
                image: MemoryImage(_photofile!)) //we have already selected it so we can assure it is not null
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width*0.5,
            // Description input field

            child: TextField(
              controller: _eventNameController,
              decoration: const InputDecoration(
                hintText: 'Event Title',
                border: InputBorder.none,
              ),
            maxLines: 8,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width*0.5,
            // Description input field

            child: TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Event Description',
                border: InputBorder.none,
              ),
            maxLines: 8,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width*0.5,
            // Description input field

            child: TextField(
              controller: _eventAgeController,
              decoration: const InputDecoration(
                hintText: 'Age (optional)',
                border: InputBorder.none,
              ),
            maxLines: 8,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}