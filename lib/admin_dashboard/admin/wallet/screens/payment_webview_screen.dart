import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebviewScreen extends StatefulWidget {
  final String paymentUrl;
  final String successUrlPrefix; // Used to detect successful payment
  final String failureUrlPrefix; // Used to detect failed payment

  const PaymentWebviewScreen({
    super.key,
    required this.paymentUrl,
    this.successUrlPrefix = 'success',
    this.failureUrlPrefix = 'failure',
  });

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            _checkUrlRedirection(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _checkUrlRedirection(url);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (_checkUrlRedirection(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  /// Checks if the URL matches the success or failure patterns
  /// Returns true if it handled a redirect, false otherwise.
  bool _checkUrlRedirection(String url) {
    if (url.toLowerCase().contains(widget.successUrlPrefix)) {
      Navigator.of(context).pop(true); // Return true for success
      return true;
    } else if (url.toLowerCase().contains(widget.failureUrlPrefix)) {
      Navigator.of(context).pop(false); // Return false for failure
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدفع'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
