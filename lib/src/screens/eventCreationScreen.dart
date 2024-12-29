import 'package:flutter/material.dart';


class Eventcreationscreen extends StatefulWidget {
  const Eventcreationscreen({super.key});

  @override
  _EventcreationscreenState createState() => _EventcreationscreenState();
}


class _EventcreationscreenState extends State<Eventcreationscreen> {


  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();



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
              ],
            ),
          ),
        )
      ),
    );
  }
}