import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final bool showBackButton;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if (showBackButton) ...[
          //   GestureDetector(
          //     onTap: onBack ??
          //         () {
          //           if (Navigator.of(context).canPop()) {
          //             Get.back();
          //           }
          //         },
          //     child: Container(
          //       width: 42,
          //       height: 42,
          //       decoration: const BoxDecoration(
          //         color: Colors.white,
          //         shape: BoxShape.circle,
          //         boxShadow: [
          //           BoxShadow(
          //             color: Color(0x1A000000),
          //             blurRadius: 8,
          //             offset: Offset(0, 2),
          //           ),
          //         ],
          //       ),
          //       child: const Icon(
          //         Icons.arrow_back,
          //         color: Color(0xFF1E1B4B),
          //         size: 20,
          //       ),
          //     ),
          //   ),
          //   const SizedBox(height: 20),
          // ] else
          //   const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
