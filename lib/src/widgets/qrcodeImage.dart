import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'dart:convert';



class QrCodeImage extends StatefulWidget {
  QrCodeImage({super.key, required this.user, required this.onQrCodeUpdated});

  final UserModel user;
  final ValueChanged<String> onQrCodeUpdated;

  @override
  State<QrCodeImage> createState() => _QrCodeImageState();
}

class _QrCodeImageState extends State<QrCodeImage> {

  bool _qrCodeLoading = false;
  late String qrCodeBase64;

  @override
  void initState() {
    super.initState();
    qrCodeBase64 = widget.user.qrCode;
  }
  

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15, top: 60, right: 60, left: 60),
          child: qrCodeBase64 == ''
          ? const Text('Error fetching QR Code')
          : Image.memory(
              base64Decode(qrCodeBase64.split(',')[1]),
              fit: BoxFit.contain,
          ),
        ),
        // const SizedBox(height: 20,),
          ElevatedButton(
            style: ButtonStyle(
              padding: WidgetStatePropertyAll(EdgeInsets.zero),
              fixedSize: WidgetStatePropertyAll(Size(200, 20)),
              backgroundColor: WidgetStatePropertyAll<Color>(korazonColor),
              shape: WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              )),
            ),
            
            onPressed: () async {
              if (_qrCodeLoading == true) { return; } // avoid multiple classs

              _qrCodeLoading = true;

              final temp = await createQRCode(widget.user.userID);

              if (temp == null) {
                showErrorMessage(context, content: "QR code couldn't be generated. Please try again.");
                return;
              }

              setState(() {
                qrCodeBase64 = temp;
              });

              // Notify the parent so it can setState, too
              widget.onQrCodeUpdated.call(temp);

              await FirebaseFirestore.instance.collection('users').doc(widget.user.userID).update({
                'qrCode': temp,
              });

              _qrCodeLoading = false;

            },
            child: Text(
              'Regenerate QR code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}