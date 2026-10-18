import 'package:architecture_getx/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onFacebookTap;
  final String dividerText;

  const SocialLoginButtons({
    super.key,
    this.onGoogleTap,
    this.onFacebookTap,
    this.dividerText = 'Or login with',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            const Expanded(
              child: Divider(color: AppColors.divider, thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                dividerText,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Expanded(
              child: Divider(color: AppColors.divider, thickness: 1),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Social buttons row
        Row(
          children: [
            // Google
            Expanded(
              child: _buildSocialButton(
                icon: const _GoogleLogo(size: 20),
                label: 'Google',
                onTap: onGoogleTap ?? () {},
              ),
            ),
            const SizedBox(width: 14),
            // Facebook
            Expanded(
              child: _buildSocialButton(
                icon: const _FacebookLogo(size: 20),
                label: 'facebook',
                onTap: onFacebookTap ?? () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.authFieldBorder, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Google Multi-Color "G" Icon
class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;
    final strokeWidth = w * 0.22;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Red Arc (top)
    canvas.drawArc(rect, -3.14 * 0.75, 3.14 * 0.55, false, redPaint);
    // Yellow Arc (left)
    canvas.drawArc(rect, -3.14 * 1.3, 3.14 * 0.55, false, yellowPaint);
    // Green Arc (bottom)
    canvas.drawArc(rect, 3.14 * 0.25, 3.14 * 0.55, false, greenPaint);
    // Blue Arc (right)
    canvas.drawArc(rect, -0.2, 3.14 * 0.5, false, bluePaint);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final barRect = Rect.fromLTWH(w * 0.45, h * 0.40, w * 0.52, strokeWidth);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(2)),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Facebook Logo Icon
class _FacebookLogo extends StatelessWidget {
  final double size;
  const _FacebookLogo({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'f',
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: size * 0.75,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
      ),
    );
  }
}
