import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CustomPinInput extends StatelessWidget {
  final TextEditingController controller;
  final bool hasError;
  final bool useNumericKeyboard;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;

  const CustomPinInput({
    super.key,
    required this.controller,
    this.hasError = false,
    this.useNumericKeyboard = true,
    this.onCompleted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      controller: controller,
      keyboardType:
          useNumericKeyboard ? TextInputType.number : TextInputType.text,
      animationType: AnimationType.fade,
      textCapitalization: TextCapitalization.characters,
      enableActiveFill: true,
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) {
          return newValue.copyWith(text: newValue.text.toUpperCase());
        }),
        if (useNumericKeyboard)
          FilteringTextInputFormatter.allow(
              RegExp(r'[0-9]')), // limit to digits
      ],
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
      ),
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(10),
        borderWidth: 0,
        inactiveFillColor: Colors.white.withOpacity(0.15),
        activeFillColor: Colors.white.withOpacity(0.15),
        selectedFillColor: Colors.white.withOpacity(0.15),
        activeColor: hasError ? Colors.red : Colors.transparent,
        inactiveColor: hasError ? Colors.red : Colors.transparent,
        selectedColor: hasError ? Colors.red : Colors.transparent,
      ),
      onChanged: onChanged,
      onCompleted: onCompleted,
    );
  }
}
