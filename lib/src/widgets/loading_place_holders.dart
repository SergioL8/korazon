import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget LoadingImagePlaceHolder() {
  return Shimmer.fromColors(
    baseColor: const Color.fromARGB(82, 94, 94, 94),
    highlightColor: const Color.fromARGB(82, 154, 154, 154),
    child: Container(
      color: const Color.fromARGB(82, 94, 94, 94),
    ),
  );
}


Widget LoadingTextlaceHolder() {
  return Shimmer.fromColors(
    baseColor: const Color.fromARGB(82, 94, 94, 94),
    highlightColor: const Color.fromARGB(82, 154, 154, 154),
    child: Container(
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(82, 94, 94, 94),
      ),
    ),
  );
}