import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';

class Togglebutton extends StatefulWidget {
  final Function(bool) selectionNumber;

  const Togglebutton({super.key, required this.selectionNumber});

  @override
  State<Togglebutton> createState() => _TogglebuttonState();
}

class _TogglebuttonState extends State<Togglebutton> {
  List<bool> isSelected = [true, false];
  bool get isFirstSelected => isSelected[1]; //tells if the first element is selected

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      selectedColor: tertiaryColor,
      fillColor: secondaryColor,
      color: secondaryColor,
      borderWidth: primaryBorderWidth,
      selectedBorderColor: tertiaryColor,
      isSelected: isSelected,
      onPressed: (int index) {
        setState(() {
          for (int buttonIndex = 0;
              buttonIndex < isSelected.length;
              buttonIndex++) {
            if (buttonIndex == index) {
              isSelected[buttonIndex] = true;
            } else {
              isSelected[buttonIndex] = false;
            }
          }
        });
        widget.selectionNumber(isSelected[1]);
      },
      children: <Widget>[
        Text(
          'User',
          style: TextStyle(
            fontSize: primaryFontSize,
            fontWeight: primaryFontWeight,
          ),
        ),
        Text(
          'Host',
          style: TextStyle(
            fontSize: primaryFontSize,
            fontWeight: primaryFontWeight,
          ),
        ),
      ],
    );
  }
}
