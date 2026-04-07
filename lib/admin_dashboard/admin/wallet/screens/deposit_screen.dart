import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payments_provider.dart';
import 'payment_webview_screen.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedMethod = 'card'; // default method

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submitDeposit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Hide keyboard
    FocusScope.of(context).unfocus();

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    final paymentsProvider = Provider.of<PaymentsProvider>(context, listen: false);
    final response = await paymentsProvider.initiateDeposit(amount, _selectedMethod);

    if (!mounted) return;

    if (response != null && response.type == 'iframe' && response.url.isNotEmpty) {
      // Navigate to WebView
      final paymentResult = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => PaymentWebviewScreen(
            paymentUrl: response.url,
            // Configure these prefixes according to Paymob's callback URLs pattern
            successUrlPrefix: 'success=true',
            failureUrlPrefix: 'success=false',
          ),
        ),
      );

      if (!mounted) return;

      if (paymentResult == true) {
        _showSuccessDialog('تم الإيداع بنجاح');
      } else if (paymentResult == false) {
        _showErrorDialog('فشلت عملية الدفع. حاول مرة أخرى.');
      } else {
        // null means the user cancelled / popped the screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إلغاء عملية الدفع')),
        );
      }
    } else if (response != null) {
      // In case the response is successful but not an iframe (e.g. direct success for testing)
      _showSuccessDialog(response.message);
    } else {
      // Error occurred, error message from provider
      final errorMessage = paymentsProvider.error ?? 'حدث خطأ غير متوقع';
      _showErrorDialog(errorMessage);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نجاح'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to wallet/dashboard
            },
            child: const Text('حسناً'),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إيداع في المحفظة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'المبلغ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المبلغ';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'يرجى إدخال مبلغ صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedMethod,
                decoration: InputDecoration(
                  labelText: 'طريقة الدفع',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'card', child: Text('بطاقة ائتمان / مدى')),
                  DropdownMenuItem(value: 'apple_pay', child: Text('Apple Pay')),
                  DropdownMenuItem(value: 'stc_pay', child: Text('STC Pay')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMethod = value;
                    });
                  }
                },
              ),
              const Spacer(),
              Consumer<PaymentsProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _submitDeposit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'متابعة للدفع',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
