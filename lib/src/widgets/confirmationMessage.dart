import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/utils.dart';


void showConfirmationMessage(BuildContext context, {required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      padding: EdgeInsets.symmetric(vertical:MediaQuery.of(context).size.height * 0.02, horizontal: MediaQuery.of(context).size.width * 0.05),
      backgroundColor: tertiaryColor,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.favorite_sharp, 
            color: korazonColor,
            size: MediaQuery.of(context).size.height * 0.035,
          ),
          const SizedBox(width: 12,),
          Text(
            message,
            overflow: TextOverflow.clip,
            style: const TextStyle(
              fontSize: 18,
              color: secondaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          Spacer(),
          // InkWell(
          //   onTap: () => Navigator.of(context).pop(), 
          //   child: Container(
          //     width: 40,
          //     height: 40,
          //     decoration: BoxDecoration(
          //       color: korazonColor,
          //       borderRadius: BorderRadius.all(Radius.circular(20))
          //     ),
          //     child: Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
          //       child: Center(
          //         child: 
          //         Icon(
          //           Icons.close_rounded,
          //           color: Colors.white,
          //         )
          //         // Text(
          //         //   'Ok',
          //         //   style: TextStyle(
          //         //     color: Colors.white,
          //         //     fontSize: 17,
          //         //     fontWeight: FontWeight.w800,
          //         //   ),
          //         // ),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
      behavior: SnackBarBehavior.floating,  // This makes it float
      margin: const EdgeInsets.all(16),     // Add margins around it
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      showCloseIcon: true,
      closeIconColor: korazonColor,
      duration: Duration(seconds: 3),
      dismissDirection: DismissDirection.horizontal,
    ),
  );
}