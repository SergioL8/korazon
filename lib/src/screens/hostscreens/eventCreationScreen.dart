import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:korazon/src/screens/hostscreens/ticketCreationScreen.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/widgets/colorfulSpinner.dart';
import 'package:korazon/src/widgets/displayCurrentTickets.dart';
import 'package:korazon/src/widgets/selectAddressBox.dart';
import 'package:korazon/src/widgets/selectDateTime.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';



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
  Timestamp? _startDateTimeController;
  Timestamp? _endDateTimeController;
  TextEditingController _ageController = TextEditingController(text: '18'); // set initial value of the age to 18 (you need this because if the wheel is not moved, the controller will not be updated)
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(text: '0.00'); // set initial value of the price to 0.00
  UserModel? user;
  final FocusNode eventTitleFocousNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();
  bool isEventTitleFocused = false;
  bool isDescriptionFocused = false;
  bool addressError = false;
  LocationModel? _selectedLocation;
  List<TicketModel> tickets = [
    TicketModel(
      ticketID: 'firstTicket',
      ticketName: 'General Admission',
      ticketPrice: 0.00,
    )
  ]; // this will be used to store the tickets created by the user

  bool _isLoading = false; // this variable will be used to show a loading spinner when the user clicks the submit button
  Uint8List? _photofile; // this variable will be used to store the image file that the user uploads




  // call back function from the select address box
  void _onAddressSelected(LocationModel location) {
    setState(() {
      _selectedLocation = location; // update the selected location
      if (addressError) { // this variable is used to show an error in the address box. So we update it to false here if it was true and if the address is verified now
        if (_selectedLocation!.verifiedAddress == true) {
          addressError = false;
        }
      }
    });
  }

  void _onDateTimeSelected(DateTime? startDateTime, DateTime? endDateTime) {
    debugPrint('Start date time: $startDateTime');
    debugPrint('End date time: $endDateTime');
    if (startDateTime == null) {
      _startDateTimeController = null;
    } else{
      _startDateTimeController = Timestamp.fromDate(startDateTime); // update the start date time controller
    }
    if (endDateTime == null) {
      _endDateTimeController = null;
    } else {
      _endDateTimeController = Timestamp.fromDate(endDateTime); // update the end date time controller
    }
  }



 

  /// This function uploads the image to firebase storage and the event to firebase firestore. It uses the function from utils compressImage
  /// 
  /// The function doesn't take any parameters and doesn't return anything. But the result is the event uploaded to firestore
  void postEvent(
    //String? hostName,  //! These could come from the provider but we will get them from firestore 
    //String? profilePicUrl,
  ) async {

    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    // Check mandatory inputs
    if (_titleController.text.isEmpty) {
      showErrorMessage(context, title: 'Add a title to post your event.');
      return;
    }
    if (_startDateTimeController == null) {
      showErrorMessage(context, title: 'Please select a time and date.');
      return;
    }
    if (_endDateTimeController != null) { // check if the end date is before the start date
      final startDate = _startDateTimeController!.toDate();
      final endDate = _endDateTimeController!.toDate();
      if (endDate.isBefore(startDate)) { // check if the end date is before the start date
        showErrorMessage(context, title: 'The end date must be after the start date.');
        return;
      }
    }
    if (_selectedLocation == null) { // if no address has been selected, show an error message
      setState(() {
        addressError = true;
      });
      showErrorMessage(context, content: 'Please select an address');
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

    if (uid == null) {
      showErrorMessage(context, content: 'There was an error loading your user, please logout and login again', errorAction: ErrorAction.logout);
      return;
    }

    var userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

    user = UserModel.fromDocumentSnapshot(userDocument);

    if (user == null) {
      showErrorMessage(context, content: 'There was an error loading your user, please logout and login again', errorAction: ErrorAction.logout);
      return;
    }
    if (user!.isVerifiedHost == false) {
      showErrorMessage(context, content: 'Only verified users can post events', errorAction: ErrorAction.verify);
      return;
    }

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
        'photoPath': fileRef.fullPath,
        'description': _descriptionController.text,
        'location': _selectedLocation!.toMap(), // this is a helper function that converts the location to a map
        'startDateTime': _startDateTimeController,
        'endDateTime': _endDateTimeController,
        'price': double.parse(_priceController.text),
        'age': double.parse(_ageController.text),
        
        // Host variables
        'hostId': uid,
        'hostName': user!.name,
        'hostProfilePicUrl': user!.profilePicPath,
      });


      // add the created event to the host list of events
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'createdEvents': FieldValue.arrayUnion([docRef.id])
      });


      // Clear all controllers
      _titleController.clear();
      _startDateTimeController = null;
      _endDateTimeController = null;
      _ageController.clear();
      _descriptionController.clear();
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




  void newTicket({TicketModel? ticket}) async {
    final TicketModel? newTicket = await showModalBottomSheet<TicketModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: backgroundColorBM,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (_) => TicketCreationScreen(ticket: ticket,),
    );

    if (newTicket != null) {
      if (ticket != null) { // if the ticket is not null, it means that the user is editing an existing ticket
        setState(() {
          tickets[tickets.indexWhere((t) => t.ticketID == ticket.ticketID)] = newTicket;
        });
      } else { // if the ticket is null, it means that the user is creating a new ticket
        setState(() {
          tickets.add(newTicket);
        });
      }
    }
  }

  void removeTicket(String ticketID) {
    setState(() {
      tickets.removeWhere((ticket) => ticket.ticketID == ticketID);
    });
  }


  // intiailize the focus for the event title
  @override
  void initState() {
    super.initState();
    eventTitleFocousNode.addListener(() {
      setState(() {
        isEventTitleFocused = eventTitleFocousNode.hasFocus;
      });
    });
    descriptionFocusNode.addListener(() {
      setState(() {
        isDescriptionFocused = descriptionFocusNode.hasFocus;
      });
    });
  }





  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss the keyboard
      },
      child: Scaffold(
        backgroundColor: backgroundColorBM,
        appBar: AppBar(
          backgroundColor: backgroundColorBM,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              const Text('Create Event',
              style: TextStyle(
                color: tertiaryColor,
                fontWeight: primaryFontWeight,
                fontSize: 32.0,
              ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(
              height: barThickness,
              decoration: const BoxDecoration(
                gradient: mainGradient,
              ),
            ),
          ),
        ),
        body: Center(
          child: SingleChildScrollView( // makes the column scrollable
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.03), // 3% padding on all sides
              child: Column(
                children: [
                  const SizedBox(height: 15), // add some space at the top
                  TextField( // TITLE text field
                    controller: _titleController, // set the controller
                    focusNode: eventTitleFocousNode, // set the focus node
                    style: whiteSubtitle,
                    cursorColor: Colors.white,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.07),
                      labelText: 'Event Title',
                      labelStyle: whiteTitle.copyWith(
                        fontWeight: isEventTitleFocused ? FontWeight.w800 : FontWeight.w400,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always, // Always show label at the top left
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15), // rounded corners
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15), // Rounded corners
                        borderSide: BorderSide(color: Colors.white)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15), // Rounded corners
                        borderSide: BorderSide(color: Colors.white)
                      ),
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25), // rounded corners
                      child: Container(
                        height: MediaQuery.of(context).size.width, // Set height equal to the width of the screen
                        width: double.infinity, // take the full width of the screen
                      
                        // if there is no image uploaded, set the container to default style
                        decoration: _photofile == null ? 
                        BoxDecoration( 
                          image: DecorationImage( // Wrap AssetImage in DecorationImage
                            image: AssetImage('assets/images/addImagePlaceHolder.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ) :
                        // if there is an image uploaded, set the container to the image
                        BoxDecoration(
                          image: DecorationImage(
                            image: MemoryImage(_photofile!), // set the image to the image that the user uploaded
                            fit: BoxFit.cover, // cover the whole container with the image
                          ),
                        ),
                      
                        child: Center( // child is the same for both cases of _photofile null or not since the user might want to change the image
                          child: _photofile == null 
                          ? SizedBox()
                          : Icon(Icons.upload, size: 50, color: Colors.white), // add an icon to the center of the container
                        ),
                      ),
                    ),
                  ),
      
      
                  const SizedBox(height: 20),
      
      
                  TextField( // DESCRIPTION text field
                    minLines: 3, // make the text field thicker
                    maxLines: 5,
                    style: whiteBody,
                    cursorColor: Colors.white,
                    textCapitalization: TextCapitalization.sentences,
                    controller: _descriptionController, // set the controller
                    focusNode: descriptionFocusNode,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.07),
                      labelText: 'Description',
                      labelStyle: whiteSubtitle.copyWith(
                        fontWeight: isDescriptionFocused ? FontWeight.w800 : FontWeight.w400,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always, // Always show label at the top left
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15), // rounded corners
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15), // Rounded corners
                        borderSide: BorderSide(color: Colors.white)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15), // Rounded corners
                        borderSide: BorderSide(color: Colors.white)
                      ),
                    ),
                  ),
      
      
                  const SizedBox(height: 20),
      
                  SelectAddressBox(onAddressSelected: _onAddressSelected, error: addressError),
      
                  const SizedBox(height: 20),
      
                  // DATE TIME BUTTON   
                  SelectDateTime(onDateChanged: _onDateTimeSelected, dateTimeUse: DateTimeUse.event,),
      
                  const SizedBox(height: 20),

                  TicketsSection(tickets: tickets, newTicket: newTicket, removeTicket: removeTicket,), // this widget will show the tickets created by the user

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
                          ColorfulSpinner(
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
      ),
    );
  }

  // Dispose controllers to avoid memory leaks
  @override
  void dispose() {
    _titleController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}