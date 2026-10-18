import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/aba_payway_controller.dart';

class AbaPayWayView extends GetView<AbaPayWayController> {
  const AbaPayWayView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller.webViewController),
      drawerEdgeDragWidth: 100,
    );
  }
}
