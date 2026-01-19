import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A compass widget that displays the Qibla direction with a rotating arrow.
///
/// The compass shows a circular dial with cardinal directions (N, E, S, W)
/// and a prominent arrow that rotates to indicate the Qibla direction relative
/// to the device's current orientation.
class QiblaCompass extends StatelessWidget {
  /// The angle in degrees to rotate the Qibla arrow (0-360).
  ///
  /// A value of 0 means the arrow points upward (toward Qibla when the device
  /// is pointing north). The arrow rotates clockwise as the angle increases.
  final double qiblaAngle;

  /// Creates a new Qibla compass widget.
  ///
  /// Parameters:
  /// - [qiblaAngle]: The angle to rotate the Qibla arrow in degrees (0-360)
  /// - [key]: Optional widget key
  const QiblaCompass({
    required this.qiblaAngle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Compass rose with cardinal directions
          CustomPaint(
            size: const Size(300, 300),
            painter: _CompassRosePainter(),
          ),
          // Qibla arrow that rotates based on device orientation
          Transform.rotate(
            angle: _degreesToRadians(qiblaAngle),
            child: CustomPaint(
              size: const Size(300, 300),
              painter: _QiblaArrowPainter(),
            ),
          ),
        ],
      ),
    );
  }

  /// Converts degrees to radians.
  ///
  /// Transform.rotate uses radians, but our Qibla angle is in degrees.
  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}

/// Custom painter for drawing the compass rose background.
///
/// Draws a circular dial with tick marks and cardinal direction labels
/// (N, E, S, W) to provide orientation reference.
class _CompassRosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw outer circle
    final circlePaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius, circlePaint);

    // Draw inner circle
    final innerCirclePaint = Paint()
      ..color = Colors.grey[100]!
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius * 0.9, innerCirclePaint);

    // Draw tick marks and cardinal directions
    _drawTickMarks(canvas, center, radius);
    _drawCardinalDirections(canvas, center, radius);
  }

  /// Draws tick marks around the compass rose.
  ///
  /// Major tick marks are drawn at 45-degree intervals with cardinal directions
  /// emphasized, and minor tick marks at 15-degree intervals.
  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 2
      ..isAntiAlias = true;

    // Draw major and minor tick marks
    for (int i = 0; i < 360; i += 15) {
      final angle = i * math.pi / 180;
      final isMajor = i % 90 == 0;
      final isMedium = i % 45 == 0;

      final outerRadius = radius - 5;
      final innerRadius = isMajor
          ? radius - 25
          : isMedium
              ? radius - 18
              : radius - 12;

      final x1 = center.dx + outerRadius * math.cos(angle);
      final y1 = center.dy + outerRadius * math.sin(angle);
      final x2 = center.dx + innerRadius * math.cos(angle);
      final y2 = center.dy + innerRadius * math.sin(angle);

      tickPaint.strokeWidth = isMajor ? 3 : (isMedium ? 2 : 1);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }
  }

  /// Draws cardinal direction labels (N, E, S, W) on the compass.
  ///
  /// Labels are positioned at 0°, 90°, 180°, and 270° with north emphasized.
  void _drawCardinalDirections(Canvas canvas, Offset center, double radius) {
    final textStyle = TextStyle(
      color: Colors.grey[800],
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    // Cardinal directions: N, E, S, W
    final directions = [
      {'label': 'N', 'angle': 0},
      {'label': 'E', 'angle': 90},
      {'label': 'S', 'angle': 180},
      {'label': 'W', 'angle': 270},
    ];

    for (final direction in directions) {
      final angle = direction['angle']! as int;
      final label = direction['label']! as String;

      final radians = angle * math.pi / 180;
      final labelRadius = radius - 45;
      final x = center.dx + labelRadius * math.cos(radians);
      final y = center.dy + labelRadius * math.sin(radians);

      final textPainter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Emphasize North direction
      if (label == 'N') {
        final northStyle = TextStyle(
          color: Colors.deepPurple,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        );
        textPainter.text = TextSpan(text: label, style: northStyle);
        textPainter.layout();
      }

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for drawing the Qibla direction arrow.
///
/// Draws a prominent arrow that points toward the Qibla direction.
/// The arrow is styled with a gradient and shadow for visual emphasis.
class _QiblaArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final arrowLength = size.width * 0.35;
    final arrowWidth = size.width * 0.15;

    // Define arrow path pointing upward
    final path = Path()
      ..moveTo(center.dx, center.dy - arrowLength) // Tip
      ..lineTo(center.dx + arrowWidth / 2, center.dy) // Right edge
      ..lineTo(center.dx + arrowWidth / 4, center.dy) // Inner right
      ..lineTo(center.dx + arrowWidth / 4, center.dy + arrowLength * 0.3)
      ..lineTo(center.dx - arrowWidth / 4, center.dy + arrowLength * 0.3)
      ..lineTo(center.dx - arrowWidth / 4, center.dy) // Inner left
      ..lineTo(center.dx - arrowWidth / 2, center.dy) // Left edge
      ..close();

    // Draw arrow shadow
    final shadowPaint = Paint()
      ..color = Colors.black26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.save();
    canvas.translate(3, 3);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Draw arrow with gradient
    final rect = Rect.fromCircle(center: center, radius: arrowLength);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.deepPurple[400]!,
        Colors.deepPurple[600]!,
        Colors.deepPurple[800]!,
      ],
    );

    final arrowPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(path, arrowPaint);

    // Draw arrow outline
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..isAntiAlias = true;
    canvas.drawPath(path, outlinePaint);

    // Draw center circle (Kaaba indicator)
    final centerCirclePaint = Paint()
      ..color = Colors.amber[400]!
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(center, 8, centerCirclePaint);

    final centerCircleOutline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..isAntiAlias = true;
    canvas.drawCircle(center, 8, centerCircleOutline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
