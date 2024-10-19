import 'package:flutter/material.dart';
import 'design_variables.dart';

showSnackBar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: Text(
          text,
          style: TextStyle(
            color: tertiaryColor,
            fontSize: primaryFontSize,
          ),
        ),
      ),
      backgroundColor: secondaryColor,
      elevation: 100,
      padding: EdgeInsets.symmetric(vertical: 20),
    ),
  );
}