import 'dart:math';
import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';

class ColorfulSpinner extends StatefulWidget {
  final double size;
  final double strokeWidth;

  const ColorfulSpinner({
    super.key,
    this.size = 80,
    this.strokeWidth = 8,
  });

  @override
  _ColorfulSpinnerState createState() => _ColorfulSpinnerState();
}

class _ColorfulSpinnerState extends State<ColorfulSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Faster spin
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: SpinnerPainter(
            rotationValue: _controller.value,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SpinnerPainter extends CustomPainter {
  final double rotationValue;
  final double strokeWidth;

  SpinnerPainter({
    required this.rotationValue,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;

    // Base arc length (80% of a full circle)
    final baseSweepAngle = 0.8 * 2 * pi;

    // Make the arc length dynamically change over time
    //final lengthVariation = 0.15 * 2 * pi * sin(rotationValue * 2 * pi * 2);
    final sweepAngle = baseSweepAngle; //l+ lengthVariation;

    // Rotating start position
    final startAngle = rotationValue * 2 * pi + pi / 2;

    // Dynamic stops for the gradient
    double minStop = 0.0; // Always starts at the beginning
    double midStop = 0.3 + 0.2 * sin(rotationValue * 2 * pi * 2); // Expands and shrinks
    double maxStop = 0.75 + 0.1 * sin(rotationValue * 2 * pi * 2); // Changes with rotation

    // Sweep gradient to align colors dynamically with the arc
    final gradientPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: [
          Colors.black, // Tail (start of arc)
          korazonColor, // Transition color
          Color.fromARGB(255, 103, 132, 224), // Head (end of arc)
          Colors.transparent, // Invisible tail for smooth fade-out
        ],
        stops: [minStop, midStop, maxStop, 1.0], // Dynamically changing stops
        transform: GradientRotation(startAngle), // Sync with rotation
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Draw the animated arc with the gradient
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SpinnerPainter oldDelegate) {
    return oldDelegate.rotationValue != rotationValue;
  }
}

