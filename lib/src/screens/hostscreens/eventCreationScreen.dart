import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/widgets/pickDateTime.dart';
import 'package:wheel_chooser/wheel_chooser.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/utils.dart';



class EventCreationScreen extends StatefulWidget {
  const EventCreationScreen({super.key});

  @override
  EventCreationScreenState createState() => EventCreationScreenState();
}




class EventCreationScreenState extends State<EventCreationScreen> {

  // get the uid of the host creating the event
  final uid = FirebaseAuth.instance.currentUser?.uid;

  // Variable declaration
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  TextEditingController _ageController = TextEditingController(text: '18'); // set initial value of the age to 18 (you need this because if the wheel is not moved, the controller will not be updated)
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(text: '0.00'); // set initial value of the price to 0.00
  var userData = {};

  bool _isLoading = false; // this variable will be used to show a loading spinner when the user clicks the submit button
  Uint8List? _photofile; // this variable will be used to store the image file that the user uploads





  /// This function uploads the image to firebase storage and the event to firebase firestore. It uses the function from utils compressImage
  /// 
  /// The function doesn't take any parameters and doesn't return anything. But the result is the event uploaded to firestore
  void postEvent(
    //String? hostName,  //! These could come from the provider but we will get them from firestore 
    //String? profilePicUrl,
  ) async {

    if (uid == null) {
      showErrorMessage(context, content: 'There was an error loading your user, please logout and login again');
      return;
    }

    var userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
    
    if (!userDocument.exists) {
      showErrorMessage(context, content: 'There was an error loading your user, please logout and login again');
      return;
    }

    userData = userDocument.data()!;


    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    // Check mandatory inputs
    if (_titleController.text.isEmpty) {
      showErrorMessage(context, title: 'Add a title to post your event.');
      return;
    }
    if (_dateTimeController.text.isEmpty) {
      showErrorMessage(context, title: 'Please select a time and date.');
      return;
    }
    if (_locationController.text.isEmpty) {
      showErrorMessage(context, title: 'Please select a location.');
      return;
    }
    if (_photofile == null) {
      showErrorMessage(context, title: 'Please add a flyer.');
      return;
    }
    if (_priceController.text.isEmpty) {
      showErrorMessage(context, title: 'Please set a ticket price.');
      return;
    }

    setState(() {
      _isLoading = true; // set the loading spinner to true
    });


    // compress the image (compressImage is a helper function that can be found under the utils folder)
    _photofile = await compressImage(_photofile!, 50);

    // specify the path and name of the image
    Reference storageRef = FirebaseStorage.instance.ref(); // create storage reference (basically the root of the storage bucket on the cloud)
    Reference fileRef = storageRef.child('images/events/${uid}_${_titleController.text}_${DateTime.now()}.png');

    // save the image to firebase storage
    UploadTask imageUploadTask = fileRef.putData(_photofile!); // here uploadtask is a variable that stores information about how the upload is going

    // This line will wait the execution of the function until the upload has completed (success or failure).
    TaskSnapshot imageTaskSnapshot = await imageUploadTask;

    // check for success or failure of the image upload
    if (imageTaskSnapshot.state != TaskState.success) {
      showErrorMessage(context, content: 'There was an error uploading the image. Please try again');
    }

    try {
      // save the event to firebase firestore
      DocumentReference docRef = await FirebaseFirestore.instance.collection('events').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'dateTime': _dateTimeController.text,
        'location': _locationController.text,
        'price': double.parse(_priceController.text),
        'age': double.parse(_ageController.text),
        'photoPath': fileRef.fullPath,
        
        // Host variables
        'hostId': uid,
        'hostName': userData['name'],
        'hostProfilePicUrl': userData['profilePicUrl'],
      });


      // add the created event to the host list of events
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'createdEvents': FieldValue.arrayUnion([docRef.id])
      });


      // Clear all controllers
      _titleController.clear();
      _dateTimeController.clear();
      _ageController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _priceController.clear();
      _photofile = null; // Clear the image file


      // show a success message to the user
      showSnackBar(context, 'Post created successfully');


    } catch (e) { // catch any errors that occur during the upload
      showErrorMessage(context, content: 'There was an error posting your event. Please try again');
    }


    setState(() {
      _isLoading = false; // set the loading spinner to true
    });
  }





  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
            backgroundColor: korazonColorLP,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const Text('Create an Event',
                style: TextStyle(
                  color: secondaryColor,
                  fontWeight: primaryFontWeight,
                  fontSize: 32.0,
                ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2.0),
              child: Container(
                color: korazonColor,
                height: 4.0,
              ),
            ),
          ),
      body: Center(
        child: SingleChildScrollView( // makes the column scrollable
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.03), // 3% padding on all sides
            child: Column(
              children: [


                TextField( // TITLE text field
                  style: TextStyle( // change the size of the input text (the text when typing)
                    fontSize: 40,
                  ),
                  controller: _titleController, // set the controller
                  decoration: InputDecoration(
                    labelStyle: TextStyle( // change the size of the label text
                      fontSize: 40,
                    ),
                    labelText: 'Event Title',
                    ),
                ),


                const SizedBox(height: 20),

                // UPLOAD IMAGE
                InkWell( // this will make the container clickable
                  onTap: () async {
                    Uint8List? file = await selectImage(context); // get the image file from the user
                    if (file != null) {
                      setState(() {
                        _photofile = file; // set the image file to the file that the user uploaded
                      });
                    }
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.23, // set the container to a height relative to the device
                    width: double.infinity, // take the full width of the screen

                    // if there is no image uploaded, set the container to default style
                    decoration: _photofile == null ? 
                    BoxDecoration( 
                      borderRadius: BorderRadius.circular(15), // rounded corners
                      color: const Color.fromARGB(255, 158, 158, 158), // set background color of the container to grey
                    ) :
                    // if there is an image uploaded, set the container to the image
                    BoxDecoration(
                      borderRadius: BorderRadius.circular(15), // rounded corners
                      image: DecorationImage(
                        image: MemoryImage(_photofile!), // set the image to the image that the user uploaded
                        fit: BoxFit.cover, // cover the whole container with the image
                      ),
                    ),

                    child: Center( // child is the same for both cases of _photofile null or not since the user might want to change the image
                      child: Icon(Icons.upload, size: 50, color: Colors.white), // add an icon to the center of the container
                    ),
                  ),
                ),


                const SizedBox(height: 20),


                TextField( // DESCRIPTION text field
                  minLines: 3, // make the text field thicker
                  maxLines: 5,
                  controller: _descriptionController, // set the controller
                  decoration: InputDecoration(
                    labelText: 'Description...',
                    alignLabelWithHint: true, // Aligns the label with the top of the text field
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15), // rounded corners
                    ),
                  ),
                ),


                const SizedBox(height: 20),


                TextField( // LOCATION text field
                  controller: _locationController, // set the controller
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15), // rounded corners
                    ),
                  ),
                ),


                const SizedBox(height: 20),


                // DATE TIME BUTTON
                SizedBox(
                  width: double.infinity, // take the full width of the screen
                  child: TextButton(

                    style: ButtonStyle(
                      fixedSize: WidgetStatePropertyAll(Size(double.infinity, 50)), // set the size of the button
                      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // rounded corners
                          side: BorderSide(color: const Color.fromARGB(255, 127, 127, 127), width: 1.1), // add a border to the button
                        ),
                      ),
                    ),

                    onPressed: () async {
                      final String? date = await selectDateTime(context); // execute the function to get the date and time
                      setState(() {
                        if (date != null) {
                          _dateTimeController.text = date; // once the date and time is selected, set the controller to the selected date and time
                        }
                      });
                    },

                    child: _dateTimeController.text.isEmpty ? // dynamically change the text of the button
                    const Text('Select Date&Time') : 
                    Text(_dateTimeController.text),
                  ),
                ),


                const SizedBox(height: 20),


                // AGE WHEEL
                SizedBox( // necessary to size the column to a fixed height
                  height: 100,
                  child: Column(
                    children: [
                      Text('Age'), // add a label
                      Expanded( // necessary to make the wheel chooser take the full height of the column
                        child: WheelChooser.integer( // this is a widget from the wheel_chooser package
                          onValueChanged: (s) => _ageController.text = s.toString(), // when the wheel is moved update the controller
                          initValue: 18, // set an initial value
                          minValue: 1, // set the minimum value
                          maxValue: 99, // set the maximum value
                          horizontal: true, // make the wheel horizontal, if false, it would be vertical
                        ),
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 20),

                // PRICE text field
                Container(
                  height: MediaQuery.of(context).size.height * 0.12, // set the container to a height relative to the device
                  width: double.infinity, // take the full width of the screen
                  padding: EdgeInsets.all(20), // add padding to the container
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15), // rounded corners
                    color: const Color.fromRGBO(250, 177, 177, 1), // this color will have to be updated to the korazon color
                  ),
                  child: Row( // this row is necessary to have the label and the text field side by side
                    children: [
                      Expanded( // this is necessary to make the text field take the full width of the container
                        child: Center(
                          child: Text(
                            'Price',
                            style: TextStyle( // style the text
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        )
                      ),
                      Expanded( // this is necessary to make the text field take the full width of the container
                        child: TextField(
                          style: TextStyle(color: Colors.white), // change the color of the input text (what is being written)
                          controller: _priceController, // set the controller
                          keyboardType: TextInputType.numberWithOptions(decimal: true), // set the keyboard type to only numbers and a decimal point
                          inputFormatters: [ // this field forces a type of input
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+([.,]\d{0,2})?$')), // only allow digits and a decimal point (need to know regex to understand this)
                          ],
                          onChanged: (value) {
                            // If the user typed a comma, replace it with a dot
                            if (value.contains(',')) {
                              final cursorPos = _priceController.selection.baseOffset;
                              final newValue = value.replaceAll(',', '.');
                              _priceController.text = newValue;
                              // Restore the cursor position
                              _priceController.selection = TextSelection.collapsed(offset: cursorPos);
                            }
                          },
                          decoration: InputDecoration( // decoration for the text field
                            contentPadding: const EdgeInsets.symmetric(vertical: 38), // add vertical padding
                            filled: true, // allows to add a fill color
                            fillColor: Colors.black, // set the fill color to black
                            prefixIcon: Icon(Icons.attach_money), // add a money icon to the left of the text field
                            prefixIconColor: Colors.white, // set the color of the icon to white
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15), // rounded corners
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 20),


                // POST EVENT BUTTON
                InkWell(
                  onTap:() => postEvent(
                  //  user?.name, //! This could also come from provider
                  //  user?.profilePicUrl, //! Make sure to add to provider 
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.12, // set the container to a height relative to the device
                    width: double.infinity, // take the full width of the screen
                    padding: EdgeInsets.all(20), // add padding to the container
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15), // rounded corners
                      color: const Color.fromARGB(255, 0, 0, 0), // this color will have to be updated to the korazon color
                    ),
                    child: Center(
                      child: _isLoading ? 
                        CircularProgressIndicator(
                          color: const Color.fromRGBO(250, 177, 177, 1),
                        ) : 
                        Text(
                          'Post Event',
                          style: TextStyle( // style the text
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromRGBO(250, 177, 177, 1),
                                ),
                        )
                    )
                    
                  ),
                )
              ]
            ),
          ),
        )
      ),
    );
  }

  // Dispose controllers to avoid memory leaks
  @override
  void dispose() {
    _titleController.dispose();
    _dateTimeController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
