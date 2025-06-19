import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';



class QrCodeImage extends StatefulWidget {
  QrCodeImage({super.key, required this.user, required this.profilePic, required this.onQrCodeUpdated});

  final UserModel user;
  final ValueChanged<String> onQrCodeUpdated;
  final Uint8List? profilePic;

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      height: 660,
      child: Stack(
        children: [
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            height: 500,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: linearGradient,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: widget.profilePic != null
                    ? MemoryImage(widget.profilePic!)
                    : const AssetImage('assets/images/no_profile_picture_place_holder.png') as ImageProvider,
              ),
              const SizedBox(height: 15, width: double.infinity,),
              Text(
                "${widget.user.name} ${widget.user.lastName}",
                style: whiteBody.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black
                ),
              ),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Image.memory(
                  // width: MediaQuery.of(context).size.width * 0.70,
                  base64Decode(qrCodeBase64.split(',')[1]),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 10,),
              IconButton(
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
                icon: FaIcon(
                  FontAwesomeIcons.rotate,
                  size: 35,
                  color: Colors.black,
                )
              ),
              Text(
                'Regenerate QR code',
                style: whiteBody.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black
                ),
              )
            ],
          ),
        ]
      ),
    );
  }
}