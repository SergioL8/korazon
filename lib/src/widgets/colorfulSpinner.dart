import 'dart:math';
import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';

class ColorfulSpinner extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final int speed;

  const ColorfulSpinner({
    super.key,
    this.size = 80,
    this.strokeWidth = 5,
    this.speed = 1000,
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
      duration: Duration(milliseconds: widget.speed), // Faster spin
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

    // Length of the arc (covers 80% of the circle)
    final sweepAngle = 0.8 * 2 * pi;

    // Rotating start position
    final startAngle = rotationValue * 2 * pi + pi / 2;

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
        stops: [0.0, 0.35, 0.8, 1.0], // Defines the gradient blending
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