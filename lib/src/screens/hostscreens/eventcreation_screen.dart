import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:korazon/src/cloudresources/firestore_methods.dart';
import 'package:korazon/src/data/providers/user_provider.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class EventCreationScreen extends StatefulWidget {
  const EventCreationScreen({super.key});

  @override
  State<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {

  Uint8List? _photofile;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventAgeController = TextEditingController();
  // Age should probably be a scrolling wheel

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Refresh user data when the screen initializes
    Provider.of<UserProvider>(context, listen: false).refreshUser();
    //context.read<UserProvider>().refreshUser();
  }


  Future<Uint8List> compressImage(Uint8List image) async {
    final result = await FlutterImageCompress.compressWithList(
      image,
      minHeight: 1000,
      minWidth: 1000,
      quality: 50,
      rotate: 0,
    );

    return result;
  }


  void postEvent(String uid, String username, String? accountImage, ) async {

    setState(() {
      _isLoading = true;
    });

    if (_photofile == null) {
      showSnackBar(context, 'Please select an image before posting');

    } else {

      try {
        // create storage reference
        Reference storageRef = FirebaseStorage.instance.ref();
        
        // check that the image is not null
        if (_photofile == null) {
          showSnackBar(context, 'Please select an image before posting');
          return;
        }

        // specify the path and name of the image
        Reference fileRef = storageRef.child('images/events/${uid}_${_eventTitleController.text}_${DateTime.now()}.png');
        
        // compress the image
        _photofile = await compressImage(_photofile!);

        // upload the image to the storage
        UploadTask uploadTask = fileRef.putData(_photofile!);

        TaskSnapshot taskSnapshot = await uploadTask;

        if (taskSnapshot.state != TaskState.success) {
          showSnackBar(context, 'Image upload failed. Try again.');
          return;
        }

        // get the download url of the image
        // String filePath = await fileRef.fullPath();


        String res = await FirestoreMethods().uploadPost(
          //1.uid, 2.username, 3.EventName, 4.file, 5.description
          uid,
          username,
          _eventTitleController.text,
          fileRef.fullPath,  
          _descriptionController.text,
          accountImage, // 6. account image
          _eventAgeController.text, // 7. event age

          //we can use the null asertion because to press the button you must have already selected the photofile
        );


        print('Upload result: $res');


        if (res == "success") {
          setState(() {
            _isLoading = false;
          });
          showSnackBar(context, 'Posted');
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
  }

  _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Create a Post'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Text('Take Photo'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.camera);
                  //pickimage is a function from utils.

                  setState(() {
                    _photofile = file;
                  });
                  print('image set');
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Text('From Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource
                      .gallery); //pickimage is a function from utils.

                  setState(() {
                    _photofile = file;
                    //photofile is now the picture we selected
                  });
                  print('image set');
                },
              ),
              SimpleDialogOption(
                  padding: const EdgeInsets.all(20),
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    //closes the dialog when pressed somewhere else
                  }),
            ],
          );
        });
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
    _eventTitleController.dispose();
    _eventAgeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.getUser;

    if (user == null) {
      print('No user data available in eventcreation page');
      return Center(
        child: CircularProgressIndicator(),
      );

    } else {
      print('User data refreshed in eventcreation page: ${user.username}');
    }

    return _photofile == null
        ? Center(
            //mucho que mejorar aquí antes de poner el post
            child: IconButton(
              icon: Icon(Icons.upload),
              onPressed: () => _selectImage(context),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: korazonColor,
              leading: IconButton(
                color: secondaryColor,
                onPressed: clearImage,
                icon: Icon(Icons.arrow_back),
              ),
              title: const Text(
                'Add Post',
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
                        user.username,
                        user.profilePicUrl,
                      );
                    } else {
                      // Handle the case where user is null
                      showSnackBar(context, 'User not logged in');
                    }
                  },
                  child: const Text(
                    'POST EVENT',
                    style: TextStyle(
                      color: secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _isLoading ? const LinearProgressIndicator() : Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        child: Image.asset(
                            'assets/images/starship.jpg'), // TODO: make this snap['userImage']
                      )
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    height: 300, //TODO set as function of the image
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: MemoryImage(
                                _photofile!)) //we have already selected it so we can assure it is not null
                        ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    // Description input field

                    child: TextField(
                      controller: _eventTitleController,
                      decoration: const InputDecoration(
                        hintText: 'Event Title',
                        border: InputBorder.none,
                      ),
                      maxLines: 8,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
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
                    width: MediaQuery.of(context).size.width * 0.5,
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
            ),
          );
  }
}
