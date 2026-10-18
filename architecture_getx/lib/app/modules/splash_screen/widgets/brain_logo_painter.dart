import 'dart:math' as math;
import 'package:flutter/material.dart';

class BrainLogo extends StatefulWidget {
  final double size;
  final Color color;
  final bool animate;

  const BrainLogo({
    super.key,
    this.size = 140,
    this.color = Colors.white,
    this.animate = true,
  });

  @override
  State<BrainLogo> createState() => _BrainLogoState();
}

class _BrainLogoState extends State<BrainLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.06)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animate ? _pulseAnimation.value : 1.0,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _BrainLogoPainter(
                color: widget.color,
                animationValue: _controller.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BrainLogoPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  _BrainLogoPainter({
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width * 0.5;

    // Draw Left Hemisphere: Neural Network nodes & connecting branches
    _drawLeftHemisphere(canvas, size, centerX);

    // Draw Right Hemisphere: Stylized organic brain gyri/sulci folds
    _drawRightHemisphere(canvas, size, centerX);
  }

  void _drawLeftHemisphere(Canvas canvas, Size size, double centerX) {
    final w = size.width;
    final h = size.height;

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.95)
      ..strokeWidth = w * 0.024
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final nodePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Normalized relative coordinates for nodes on the left hemisphere
    // Form a distinct left brain profile (frontal, parietal, occipital, temporal)
    final nodes = <Offset>[
      Offset(centerX - w * 0.08, h * 0.18), // N0: Top medial
      Offset(centerX - w * 0.24, h * 0.20), // N1: Top anterior
      Offset(centerX - w * 0.38, h * 0.32), // N2: Frontal upper
      Offset(centerX - w * 0.45, h * 0.46), // N3: Frontal mid-lateral
      Offset(centerX - w * 0.39, h * 0.60), // N4: Temporal outer
      Offset(centerX - w * 0.35, h * 0.74), // N5: Temporal lower
      Offset(centerX - w * 0.20, h * 0.82), // N6: Occipital / base lower
      Offset(centerX - w * 0.08, h * 0.78), // N7: Base medial
      Offset(centerX - w * 0.20, h * 0.42), // N8: Core inner 1
      Offset(centerX - w * 0.18, h * 0.60), // N9: Core inner 2
      Offset(centerX - w * 0.06, h * 0.46), // N10: Center-fissure node
    ];

    // Node radius scale
    final radii = <double>[
      w * 0.032, // N0
      w * 0.038, // N1
      w * 0.040, // N2
      w * 0.046, // N3
      w * 0.038, // N4
      w * 0.042, // N5
      w * 0.036, // N6
      w * 0.038, // N7
      w * 0.046, // N8
      w * 0.040, // N9
      w * 0.032, // N10
    ];

    // Connecting lines between network nodes
    final connections = <List<int>>[
      [0, 1],
      [1, 2],
      [2, 3],
      [3, 4],
      [4, 5],
      [5, 6],
      [6, 7],
      [0, 8],
      [1, 8],
      [2, 8],
      [3, 8],
      [3, 9],
      [4, 9],
      [5, 9],
      [6, 9],
      [7, 9],
      [8, 10],
      [9, 10],
      [0, 10],
      [7, 10],
    ];

    for (final conn in connections) {
      final p1 = nodes[conn[0]];
      final p2 = nodes[conn[1]];
      canvas.drawLine(p1, p2, linePaint);
    }

    // Draw node circles with subtle pulse effect
    for (int i = 0; i < nodes.length; i++) {
      final pos = nodes[i];
      final r = radii[i];
      final nodePulse = 1.0 + 0.08 * math.sin(animationValue * 2 * math.pi + i);

      // Node outer glow for key anchor points
      if (i == 3 || i == 8 || i == 5) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, r * 1.5 * nodePulse, glowPaint);
      }

      canvas.drawCircle(pos, r * nodePulse, nodePaint);
    }
  }

  void _drawRightHemisphere(Canvas canvas, Size size, double centerX) {
    final w = size.width;
    final h = size.height;

    final foldPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = w * 0.048;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Organic folds of the right hemisphere:
    // Path 1: Top cranial crest & frontal lobe fold
    final path1 = Path();
    path1.moveTo(centerX + w * 0.08, h * 0.18);
    path1.cubicTo(
      centerX + w * 0.22, h * 0.16,
      centerX + w * 0.38, h * 0.22,
      centerX + w * 0.42, h * 0.34,
    );
    path1.cubicTo(
      centerX + w * 0.44, h * 0.40,
      centerX + w * 0.34, h * 0.42,
      centerX + w * 0.24, h * 0.36,
    );
    canvas.drawPath(path1, foldPaint);

    // Path 2: Mid-lateral parietal & inner loop fold
    final path2 = Path();
    path2.moveTo(centerX + w * 0.44, h * 0.44);
    path2.cubicTo(
      centerX + w * 0.46, h * 0.52,
      centerX + w * 0.42, h * 0.60,
      centerX + w * 0.34, h * 0.60,
    );
    path2.cubicTo(
      centerX + w * 0.24, h * 0.60,
      centerX + w * 0.20, h * 0.50,
      centerX + w * 0.30, h * 0.48,
    );
    canvas.drawPath(path2, foldPaint);

    // Path 3: Temporal lobe & lower curve
    final path3 = Path();
    path3.moveTo(centerX + w * 0.40, h * 0.66);
    path3.cubicTo(
      centerX + w * 0.38, h * 0.76,
      centerX + w * 0.28, h * 0.82,
      centerX + w * 0.16, h * 0.82,
    );
    path3.cubicTo(
      centerX + w * 0.10, h * 0.82,
      centerX + w * 0.08, h * 0.74,
      centerX + w * 0.14, h * 0.68,
    );
    canvas.drawPath(path3, foldPaint);

    // Path 4: Medial vertical organic gyri
    final path4 = Path();
    path4.moveTo(centerX + w * 0.10, h * 0.30);
    path4.cubicTo(
      centerX + w * 0.14, h * 0.38,
      centerX + w * 0.14, h * 0.48,
      centerX + w * 0.10, h * 0.56,
    );
    canvas.drawPath(path4, foldPaint);

    // Small organic accent pods / lobes
    canvas.drawCircle(Offset(centerX + w * 0.22, h * 0.28), w * 0.026, fillPaint);
    canvas.drawCircle(Offset(centerX + w * 0.30, h * 0.72), w * 0.024, fillPaint);
    canvas.drawCircle(Offset(centerX + w * 0.16, h * 0.48), w * 0.022, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _BrainLogoPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color;
  }
}
