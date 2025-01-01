import 'package:flutter/material.dart';

class HostAnalytics extends StatefulWidget {
  const HostAnalytics({super.key});

  @override
  State<HostAnalytics> createState() => _HostAnalyticsState();
}

class _HostAnalyticsState extends State<HostAnalytics> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Here will be displayed the info on how your current events are doing'),
    );
  }
}