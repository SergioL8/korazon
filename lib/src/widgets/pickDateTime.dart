import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


/// This function is used to select a date and time from the user. It uses the default date and time picker
/// of flutter, to select the date and time as one single widget.
/// 
/// Input: BuildContext context
/// 
/// Output: Future<String?>, the formatted date and time picked by the user
Future<String?> selectDateTime(BuildContext context) async {
  
  TimeOfDay? timePicked; // variable declaration
  
  final DateTime? datePicked = await showDatePicker( // use the default date picker of flutter
    context: context,
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(Duration(days: 365 * 2)),
  );


  if (datePicked != null) { // only show the time picker once the data has been picked
    timePicked = await showTimePicker( // use the default time picker of flutter
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  if (timePicked != null) { // if the time has been picked then we have all the data we need
    final DateTime dateTime = DateTime( // concatenate the date and time picked
      datePicked!.year,
      datePicked.month,
      datePicked.day,
      timePicked.hour,
      timePicked.minute,
    );

    if (dateTime.isBefore(DateTime.now())) { // check if the date and time picked is before the current date and time
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Day or time are before now.')), // in the future use the alert box
      );
      return null; // return null if the date and time picked is before the current date and time
    }

    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime); // return the formatted date and time

  }
  return null;
}