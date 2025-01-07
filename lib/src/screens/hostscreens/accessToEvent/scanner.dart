import 'package:korazon/src/screens/hostscreens/accessToEvent/checkTheAccessToEvent.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';


class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, required this.eventID});
  final String eventID;

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}


class _ScannerScreenState extends State<ScannerScreen> {

  MobileScannerController controller = MobileScannerController();

  /// this function is used to display the bottom modal sheet that shows the info of a user when trying to access an event
  /// 
  /// this function includes some logic on how to avoid multiple modal bottom sheets from being displayed
  void _displayUserAccessToEvent(String guestID, String eventID) {

    controller.stop(); // stop the scanner so that no multiple modal bottom sheets are displayed

    showModalBottomSheet( // display the user access to event

      isScrollControlled: true,
      context: context,
      builder: (ctx) => CheckForAccessToEvent(guestID: guestID, eventID: eventID,)
      // code is the uid which allows us to access the document of the user in the widget 
      // UserAccessToEvent

    ).whenComplete(() => controller.start()); // when the modal bottom sheet is closed, start the scanner again
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code To Check In'),
      ),
      body: MobileScanner( // this is the scanner widget from the mobile_scanner package
        controller: controller, // the controller is used to start and stop the scanner

        onDetect: (BarcodeCapture barcodeCapture) { // function executed when a barcode is detected
          final String? guestID = barcodeCapture.barcodes.first.rawValue; // get the first barcode detected

          if (guestID != null) { 
            // if the barcode is not null, then display the user access to event
            _displayUserAccessToEvent(guestID, widget.eventID); // "code" is the uid given by the scanned QR code
          }
        }
      ),
    );
  }


  @override
  void dispose() {
    // Properly dispose of the controller when the screen is disposed
    controller.dispose();
    super.dispose();
  } 
}

