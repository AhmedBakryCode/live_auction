import 'package:flutter/material.dart';

/// Payment Result Screen - Shows success or failure UI
class PaymentResultScreen extends StatelessWidget {
  final bool isSuccess;
  final String? message;
  final VoidCallback? onContinue;
  final VoidCallback? onRetry;

  const PaymentResultScreen({
    super.key,
    required this.isSuccess,
    this.message,
    this.onContinue,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        onContinue?.call();
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Icon
                  _buildAnimatedIcon(),
                  const SizedBox(height: 32),
                  
                  // Title
                  Text(
                    isSuccess ? 'تم الدفع بنجاح!' : 'فشل الدفع',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isSuccess ? Colors.green[700] : Colors.red[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Message
                  Text(
                    message ?? _getDefaultMessage(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Action Buttons
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green[50] : Colors.red[50],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          size: 72,
          color: isSuccess ? Colors.green[500] : Colors.red[500],
        ),
      ),
    );
  }

  String _getDefaultMessage() {
    if (isSuccess) {
      return 'تمت عملية الدفع بنجاح.\nشكراً لاستخدامك تطبيقنا!';
    } else {
      return 'لم يتم إتمام عملية الدفع.\nيمكنك المحاولة مرة أخرى.';
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              onContinue?.call();
              Navigator.pop(context);
            },
            icon: Icon(isSuccess ? Icons.home : Icons.arrow_back),
            label: Text(
              isSuccess ? 'العودة للرئيسية' : 'العودة',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess ? Colors.green : null,
              foregroundColor: isSuccess ? Colors.white : null,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        if (!isSuccess) ...[
          const SizedBox(height: 12),
          // Retry Button (for failure)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                onRetry?.call();
              },
              icon: const Icon(Icons.refresh),
              label: const Text(
                'المحاولة مرة أخرى',
                style: TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Success Screen Wrapper
class PaymentSuccessScreen extends StatelessWidget {
  final String? message;
  final VoidCallback? onContinue;

  const PaymentSuccessScreen({
    super.key,
    this.message,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return PaymentResultScreen(
      isSuccess: true,
      message: message,
      onContinue: onContinue,
    );
  }
}

/// Failure Screen Wrapper
class PaymentFailedScreen extends StatelessWidget {
  final String? message;
  final VoidCallback? onContinue;
  final VoidCallback? onRetry;

  const PaymentFailedScreen({
    super.key,
    this.message,
    this.onContinue,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return PaymentResultScreen(
      isSuccess: false,
      message: message,
      onContinue: onContinue,
      onRetry: onRetry,
    );
  }
}
