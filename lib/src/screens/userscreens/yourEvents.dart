import 'package:flutter/material.dart';

class YourEvents extends StatefulWidget {
  const YourEvents({super.key});

  @override
  State<YourEvents> createState() => _YourEventsState();
}

class _YourEventsState extends State<YourEvents> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Here will be your QR Code and events'),
    );
  }
}