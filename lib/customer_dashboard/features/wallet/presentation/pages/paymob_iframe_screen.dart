import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymobIframeScreen extends StatefulWidget {
  final String paymentUrl;
  final int? integrationId; // kept for API compatibility, not used in old-style tokens

  const PaymobIframeScreen({
    super.key,
    required this.paymentUrl,
    this.integrationId,
  });

  @override
  State<PaymobIframeScreen> createState() => _PaymobIframeScreenState();
}

class _PaymobIframeScreenState extends State<PaymobIframeScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Mobile) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/120.0.6099.144 Mobile Safari/537.36',
      )
      ..addJavaScriptChannel(
        'PaymobResult',
        onMessageReceived: (JavaScriptMessage message) {
          final msg = message.message.toLowerCase();
          if (msg.contains('"success":true') || msg.contains('success=true')) {
            if (mounted) Navigator.pop(context, true);
          } else if (msg.contains('"success":false') ||
              msg.contains('success=false')) {
            if (mounted) Navigator.pop(context, false);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);

            // Inject listener for postMessage from the Paymob iframe
            _controller.runJavaScript(r'''
              (function() {
                if (window.__pm_injected) return;
                window.__pm_injected = true;
                window.addEventListener('message', function(e) {
                  try {
                    var d = typeof e.data === 'string' ? e.data : JSON.stringify(e.data);
                    if (d) PaymobResult.postMessage(d);
                  } catch(_) {}
                }, false);
              })();
            ''');
          },
          onNavigationRequest: (NavigationRequest req) {
            final url = req.url;

            if (url.contains('transaction_response') ||
                url.contains('success=true') ||
                url.startsWith('myapp://payment-success')) {
              if (mounted) Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }
            if (url.contains('success=false') ||
                url.contains('is_voided=true') ||
                url.startsWith('myapp://payment-failed')) {
              if (mounted) Navigator.pop(context, false);
              return NavigationDecision.prevent;
            }
            if (url.startsWith('myapp://payment-pending')) {
              if (mounted) Navigator.pop(context, null);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    _loadPaymob();
  }

  void _loadPaymob() {
    final url = widget.paymentUrl;

    if (url.contains('/iframes/')) {
      // Old-style Paymob token — MUST be wrapped in an <iframe> HTML page.
      // Loading the URL directly causes "must have iframe owner" error.
      // We fake the origin to accept.paymob.com so Paymob's iframe owner check passes.
      _controller.loadHtmlString(
        _buildHtml(url),
        baseUrl: 'https://accept.paymob.com',
      );
    } else {
      // New-style token (Intention API / Unified Checkout)
      _controller.loadRequest(Uri.parse(url));
    }
  }

  String _buildHtml(String iframeUrl) => '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      background: #fff;
    }
    iframe {
      position: absolute;
      top: 0; left: 0;
      width: 100%;
      height: 100%;
      border: none;
      overflow: hidden;
    }
  </style>
</head>
<body>
  <iframe
    src="$iframeUrl"
    allow="payment *; camera *; microphone *; clipboard-write *"
    allowfullscreen
    scrolling="yes"
    frameborder="0"
  ></iframe>
  <script>
    window.addEventListener('message', function(e) {
      try {
        var d = typeof e.data === 'string' ? e.data : JSON.stringify(e.data);
        if (d) PaymobResult.postMessage(d);
      } catch(_) {}
    }, false);
  </script>
</body>
</html>
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('إتمام الدفع'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'جارٍ تحميل صفحة الدفع...',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
