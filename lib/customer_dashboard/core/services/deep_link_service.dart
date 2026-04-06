import 'dart:async';
import 'dart:developer' as developer;
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';

/// Deep Link Service for handling payment callbacks
/// 
/// Uses app_links package for modern deep linking support
/// Handles both: app opened via link + cold start with link
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // Callbacks for payment results
  void Function()? onPaymentSuccess;
  void Function()? onPaymentFailed;
  void Function()? onPaymentPending;

  /// Initialize deep link handling
  Future<void> init({
    void Function()? onSuccess,
    void Function()? onFailed,
    void Function()? onPending,
  }) async {
    onPaymentSuccess = onSuccess;
    onPaymentFailed = onFailed;
    onPaymentPending = onPending;

    // Handle cold start (app launched from link)
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        developer.log(
          'DeepLinkService - Cold start with link: $initialUri',
          name: 'DeepLinkService',
        );
        _handleDeepLink(initialUri);
      }
    } on PlatformException catch (e) {
      developer.log(
        'DeepLinkService - Failed to get initial link: $e',
        name: 'DeepLinkService',
        level: 1000,
      );
    }

    // Handle app opened via link while running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        developer.log(
          'DeepLinkService - Link received: $uri',
          name: 'DeepLinkService',
        );
        _handleDeepLink(uri);
      },
      onError: (err) {
        developer.log(
          'DeepLinkService - Link stream error: $err',
          name: 'DeepLinkService',
          level: 1000,
        );
      },
    );

    developer.log(
      'DeepLinkService - Initialized successfully',
      name: 'DeepLinkService',
    );
  }

  /// Handle incoming deep link
  void _handleDeepLink(Uri uri) {
    developer.log(
      'DeepLinkService - Handling deep link: $uri',
      name: 'DeepLinkService',
    );

    // Check scheme
    if (uri.scheme != 'myapp') {
      developer.log(
        'DeepLinkService - Unknown scheme: ${uri.scheme}',
        name: 'DeepLinkService',
      );
      return;
    }

    // Handle based on host
    switch (uri.host) {
      case 'payment-success':
        developer.log(
          'DeepLinkService - Payment success detected',
          name: 'DeepLinkService',
        );
        onPaymentSuccess?.call();
        break;
      case 'payment-failed':
        developer.log(
          'DeepLinkService - Payment failed detected',
          name: 'DeepLinkService',
        );
        onPaymentFailed?.call();
        break;
      case 'payment-pending':
        developer.log(
          'DeepLinkService - Payment pending detected',
          name: 'DeepLinkService',
        );
        onPaymentPending?.call();
        break;
      default:
        developer.log(
          'DeepLinkService - Unknown host: ${uri.host}',
          name: 'DeepLinkService',
        );
    }
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
    onPaymentSuccess = null;
    onPaymentFailed = null;
    onPaymentPending = null;
  }
}
