import 'package:flutter/material.dart';



class AlertBox extends StatelessWidget {
  const AlertBox({super.key, this.title = 'Something went wrong...', this.content});
  final String? title;
  final String? content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alert'),
      content: const Text('This is an alert box'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}