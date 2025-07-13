import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:korazon/src/screens/hostscreens/ticketCreationScreen.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/widgets/confirmationMessage.dart';
import 'package:korazon/src/widgets/displayCurrentTickets.dart';
import 'package:korazon/src/widgets/selectAddressBox.dart';
import 'package:korazon/src/widgets/selectDateTime.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';



class EventCreationScreen extends StatefulWidget {
  const EventCreationScreen({super.key});

  @override
  EventCreationScreenState createState() => EventCreationScreenState();
}



class EventCreationScreenState extends State<EventCreationScreen> {

  // get the uid of the host creating the event
  final uid = FirebaseAuth.instance.currentUser?.uid;

  late List<TicketModel> tickets;
  late DocumentReference eventRef;

  // Variable declaration
  UserModel? user;
  Timestamp? _startDateTimeController;
  Timestamp? _endDateTimeController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode eventTitleFocousNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();
  bool isEventTitleFocused = false;
  bool isDescriptionFocused = false;
  bool addressError = false;
  bool plus21 = false;
  LocationModel? _selectedLocation;
  

  bool _isLoading = false; // this variable will be used to show a loading spinner when the user clicks the submit button
  Uint8List? _photofile; // this variable will be used to store the image file that the user uploads
  int _dateTimeWidgetKey = 0;
  int _adressWidgetKey = 0;




  // call back function from the select address box
  void _onAddressSelected(LocationModel location) {
    setState(() {
      _selectedLocation = location; // update the selected location
      if (_selectedLocation!.verifiedAddress == true) {
        addressError = false;
      } else{
        addressError = true; // if the address is not verified, we set the error to true
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
  void postEvent() async {
    debugPrint('Address Error: $addressError');
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    // ~~~~~~~~~~~~~~~ TRIM INPUTS ~~~~~~~~~~~~~~~~~~~
    _titleController.text = _titleController.text.trim();
    _descriptionController.text = _descriptionController.text.trim();

    // ~~~~~~~~~~~~~~~ CHECK REQUIRED FIELDS ~~~~~~~~~~~~~~~~~~~
    if (_titleController.text.isEmpty) {
      showErrorMessage(context, title: 'Add a title to post your event');
      return;
    }

    if (_photofile == null) {
      showErrorMessage(context, title: 'Please add a flyer');
      return;
    }

    if (addressError) {
      showErrorMessage(context, content: 'Please select a valid address');
      return;
    }
    if (_selectedLocation == null) {
      setState(() {
        addressError = true;
      });
      showErrorMessage(context, content: 'Please select an address');
      return;
    }

    if (_startDateTimeController == null) {
      showErrorMessage(context, title: 'Please select a time and date');
      return;
    }

    if (_endDateTimeController != null) { // check if the end date is before the start date
      final startDate = _startDateTimeController!.toDate();
      final endDate = _endDateTimeController!.toDate();
      if (endDate.isBefore(startDate)) { // check if the end date is before the start date
        showErrorMessage(context, title: 'The end date must be after the start date');
        return;
      }
    } else { // if end time is null then set it to +8 hours of the start time
      _endDateTimeController = Timestamp.fromDate(_startDateTimeController!.toDate().add(const Duration(hours: 8)));
    }

    if (tickets.isEmpty) {
      showErrorMessage(context, title: 'Please create at least one ticket');
      return;
    }
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    

    setState(() { _isLoading = true; }); // set the loading spinner to true
    

    if (uid == null) {
      showErrorMessage(context, content: 'There was an error loading your user, please logout and login again', errorAction: ErrorAction.logout);
      setState(() => _isLoading = false);
      return;
    }

    var userDocument = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    user = UserModel.fromDocumentSnapshot(userDocument);

    if (user == null) {
      showErrorMessage(context, content: 'There was an error loading your user, please logout and login again', errorAction: ErrorAction.logout);
      setState(() { _isLoading = false; });
      return;
    }
    if (user!.hostIdentityVerified == false) {
      showErrorMessage(context, content: 'Only verified users can post events', errorAction: ErrorAction.verify);
      setState(() { _isLoading = false; });
      return;
    }
    if (user!.stripeConnectedCustomerId == null) {
      showErrorMessage(context, content: 'You need to connect your Stripe account to post events', errorAction: ErrorAction.verify);
      setState(() { _isLoading = false; });
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
      setState(() { _isLoading = false; });
      return;
    }

    try {
      await eventRef.set({
        'title': _titleController.text,
        'photoPath': fileRef.fullPath,
        'description': _descriptionController.text,
        'location': _selectedLocation!.toMap(), // this is a helper function that converts the location to a map
        'startDateTime': _startDateTimeController,
        'endDateTime': _endDateTimeController,
        'tickets': tickets.map((ticket) => ticket.toMap()).toList(), // this will convert each ticket to a map and create a list with those maps
        'plus21': plus21,
        
        // Host variables
        'hostId': uid,
        'hostName': user!.name,
        'hostProfilePicPath': user!.profilePicPath,
        'stripeConnectedCustomerId': user!.stripeConnectedCustomerId,
      });


      // add the created event to the host list of events
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'createdEvents': FieldValue.arrayUnion([eventRef.id])
      });


      // Clear all controllers
      _titleController.clear();
      _descriptionController.clear();
      _photofile = null; // Clear the image file

      
      
      setState(() {
        _startDateTimeController = null;
        _endDateTimeController = null;
        _selectedLocation = null;
        eventRef = FirebaseFirestore.instance.collection('events').doc(); // generate a fresh ref for the *next* event
        tickets = [
          TicketModel(
            ticketID: 'firstTicket',
            eventID: eventRef.id,
            ticketName: 'General Admission',
            ticketPrice: 0.00,          
          )
        ];
        _dateTimeWidgetKey++;
        _adressWidgetKey++;
        addressError = false; // Clear the address error
        _isLoading = false; // set the loading spinner to false
      });
      
      
      // show a success message to the user
      showConfirmationMessage(context, message: 'Post created successfully');

    } catch (e) { // catch any errors that occur during the upload
      showErrorMessage(context, content: 'There was an error posting your event. Please try again');
      setState(() {
        _isLoading = false; // set the loading spinner to false
      });
    }
  }




  void newTicket({TicketModel? ticket}) async {
    debugPrint('New ticket function, ticket end time: ${ticket?.ticketEntryTimeEnd}');
    debugPrint('New ticket function, ticket title: ${ticket?.ticketName}');
    final TicketModel? newTicket = await showModalBottomSheet<TicketModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: backgroundColorBM,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (_) => TicketCreationScreen(ticket: ticket, eventID: eventRef.id,),
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
    eventRef = FirebaseFirestore.instance.collection('events').doc();
    tickets = [
      TicketModel(
        ticketID: 'firstTicket',
        eventID: eventRef.id,
        ticketName: 'General Admission',
        ticketPrice: 0.00,
      )
    ]; // this will be used to store the tickets created by the user


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
                      fillColor: Colors.white.withValues(alpha: 0.06),
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
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1), // Add white border
                          borderRadius: BorderRadius.circular(25), // Match the ClipRRect
                          image: _photofile == null
                              ? DecorationImage(
                                  image: AssetImage('assets/images/add_image_mountains_placeholder.png'),
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: MemoryImage(_photofile!),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        child: Center(
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
                      fillColor: Colors.white.withValues(alpha: 0.06),
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
      
                  SelectAddressBox(
                    key: ValueKey('address_$_adressWidgetKey'),
                    onAddressSelected: _onAddressSelected,
                    error: addressError,
                  ),
      
                  const SizedBox(height: 20),
      
                  // DATE TIME BUTTON   
                  SelectDateTime(
                    key: ValueKey('datetime_$_dateTimeWidgetKey'),
                    onDateChanged: _onDateTimeSelected,
                    dateTimeUse: DateTimeUse.event,
                  ),
      
                  const SizedBox(height: 20),

                  TicketsSection(tickets: tickets, newTicket: newTicket, removeTicket: removeTicket,), // this widget will show the tickets created by the user

                  const SizedBox(height: 20),

                  // PLUS 21 TOGGLE SECTION
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '+21 Only',
                          style: whiteBody.copyWith(
                            color: korazonColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                        Switch(
                          value: plus21,
                          activeTrackColor: korazonColor,
                          onChanged: (value) {
                            setState(() {
                              plus21 = value;
                            });
                          },
                          activeColor: Colors.white,
                          inactiveThumbColor: Colors.white70,
                          inactiveTrackColor: Colors.white38,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // POST EVENT BUTTON
                  GestureDetector(
                    onTap: postEvent,
                    child: Container(
                      width: double.infinity,
                      height: 75,
                      decoration: BoxDecoration(
                        gradient: linearGradient,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: _isLoading 
                      ? SpinKitThreeBounce(color: Colors.white, size: 30) // loading animation if the user clicks the post button
                      : Center(
                        child: Text(
                          'Post Event',
                          style: whiteSubtitle.copyWith(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          )
                        ),
                      ),
                    ),
                  ),
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
    _photofile = null;
    _descriptionController.dispose();
    _selectedLocation = null;
    _startDateTimeController = null;
    _endDateTimeController = null;
    tickets.clear();
    _isLoading = false;
    
    eventTitleFocousNode.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }
}