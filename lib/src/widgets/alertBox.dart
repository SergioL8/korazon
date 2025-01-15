import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';


void showErrorMessage(BuildContext context, {String title = 'Something went wrong...', String content = ''}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Icon(Icons.heart_broken, color: korazonColor),
          const SizedBox(width: 8,),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontSize: 20,
                color: secondaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      content: content == '' ? null 
      : Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          color: secondaryColor,
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: [
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(korazonColor),
            shape: WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            )),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Close',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}