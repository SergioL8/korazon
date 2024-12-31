import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';


/// Compresses the image to reduce the size
/// 
/// Parameters: [image] image to be compressed and [quality] integer between 0 and 100 to set the quality of the image
/// 
/// Output: Compressed image as Uint8List
Future<Uint8List> compressImage(Uint8List image, int quality) async {
    final result = await FlutterImageCompress.compressWithList(
      image,
      minHeight: 720,
      minWidth: 720,
      quality: quality,
      rotate: 0,
    );

    return result;
  }