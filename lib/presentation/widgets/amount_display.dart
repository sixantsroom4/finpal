import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AmountDisplay extends StatelessWidget {
  final double amount;
  final String currency;
  final NumberFormat _numberFormat = NumberFormat('#,###');

  AmountDisplay({
    required this.amount,
    required this.currency,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = _numberFormat.format(amount);
    switch (currency) {
      case 'USD':
        return Text('\$$formattedAmount');
      case 'JPY':
        return Text('¥$formattedAmount');
      case 'KRW':
      default:
        return Text('${formattedAmount}원');
    }
  }
}
