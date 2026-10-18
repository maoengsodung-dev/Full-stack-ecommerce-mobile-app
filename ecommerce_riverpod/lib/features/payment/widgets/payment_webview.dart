import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../app/core/theme/app_colors.dart';

class PaymentWebView extends StatelessWidget {
  final WebViewController controller;
  final bool isLoading;

  const PaymentWebView({
    super.key,
    required this.controller,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
      ],
    );
  }
}
