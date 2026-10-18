import 'package:dart_payway/dart_payway.dart';
import 'package:flutter/material.dart' hide debugPrint;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';


import '../../../app/core/constants/api_constants.dart';
import '../../../app/core/router/route_names.dart';
import '../../../app/core/theme/app_colors.dart';
import '../providers/payment_provider.dart';
import '../widgets/payment_webview.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? arguments;

  const PaymentPage({super.key, this.arguments});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  static const MethodChannel _abaChannel = MethodChannel('aba_payway');
  late final WebViewController _webViewController;
  double _amount = 0.0;
  int? _addressId;
  String? _notes;
  String _firstname = 'Customer';
  String _lastname = 'Name';
  String _email = 'customer@example.com';
  String _phone = '012000000';

  @override
  void initState() {
    super.initState();
    _parseArguments();
    _initWebView();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createAndLoadTransaction();
    });
  }

  @override
  void dispose() {
    ref.read(paymentNotifierProvider.notifier).stopPolling();
    super.dispose();
  }

  void _parseArguments() {
    final args = widget.arguments;
    if (args != null) {
      _amount = (args['price'] as num?)?.toDouble() ??
          (args['total'] as num?)?.toDouble() ??
          0.0;
      _addressId = args['addressId'] as int?;
      _notes = args['notes'] as String?;
      if (args['firstname'] != null) _firstname = args['firstname'].toString();
      if (args['lastname'] != null) _lastname = args['lastname'].toString();
      if (args['email'] != null) _email = args['email'].toString();
      if (args['phone'] != null) _phone = args['phone'].toString();
    }
  }

  void _initWebView() {
    final notifier = ref.read(paymentNotifierProvider.notifier);

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (url.startsWith(kReturnUrl)) {
              notifier.checkPaymentStatus(addressId: _addressId, notes: _notes);
            }
          },
          onPageFinished: (_) {
            notifier.setLoading(false);
          },
          onNavigationRequest: (request) async {
            final url = request.url;

            if (url.startsWith(kReturnUrl)) {
              await notifier.checkPaymentStatus(
                addressId: _addressId,
                notes: _notes,
              );
              return NavigationDecision.prevent;
            }

            if (url.startsWith('intent://')) {
              await _openAndroidIntent(url);
              return NavigationDecision.prevent;
            }

            final uri = Uri.tryParse(url);
            if (uri != null) {
              final scheme = uri.scheme.toLowerCase();
              if (['abamobilebank', 'abamobile', 'ababank', 'bakong']
                  .contains(scheme)) {
                await _openExternalUrl(url);
                return NavigationDecision.prevent;
              }
            }

            if (url.contains('link.payway.com.kh')) {
              await _openExternalUrl(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );
  }

  Future<void> _openAndroidIntent(String url) async {
    try {
      final result = await _abaChannel.invokeMethod('openIntent', {'url': url});
      if (result != true) {
        await _openExternalUrl(url);
      }
    } catch (_) {
      await _openExternalUrl(url);
    }
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Uri _checkoutUriWithHostedView(Uri uri) {
    final html = uri.data?.contentAsString();
    if (html == null || html.contains('name="view_type"')) {
      return uri;
    }
    const hostedViewInput =
        '<input type="hidden" name="view_type" value="hosted_view" id="view_type" />';
    return Uri.dataFromString(
      html.replaceFirst(
        '<input type="hidden" name="payment_gate"',
        '$hostedViewInput<input type="hidden" name="payment_gate"',
      ),
      mimeType: 'text/html',
    );
  }

  Future<void> _createAndLoadTransaction() async {
    final notifier = ref.read(paymentNotifierProvider.notifier);
    notifier.setLoading(true);

    try {
      final tranId = notifier.service.uniqueTranID();
      notifier.setTranId(tranId);

      final transaction = PaywayCreateTransaction(
        tranId: tranId,
        reqTime: notifier.service.uniqueReqTime(),
        amount: _amount > 0 ? _amount : 1.0,
        items: [
          PaywayTransactionItem(
            name: 'Order Payment',
            price: _amount > 0 ? _amount : 1.0,
            quantity: 1,
          ),
        ],
        firstname: _firstname.isNotEmpty ? _firstname : 'Customer',
        lastname: _lastname,
        email: _email,
        phone: _phone.isNotEmpty ? _phone : '012000000',
        shipping: 0.0,
        option: PaywayPaymentOption.abapay_khqr_deeplink,
        currency: PaywayTransactionCurrency.USD,
        returnUrl: kReturnUrl,
      );

      final checkoutUri = await notifier.service.generateTransactionCheckoutURI(
        transaction: transaction,
      );
      final finalUri = _checkoutUriWithHostedView(checkoutUri);
      await _webViewController.loadRequest(finalUri);

      notifier.startPolling(addressId: _addressId, notes: _notes);
    } catch (e) {
      notifier.setLoading(false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment initialization error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentNotifierProvider);

    ref.listen<PaymentState>(paymentNotifierProvider, (previous, next) {
      if (next.isPaid && !(previous?.isPaid ?? false)) {
        Navigator.of(context).pushReplacementNamed(
          RouteNames.orderSuccess,
          arguments: {
            'order': next.placedOrder,
            'paymentMethod': 'ABA PayWay',
          },
        );
      }
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          state.pageTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: PaymentWebView(
          controller: _webViewController,
          isLoading: state.isLoading,
        ),
      ),
    );
  }
}
