import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:korazon/src/utilities/utils.dart';




class EventCreationScreen extends StatefulWidget {
  const EventCreationScreen({super.key});

  @override
  State<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Uint8List? _photofile;


  /// This function prompts the user a menu ("Dialog") for the user to select wheter the image 
  /// he is going to submit will come from the camera or the gallery
  /// 
  /// The result is that when the user has selected that image, it will now be a Uint8List 
  /// stored as _photofile


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.03),
            child: Column(
              children: [
                TextField(
                  style: TextStyle(
                    fontSize: 30,
                  ),
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                      fontSize: 40,
                    ),
                    labelText: 'Event Title',
                    ),
                  
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () => _selectImage(context),

                  // We will display a container if the image has not been selected otherwise
                  // we will display the image 

                  child: _photofile == null 
                  ? Container(
                    height: MediaQuery.of(context).size.height * 0.23,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color.fromARGB(255, 158, 158, 158),
                    ),
                    child: Center(
                      child: Icon(Icons.upload, size: 50, color: Colors.white),
                    ),
                  ): Container(
                    //TODO set a standard size compression
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.23,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: MemoryImage(
                                _photofile!)) //we have already selected it so we can assure it is not null
                        ),
                  ),
                ),                
                const SizedBox(height: 20),
                TextField(
                  minLines: 3,
                  maxLines: 5,
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description...',
                    alignLabelWithHint: true, // Aligns the label with the top of the text field
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _dateTimeController,
                  decoration: InputDecoration(
                    labelText: 'Date&Time',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                /* SizedBox( // necessary to size the column to a fixed height
                  height: 100,
                  child: Column(
                    children: [
                      Text('Age'),
                      Expanded( // necessary to make the wheel chooser take the full height of the column
                        child: WheelChooser.integer(
                          onValueChanged: (s) => _ageController = s,
                          initValue: 18,
                          minValue: 1,
                          maxValue: 99,
                          horizontal: true,
                        ),
                      ),
                    ],
                  ),
                ), */
                const SizedBox(height: 20),
                Container(
                  height: MediaQuery.of(context).size.height * 0.12,
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color.fromRGBO(250, 177, 177, 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            'Price',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        )
                      ),
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          controller: _priceController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // only allow digits and a decimal point
                          ],
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.black,
                            prefixIcon: Icon(Icons.attach_money),
                            prefixIconColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ]
            ),
          ),
        )
      ),
    );
  }
}