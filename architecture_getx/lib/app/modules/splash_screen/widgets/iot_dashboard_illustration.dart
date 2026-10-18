import 'dart:math' as math;
import 'package:flutter/material.dart';

class IotDashboardIllustration extends StatefulWidget {
  final double size;

  const IotDashboardIllustration({super.key, this.size = 280});

  @override
  State<IotDashboardIllustration> createState() =>
      _IotDashboardIllustrationState();
}

class _IotDashboardIllustrationState extends State<IotDashboardIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _IotIllustrationPainter(
              pulseValue: _pulseController.value,
            ),
          ),
        );
      },
    );
  }
}

class _IotIllustrationPainter extends CustomPainter {
  final double pulseValue;

  _IotIllustrationPainter({required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Draw City Skyline in the background
    _drawCitySkyline(canvas, size);

    // 2. Draw Concentric Orbital Rings & Accent Nodes
    _drawOrbitsAndNodes(canvas, center, w);

    // 3. Draw Center IoT Hub Device with Antenna and Green LED
    _drawIotDevice(canvas, center, w);
  }

  void _drawCitySkyline(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final baseY = h * 0.72;

    final linePaint = Paint()
      ..color = const Color(0xFFD8DDE6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final windowPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Ground line
    canvas.drawLine(Offset(0, baseY), Offset(w, baseY), linePaint);

    // Buildings on Left side
    _drawBuilding(canvas, 10, baseY - 55, 30, 55, linePaint, windowPaint);
    _drawBuilding(
      canvas,
      42,
      baseY - 80,
      24,
      80,
      linePaint,
      windowPaint,
      withSpire: true,
    );
    _drawBuilding(canvas, 68, baseY - 45, 26, 45, linePaint, windowPaint);

    // Outline Tree / Nature on left
    _drawTree(canvas, 20, baseY, 14, linePaint);
    _drawTree(canvas, 80, baseY, 10, linePaint);

    // Buildings on Right side
    _drawBuilding(canvas, w - 95, baseY - 65, 25, 65, linePaint, windowPaint);
    _drawBuilding(
      canvas,
      w - 68,
      baseY - 90,
      28,
      90,
      linePaint,
      windowPaint,
      withSpire: true,
    );
    _drawBuilding(canvas, w - 38, baseY - 50, 30, 50, linePaint, windowPaint);

    // Outline Tree on right
    _drawTree(canvas, w - 85, baseY, 12, linePaint);
  }

  void _drawBuilding(
    Canvas canvas,
    double x,
    double y,
    double width,
    double height,
    Paint borderPaint,
    Paint windowPaint, {
    bool withSpire = false,
  }) {
    // Building outline
    final rect = Rect.fromLTWH(x, y, width, height);
    canvas.drawRect(rect, borderPaint);

    // Spire / Antenna on top of tall building
    if (withSpire) {
      canvas.drawLine(
        Offset(x + width / 2, y),
        Offset(x + width / 2, y - 12),
        borderPaint,
      );
      canvas.drawCircle(Offset(x + width / 2, y - 12), 1.5, borderPaint);
    }

    // Windows pattern (dashed grid)
    final rows = (height / 10).floor() - 1;
    final cols = (width / 7).floor();
    for (int r = 1; r <= rows; r++) {
      for (int c = 1; c <= cols; c++) {
        final wx = x + (c * (width / (cols + 1)));
        final wy = y + (r * 10.0);
        canvas.drawLine(
          Offset(wx - 1.5, wy),
          Offset(wx + 1.5, wy),
          windowPaint,
        );
      }
    }
  }

  void _drawTree(
    Canvas canvas,
    double x,
    double baseY,
    double radius,
    Paint paint,
  ) {
    // Tree trunk
    canvas.drawLine(Offset(x, baseY), Offset(x, baseY - radius), paint);
    // Tree foliage circle
    canvas.drawCircle(Offset(x, baseY - radius * 1.5), radius * 0.7, paint);
  }

  void _drawOrbitsAndNodes(Canvas canvas, Offset center, double w) {
    final ringPaint = Paint()
      ..color = const Color(0xFFC7CBD6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color =
          const Color(0xFF5352EC) // Primary Purple/Indigo
      ..style = PaintingStyle.fill;

    final nodeGlowPaint = Paint()
      ..color = const Color(0xFF5352EC).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    // Outer Orbit Ring 1 (Radius ~ 42% of width)
    final r1 = w * 0.42;
    canvas.drawCircle(center, r1, ringPaint);

    // Outer Orbit Ring 2 (Radius ~ 32% of width)
    final r2 = w * 0.32;
    canvas.drawCircle(center, r2, ringPaint);

    // Orbital Nodes on Ring 1
    final angles1 = [
      -math.pi * 0.65, // Top-left node
      -math.pi * 0.15, // Top-right node
      math.pi * 0.60, // Bottom-left node
    ];

    for (final angle in angles1) {
      final pos = Offset(
        center.dx + r1 * math.cos(angle),
        center.dy + r1 * math.sin(angle),
      );
      canvas.drawCircle(pos, 4.5, nodePaint);
      canvas.drawCircle(pos, 7.5 + 2 * pulseValue, nodeGlowPaint);
    }

    // Orbital Nodes on Ring 2
    final angles2 = [
      -math.pi * 0.35, // Upper-right node
      math.pi * 0.85, // Mid-left node
      math.pi * 0.30, // Lower-right node
    ];

    for (final angle in angles2) {
      final pos = Offset(
        center.dx + r2 * math.cos(angle),
        center.dy + r2 * math.sin(angle),
      );
      canvas.drawCircle(pos, 4.0, nodePaint);
    }
  }

  void _drawIotDevice(Canvas canvas, Offset center, double w) {
    final deviceSize = w * 0.34;
    final halfDevice = deviceSize / 2;

    // Device Background fill (white card to obscure background skyline)
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Outer device stroke
    final deviceBorderPaint = Paint()
      ..color =
          const Color(0xFF64748B) // Slate grey
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    // Inner screen stroke
    final innerScreenPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final outerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: deviceSize, height: deviceSize),
      const Radius.circular(12),
    );

    // Antenna on top-left of device
    final antennaX = center.dx - halfDevice + deviceSize * 0.18;
    final antennaY = center.dy - halfDevice;
    final antennaWidth = deviceSize * 0.12;
    final antennaHeight = deviceSize * 0.22;

    final antennaRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        antennaX,
        antennaY - antennaHeight,
        antennaWidth,
        antennaHeight + 4,
      ),
      const Radius.circular(4),
    );

    // Draw antenna
    canvas.drawRRect(antennaRRect, fillPaint);
    canvas.drawRRect(antennaRRect, deviceBorderPaint);

    // Draw outer device body
    canvas.drawRRect(outerRect, fillPaint);
    canvas.drawRRect(outerRect, deviceBorderPaint);

    // Draw inner display screen
    final innerPadding = deviceSize * 0.15;
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: deviceSize - (innerPadding * 2),
        height: deviceSize - (innerPadding * 2),
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(innerRect, innerScreenPaint);

    // Glowing Neon Green LED indicator in the bottom-right corner of inner screen
    final ledX =
        center.dx + (deviceSize / 2) - innerPadding - deviceSize * 0.14;
    final ledY =
        center.dy + (deviceSize / 2) - innerPadding - deviceSize * 0.14;
    final ledCenter = Offset(ledX, ledY);

    final greenGlowPaint = Paint()
      ..color = const Color(
        0xFF22C55E,
      ).withValues(alpha: 0.35 + (0.25 * pulseValue))
      ..style = PaintingStyle.fill;

    final greenLedPaint = Paint()
      ..color =
          const Color(0xFF10B981) // Vibrant emerald green
      ..style = PaintingStyle.fill;

    // Outer glow
    canvas.drawCircle(ledCenter, 9.0 + (3.0 * pulseValue), greenGlowPaint);
    // Core LED dot
    canvas.drawCircle(ledCenter, 6.0, greenLedPaint);
  }

  @override
  bool shouldRepaint(covariant _IotIllustrationPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue;
  }
}
