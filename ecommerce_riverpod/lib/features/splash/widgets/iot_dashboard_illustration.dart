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

    _drawCitySkyline(canvas, size);
    _drawOrbitsAndNodes(canvas, center, w);
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

    canvas.drawLine(Offset(0, baseY), Offset(w, baseY), linePaint);

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

    _drawTree(canvas, 20, baseY, 14, linePaint);
    _drawTree(canvas, 80, baseY, 10, linePaint);

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
    final rect = Rect.fromLTWH(x, y, width, height);
    canvas.drawRect(rect, borderPaint);

    if (withSpire) {
      canvas.drawLine(
        Offset(x + width / 2, y),
        Offset(x + width / 2, y - 12),
        borderPaint,
      );
      canvas.drawCircle(Offset(x + width / 2, y - 12), 1.5, borderPaint);
    }

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
    canvas.drawLine(Offset(x, baseY), Offset(x, baseY - radius), paint);
    canvas.drawCircle(Offset(x, baseY - radius * 1.5), radius * 0.7, paint);
  }

  void _drawOrbitsAndNodes(Canvas canvas, Offset center, double w) {
    final ringPaint = Paint()
      ..color = const Color(0xFFC7CBD6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = const Color(0xFF5352EC)
      ..style = PaintingStyle.fill;

    final nodeGlowPaint = Paint()
      ..color = const Color(0xFF5352EC).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final r1 = w * 0.42;
    canvas.drawCircle(center, r1, ringPaint);

    final r2 = w * 0.32;
    canvas.drawCircle(center, r2, ringPaint);

    final angles1 = [
      -math.pi * 0.65,
      -math.pi * 0.15,
      math.pi * 0.60,
    ];

    for (final angle in angles1) {
      final pos = Offset(
        center.dx + r1 * math.cos(angle),
        center.dy + r1 * math.sin(angle),
      );
      canvas.drawCircle(pos, 4.5, nodePaint);
      canvas.drawCircle(pos, 7.5 + 2 * pulseValue, nodeGlowPaint);
    }

    final angles2 = [
      -math.pi * 0.35,
      math.pi * 0.85,
      math.pi * 0.30,
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

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final deviceBorderPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final innerScreenPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final outerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: deviceSize, height: deviceSize),
      const Radius.circular(12),
    );

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

    canvas.drawRRect(antennaRRect, fillPaint);
    canvas.drawRRect(antennaRRect, deviceBorderPaint);

    canvas.drawRRect(outerRect, fillPaint);
    canvas.drawRRect(outerRect, deviceBorderPaint);

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

    final ledX =
        center.dx + (deviceSize / 2) - innerPadding - deviceSize * 0.14;
    final ledY =
        center.dy + (deviceSize / 2) - innerPadding - deviceSize * 0.14;
    final ledCenter = Offset(ledX, ledY);

    final greenGlowPaint = Paint()
      ..color = const Color(0xFF22C55E).withValues(alpha: 0.35 + (0.25 * pulseValue))
      ..style = PaintingStyle.fill;

    final greenLedPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(ledCenter, 9.0 + (3.0 * pulseValue), greenGlowPaint);
    canvas.drawCircle(ledCenter, 6.0, greenLedPaint);
  }

  @override
  bool shouldRepaint(covariant _IotIllustrationPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue;
  }
}
