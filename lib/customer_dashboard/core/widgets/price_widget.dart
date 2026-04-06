import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../utils/currency_formatter.dart';

class PriceWidget extends StatelessWidget {
  final double price;
  final TextStyle? style;
  final bool isCompact;

  const PriceWidget({
    super.key,
    required this.price,
    this.style,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      isCompact ? CurrencyFormatter.formatCompact(price) : CurrencyFormatter.format(price),
      style: style ?? AppTextStyles.priceStyle,
    );
  }
}
