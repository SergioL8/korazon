import 'package:korazon/src/screens/hostscreens/userAccessToEvent.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';


class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}


class _ScannerScreenState extends State<ScannerScreen> {

  MobileScannerController controller = MobileScannerController();

  // this function is used to display the bottom modal sheet that shows the info of a user when trying to access an event
  // this function includes some logic on how to avoid multiple modal bottom sheets from being displayed
  void _displayUserAccessToEvent(String code) {

    controller.stop(); // stop the scanner so that no multiple modal bottom sheets are displayed

    showModalBottomSheet( // display the user access to event
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => SafeArea(child: UserAccessToEvent(code: code,))
      // code is the uid which allows us to access the document of the user in the widget 
      // UserAccessToEvent

    ).whenComplete(() => controller.start()); // when the modal bottom sheet is closed, start the scanner again
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        controller: controller,
        onDetect: (BarcodeCapture barcodeCapture) {
          final String? code = barcodeCapture.barcodes.first.rawValue;
           // this method returns the detected barcode
          if (code != null) { 
            // if the barcode is not null, then display the user access to event
            _displayUserAccessToEvent(code);
            // code is the uid given by the scanned QR code
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

