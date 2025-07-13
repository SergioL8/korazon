import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget LoadingImagePlaceHolder() {
  return Shimmer.fromColors(
    baseColor: const Color.fromARGB(255, 84, 84, 84), // Alpha used to be 82
    highlightColor: const Color.fromARGB(255, 124, 124, 124),
    child: Container(
      color: const Color.fromARGB(255, 84, 84, 84),
    ),
  );
}


Widget LoadingTextPlaceHolder({height = 30}) {
  return Shimmer.fromColors(
    baseColor: const Color.fromARGB(82, 94, 94, 94),
    highlightColor: const Color.fromARGB(82, 154, 154, 154),
    child: Container(
      height: height.toDouble(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(82, 94, 94, 94),
      ),
    ),
  );
}