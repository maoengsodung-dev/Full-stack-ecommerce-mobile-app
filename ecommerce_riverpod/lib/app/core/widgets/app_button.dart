import 'package:flutter/material.dart';

import '../theme/app_colors.dart';


enum ButtonType { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final Widget? icon;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.icon,
    this.width = double.infinity,
    this.height = 52,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(14);

    Widget childWidget;
    if (isLoading) {
      childWidget = SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.outline || type == ButtonType.text
                ? AppColors.primary
                : Colors.white,
          ),
        ),
      );
    } else if (icon != null) {
      childWidget = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      );
    } else {
      childWidget = Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      );
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ??
          (type == ButtonType.primary
              ? AppColors.primary
              : (type == ButtonType.secondary
                  ? AppColors.primary
                  : Colors.transparent)),
      foregroundColor: textColor ??
          (type == ButtonType.outline || type == ButtonType.text
              ? AppColors.primary
              : Colors.white),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: effectiveRadius,
        side: type == ButtonType.outline
            ? BorderSide(color: backgroundColor ?? AppColors.primary, width: 1.5)
            : BorderSide.none,
      ),
    );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: childWidget,
      ),
    );
  }
}
