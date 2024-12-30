import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wheel_chooser/wheel_chooser.dart';




class Eventcreationscreen extends StatefulWidget {
  const Eventcreationscreen({super.key});

  @override
  _EventcreationscreenState createState() => _EventcreationscreenState();
}


class _EventcreationscreenState extends State<Eventcreationscreen> {


  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();



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
                    fontSize: 40,
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
                  onTap: () {print('Upload Image');},
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.23,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color.fromARGB(255, 158, 158, 158),
                    ),
                    child: Center(
                      child: Icon(Icons.upload, size: 50, color: Colors.white),
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
                SizedBox( // necessary to size the column to a fixed height
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
                ),
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