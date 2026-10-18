import 'dart:async';

import 'package:dart_payway/dart_payway.dart';
import 'package:flutter/material.dart' hide debugPrint;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/constant.dart';
import '../../../data/models/order.model.dart';
import '../../../data/repository/order_repository.dart';
import '../../../routes/app_pages.dart';
import '../../cart/controllers/cart_controller.dart';

class AbaPayWayController extends GetxController {
  // ============================================================
  // PAYWAY SERVICE
  // ============================================================

  late final PaywayTransactionService service;
  late final WebViewController webViewController;

  // ============================================================
  // ANDROID METHOD CHANNEL
  // ============================================================

  static const MethodChannel _abaChannel = MethodChannel('aba_payway');

  // ============================================================
  // OBSERVABLES
  // ============================================================

  final isLoading = true.obs;
  final isVerifying = false.obs;
  final isPaid = false.obs;
  final errorMessage = ''.obs;
  final currentTranId = ''.obs;
  final pageTitle = 'ABA PayWay'.obs;

  // ============================================================
  // ARGUMENTS
  // ============================================================

  double amountUsd = 0.0;

  List<PaywayTransactionItem> items = [];

  int? addressId;

  String? notes;

  String firstname = 'Customer';
  String lastname = 'Name';
  String email = 'customer@example.com';
  String phone = '012000000';

  // ============================================================
  // POLLING
  // ============================================================

  Timer? _pollingTimer;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    // 1. Initialize PayWay service
    service = PaywayTransactionService(
      merchant: PaywayMerchant(
        merchantID: kMerchantID,
        merchantApiName: kMerchantName,
        merchantApiKey: kMerchantApiKey,
        baseApiUrl: kBaseUrl,
        refererDomain: kRefererDomain,
      ),
    );

    // 2. Read arguments passed from Checkout
    _parseArguments();

    // 3. Initialize WebView
    _initWebViewController();

    // 4. Create and load PayWay transaction
    createTransaction();
  }

  // ============================================================
  // PARSE ARGUMENTS
  // ============================================================

  void _parseArguments() {
    final args = Get.arguments;

    if (args is Map) {
      amountUsd =
          (args['price'] as num?)?.toDouble() ??
          (args['total'] as num?)?.toDouble() ??
          0.0;

      if (args['title'] != null) {
        pageTitle.value = args['title'].toString();
      }

      addressId = args['addressId'] as int?;
      notes = args['notes'] as String?;

      if (args['firstname'] != null) {
        firstname = args['firstname'].toString();
      }

      if (args['lastname'] != null) {
        lastname = args['lastname'].toString();
      }

      if (args['email'] != null) {
        email = args['email'].toString();
      }

      if (args['phone'] != null) {
        phone = args['phone'].toString();
      }

      if (args['items'] is List<PaywayTransactionItem>) {
        items = List<PaywayTransactionItem>.from(args['items']);
      }
    } else if (args is num) {
      amountUsd = args.toDouble();
    }
  }

  // ============================================================
  // WEBVIEW
  // ============================================================

  void _initWebViewController() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          // ----------------------------------------------------
          // PAGE STARTED
          // ----------------------------------------------------
          onPageStarted: (url) {
            debugPrint('ABA PayWay onPageStarted: $url');

            // PayWay return URL
            if (url.startsWith(kReturnUrl)) {
              checkPaymentStatus();
            }
          },

          // ----------------------------------------------------
          // PAGE FINISHED
          // ----------------------------------------------------
          onPageFinished: (url) {
            debugPrint('ABA PayWay onPageFinished: $url');

            isLoading.value = false;
          },

          // ----------------------------------------------------
          // WEB RESOURCE ERROR
          // ----------------------------------------------------
          onWebResourceError: (error) {
            debugPrint('ABA PayWay WebResourceError:');

            debugPrint('Description: ${error.description}');

            debugPrint('Error Code: ${error.errorCode}');

            debugPrint('URL: ${error.url}');

            // IMPORTANT:
            // We do NOT launch intent:// here.
            //
            // intent:// is handled in onNavigationRequest
            // BEFORE WebView attempts to load it.
          },

          // ----------------------------------------------------
          // NAVIGATION REQUEST
          // ----------------------------------------------------
          onNavigationRequest: (request) async {
            final url = request.url;

            debugPrint('ABA PayWay onNavigationRequest: $url');

            // ==================================================
            // 1. PAYWAY RETURN URL
            // ==================================================

            if (url.startsWith(kReturnUrl)) {
              debugPrint('PayWay return URL detected.');

              await checkPaymentStatus();

              return NavigationDecision.prevent;
            }

            // ==================================================
            // 2. ANDROID INTENT:// URL
            // ==================================================

            //
            // Your screenshot shows:
            //
            // intent://ababank.com?type=payway&qrcode=...
            //
            // WebView cannot load intent:// directly.
            //

            if (url.startsWith('intent://')) {
              debugPrint('ABA Android Intent detected:');
              debugPrint(url);
              await _openAndroidIntent(url);
              return NavigationDecision.prevent;
            }

            // ==================================================
            // 3. ABA MOBILE / BAKONG CUSTOM SCHEMES
            // ==================================================

            final uri = Uri.tryParse(url);

            if (uri != null) {
              final scheme = uri.scheme.toLowerCase();

              debugPrint('Detected URL scheme: $scheme');

              if (scheme == 'abamobilebank' ||
                  scheme == 'abamobile' ||
                  scheme == 'ababank' ||
                  scheme == 'bakong') {
                debugPrint('ABA/Bakong custom scheme detected:');
                debugPrint(url);
                await _openExternalUrl(url);
                return NavigationDecision.prevent;
              }
            }

            // ==================================================
            // 4. ABA PAYWAY UNIVERSAL LINKS
            // ==================================================

            if (url.contains('link.payway.com.kh')) {
              debugPrint('ABA PayWay Universal Link detected: $url');
              await _openExternalUrl(url);
              return NavigationDecision.prevent;
            }

            // ==================================================
            // 5. NORMAL HTTP / HTTPS
            // ==================================================

            return NavigationDecision.navigate;
          },
        ),
      );
  }

  // ============================================================
  // OPEN ANDROID INTENT
  // ============================================================

  Future<void> _openAndroidIntent(String url) async {
    try {
      debugPrint('Sending intent to Android: $url');
      final result = await _abaChannel.invokeMethod('openIntent', {'url': url});
      debugPrint('Android Intent result: $result');

      if (result == false) {
        Get.snackbar(
          'ABA Mobile',
          'ABA Mobile is not installed on this device. You can scan the KHQR code to pay.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E293B),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } on PlatformException catch (e) {
      debugPrint('Android Intent PlatformException: ${e.message}');
      await _fallbackLaunchIntent(url);
    } catch (e) {
      debugPrint('Could not open Android Intent: $e');
      await _fallbackLaunchIntent(url);
    }
  }

  Future<void> _fallbackLaunchIntent(String url) async {
    try {
      String? deepLink;
      final schemeMatch = RegExp(r'scheme=([^;]+)').firstMatch(url);
      if (schemeMatch != null) {
        final scheme = schemeMatch.group(1);
        final cleanUrl = url
            .replaceFirst('intent://', '')
            .split('#Intent')
            .first;
        deepLink = '$scheme://$cleanUrl';
      }

      if (deepLink != null) {
        final uri = Uri.tryParse(deepLink);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      }

      Get.snackbar(
        'ABA Mobile',
        'ABA Mobile may not be installed. Please scan the KHQR code to pay.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      debugPrint('Fallback launch error: $e');
      Get.snackbar(
        'ABA Mobile',
        'Could not open ABA Mobile. Please scan the KHQR code to pay.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ============================================================
  // OPEN EXTERNAL CUSTOM URL
  // ============================================================

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      debugPrint('Invalid external URL: $url');
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        debugPrint(
          'Could not open external URL directly, trying native channel: $url',
        );
        final result = await _abaChannel.invokeMethod('openIntent', {
          'url': url,
        });
        if (result != true) {
          Get.snackbar(
            'ABA Mobile',
            'ABA Mobile may not be installed. Please scan the KHQR code to pay.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF1E293B),
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      debugPrint('Could not open external URL $url: $e');
      try {
        final result = await _abaChannel.invokeMethod('openIntent', {
          'url': url,
        });
        if (result != true) {
          Get.snackbar(
            'ABA Mobile',
            'ABA Mobile may not be installed. Please scan the KHQR code to pay.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF1E293B),
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        }
      } catch (err) {
        debugPrint('Native channel invocation error: $err');
        Get.snackbar(
          'ABA Mobile',
          'ABA Mobile may not be installed. Please scan the KHQR code to pay.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E293B),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  // ============================================================
  // HOSTED VIEW
  // ============================================================

  /// PayWay hosted_view for native app WebViews.
  ///
  /// This makes the PayWay checkout display correctly
  /// inside the Flutter WebView.
  static const _hostedViewInput =
      '<input type="hidden" '
      'name="view_type" '
      'value="hosted_view" '
      'id="view_type" />';

  Uri _checkoutUriWithHostedView(Uri uri) {
    final html = uri.data?.contentAsString();

    if (html == null || html.contains('name="view_type"')) {
      return uri;
    }

    return Uri.dataFromString(
      html.replaceFirst(
        '<input type="hidden" name="payment_gate"',
        '$_hostedViewInput'
            '<input type="hidden" name="payment_gate"',
      ),
      mimeType: 'text/html',
    );
  }

  // ============================================================
  // CREATE PAYWAY TRANSACTION
  // ============================================================

  Future<void> createTransaction() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // --------------------------------------------------------
      // Generate transaction ID
      // --------------------------------------------------------

      final tranId = service.uniqueTranID();

      currentTranId.value = tranId;

      debugPrint('PayWay Tran ID: $tranId');

      // --------------------------------------------------------
      // Source items
      // --------------------------------------------------------

      final List<PaywayTransactionItem> sourceItems = items.isNotEmpty
          ? items
          : [
              PaywayTransactionItem(
                name: 'Order Payment',
                price: amountUsd > 0 ? amountUsd : 1.0,
                quantity: 1,
              ),
            ];

      // --------------------------------------------------------
      // Convert USD -> KHR
      // --------------------------------------------------------

      final khrItems = sourceItems
          .map((item) => item.copyWith(price: (item.price).roundToDouble()))
          .toList();

      // --------------------------------------------------------
      // Calculate KHR amount
      // --------------------------------------------------------

      final khrAmount = khrItems.fold<double>(
        0.0,
        (sum, item) => sum + item.price * item.quantity,
      );

      debugPrint('USD amount: $amountUsd');

      debugPrint('KHR amount: $khrAmount');

      // --------------------------------------------------------
      // Create transaction
      // --------------------------------------------------------

      final transaction = PaywayCreateTransaction(
        tranId: tranId,

        reqTime: service.uniqueReqTime(),

        amount: khrAmount,

        items: khrItems,

        firstname: firstname,

        lastname: lastname,

        email: email,

        phone: phone,

        shipping: 0.0,

        // KHQR / ABA PayWay Deeplink
        option: PaywayPaymentOption.abapay_khqr_deeplink,

        // Keep your existing currency configuration
        currency: PaywayTransactionCurrency.USD,

        returnUrl: kReturnUrl,
      );

      // --------------------------------------------------------
      // Generate PayWay Checkout URL
      // --------------------------------------------------------

      final checkoutUri = await service.generateTransactionCheckoutURI(
        transaction: transaction,
      );

      debugPrint('Generated PayWay Checkout URI:');

      debugPrint(checkoutUri.toString());

      // --------------------------------------------------------
      // Load PayWay checkout
      // --------------------------------------------------------

      await webViewController.loadRequest(
        _checkoutUriWithHostedView(checkoutUri),
      );

      // --------------------------------------------------------
      // Start payment polling
      // --------------------------------------------------------

      _startPolling();
    } catch (e) {
      debugPrint('Error creating transaction: $e');

      errorMessage.value = 'Failed to initialize ABA PayWay: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // START POLLING
  // ============================================================

  void _startPolling() {
    _pollingTimer?.cancel();

    debugPrint('Starting PayWay payment polling...');

    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      // Stop polling if payment is successful
      if (isPaid.value || isClosed) {
        _pollingTimer?.cancel();

        debugPrint('Payment polling stopped.');

        return;
      }

      await checkPaymentStatus(silent: true);
    });
  }

  // ============================================================
  // CHECK PAYMENT STATUS
  // ============================================================

  Future<void> checkPaymentStatus({bool silent = false}) async {
    if (isPaid.value || currentTranId.value.isEmpty) {
      return;
    }

    if (isVerifying.value && silent) {
      return;
    }

    try {
      if (!silent) {
        isVerifying.value = true;
      }

      debugPrint('Checking PayWay transaction...');

      debugPrint('Tran ID: ${currentTranId.value}');

      final result = await service.checkTransaction(
        transaction: PaywayCheckTransaction(
          tranId: currentTranId.value,

          reqTime: service.uniqueReqTime(),
        ),
      );

      debugPrint('PayWay checkTransaction result:');

      debugPrint('Status: ${result.status}');

      debugPrint('Payment Status: ${result.paymentStatus}');

      // --------------------------------------------------------
      // Payment success
      // --------------------------------------------------------

      final paymentStatus = result.paymentStatus.toUpperCase();

      final isSuccess =
          result.status == 0 ||
          paymentStatus == 'APPROVED' ||
          paymentStatus == 'COMPLETED' ||
          paymentStatus == 'SUCCESS';

      if (isSuccess) {
        debugPrint('PAYMENT SUCCESS');

        isPaid.value = true;

        _pollingTimer?.cancel();

        await _onPaymentSuccess();
      }
      // --------------------------------------------------------
      // Still pending
      // --------------------------------------------------------
      else if (!silent) {
        Get.snackbar(
          'Payment Status',
          'Payment is still pending. '
              'Please scan or complete the transaction '
              'in ABA Mobile.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E293B),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('Error checking transaction: $e');

      if (!silent) {
        Get.snackbar(
          'Verification Error',
          'Could not check payment status: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } finally {
      if (!silent) {
        isVerifying.value = false;
      }
    }
  }

  // ============================================================
  // PAYMENT SUCCESS
  // ============================================================

  Future<void> _onPaymentSuccess() async {
    debugPrint('Processing successful payment...');

    Get.snackbar(
      'Payment Successful!',
      'Your payment has been received and verified.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );

    OrderRes? createdOrder;

    // ----------------------------------------------------------
    // Place order
    // ----------------------------------------------------------

    if (addressId != null && Get.isRegistered<OrderRepository>()) {
      try {
        final orderRepo = Get.find<OrderRepository>();

        createdOrder = await orderRepo.placeOrder(
          addressId: addressId!,
          notes: notes,
        );
      } catch (e) {
        debugPrint('Failed to auto-place order after payment: $e');
      }
    }

    // ----------------------------------------------------------
    // Clear cart on successful order
    // ----------------------------------------------------------

    if (Get.isRegistered<CartController>()) {
      await Get.find<CartController>().clearCart();
    }

    // ----------------------------------------------------------
    // Navigate to success screen
    // ----------------------------------------------------------

    await Future.delayed(const Duration(milliseconds: 600));

    Get.offNamed(
      Routes.ORDER_SUCCESS,
      arguments: {'order': createdOrder, 'paymentMethod': 'ABA PayWay (KHQR)'},
    );
  }

  // ============================================================
  // CLOSE
  // ============================================================

  @override
  void onClose() {
    _pollingTimer?.cancel();

    super.onClose();
  }
}
