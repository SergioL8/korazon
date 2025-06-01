import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';



Future<void> showRsvpConfirmation(
  BuildContext context,
  Future<void> Function() onSubmit,
) async {
  final dialogFuture = showDialog<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      backgroundColor: backgroundColorBM.withValues(alpha: 0.85),
      title: Text(
        'Complete Transaction',
        overflow: TextOverflow.clip,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Text(
              'The ticket you are trying to RSVP is free. '
              'By clicking "Pay \$0.00" you confirm your RSVP and agree to the event terms.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(korazonColor),
              shape: WidgetStatePropertyAll<OutlinedBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            onPressed: () async {
              await onSubmit();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Pay \$0.00',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  await dialogFuture; // Pause until “Continue” (or dialog dismiss)
}
