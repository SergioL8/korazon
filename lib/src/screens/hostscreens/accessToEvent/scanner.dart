import 'package:korazon/src/screens/hostscreens/accessToEvent/checkTheAccessToEvent.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, required this.eventID, required this.eventTitle, required this.eventDateAndTime});
  final String eventID;
  final String? eventTitle;
  final DateTime? eventDateAndTime;

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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      context: context,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height,
        width: MediaQuery.of(ctx).size.width,
        child: CheckForAccessToEvent(
          guestID: guestID,
          eventID: eventID,
        ),
      ),
      
      // code is the uid which allows us to access the document of the user in the widget 
      // UserAccessToEvent

    ).whenComplete(() => controller.start()); // when the modal bottom sheet is closed, start the scanner again
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          MobileScanner( // this is the scanner widget from the mobile_scanner package
            controller: controller, // the controller is used to start and stop the scanner
            onDetect: (BarcodeCapture barcodeCapture) { // function executed when a barcode is detected
              final String? parts = barcodeCapture.barcodes.first.rawValue; // get the first barcode detected
              debugPrint('Barcode found: $parts'); // print the barcode to the console
              if (parts != null) { 
                final guestID = parts.split(',')[0];
                // if the barcode is not null, then display the user access to event
                _displayUserAccessToEvent(guestID, widget.eventID); // "code" is the uid given by the scanned QR code
              }
            }
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8, // 8 px below notch
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.grey[700],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => linearGradient.createShader(bounds),
                        child:  Text(
                          'Korazon',
                          style: whiteBody.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        widget.eventTitle ?? 'No event title',
                        style: whiteBody.copyWith(fontSize: 14),
                      ),
                      if (widget.eventDateAndTime != null)
                        Text(
                          '${DateFormat('EEE').format(widget.eventDateAndTime!)}'
                          ', ${DateFormat('MMM').format(widget.eventDateAndTime!).toUpperCase()}'
                          ' ${DateFormat('d').format(widget.eventDateAndTime!)}, '
                          '${DateFormat('h:mm a').format(widget.eventDateAndTime!)}',
                          style: whiteBody.copyWith(fontSize: 12),
                        ),
                    ],
                  )
                  
                ],
              )
            ),
          ),
        ]
        
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
