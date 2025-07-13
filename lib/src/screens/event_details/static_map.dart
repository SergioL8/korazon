import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/loading_place_holders.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';




class StaticMap extends StatefulWidget {

  const StaticMap({
    super.key,
    required this.lat,
    required this.lon,
    required this.eventId,
    this.width = 300,
    this.height = 200,
  });

  final double? lat;
  final double? lon;
  final double width;
  final double height;
  final String eventId;

  @override
  State<StaticMap> createState() => _StaticMapState();
  
}

class _StaticMapState extends State<StaticMap> {

  bool _error = false;
  Uint8List? _mapBytes;

  Future<void> _openInNativeMaps() async {
    final lat = widget.lat;
    final lng = widget.lon;
    if (lat == null || lng == null) return;

    final googleUrl = 'google.navigation:q=$lat,$lng';
    final appleUrl  = 'maps://?q=$lat,$lng';
    final fallbackUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    String url;
    if (Platform.isAndroid) {
      debugPrint('Android device detected, using Google Maps URL');
      url = googleUrl;
    } else if (Platform.isIOS) {
      debugPrint('iOS device detected, using Apple Maps URL');
      url = appleUrl;
    } else {
      debugPrint('Unknown platform, using fallback URL');
      url = fallbackUrl;
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
      // last-ditch: open the web version
      await launchUrl(Uri.parse(fallbackUrl));
    } else {
      // do nothing if no URL can be launched
      debugPrint('Could not launch any map URL');
    }
  }

  Future<void> fetchStaticMap(double? lat, double? lon) async {

    if (lat == null || lon == null) {
      setState(() {
        _error = true;
      });
      return; // Return early if lat or lon is null
    }

    final cacheKey = 'staticMap_${lat}_${lon}_${widget.width}_${widget.height}_${widget.eventId}';
    final fileInfo = await DefaultCacheManager().getFileFromCache(cacheKey);

    if (fileInfo != null) {
      setState(() {
        _mapBytes = fileInfo.file.readAsBytesSync();
      });
      return; // Return early if the image is cached
    } else {
      // Fetch the static map image from the server
      final uri = Uri.https(
        'us-central1-korazon-dc77a.cloudfunctions.net',
        '/getStaticMapImage',
        {
          'lat': lat.toString(),
          'lng': lon.toString(),
          'zoom': '15',
          'width': widget.width.toInt().toString(),
          'height': widget.height.toInt().toString(),
        },
      );
      final resp = await http.get(uri);

      if (resp.statusCode == 200) {
        setState(() {
          _mapBytes = resp.bodyBytes;
        });
      } else {
        debugPrint('Error fetching static map: ${resp.statusCode}');
        debugPrint('Response body: ${resp.body}');
        setState(() {
          _error = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStaticMap(widget.lat, widget.lon);
  }

  @override
  Widget build(context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.0,
        )
        
      ),
      child: _error
        ? Center(
            child: Text(
              'There was an error loading the map. Please report the porblem, you can find the report button by scrolling down',
              style: whiteBody,
            ),
          )
        : _mapBytes == null
          ? LoadingImagePlaceHolder()
          : GestureDetector(
            onTap: _openInNativeMaps,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _mapBytes!,
                width: widget.width,
                height: widget.height,
                fit: BoxFit.cover,
              ),
            ),
          ),
    );
  }
}