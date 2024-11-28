import 'package:flutter/material.dart';
import 'package:finpal/core/constants/app_currencies.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:intl/intl.dart';

class CurrencyTotalCard extends StatelessWidget {
  final String currency;
  final double amount;
  final AppLanguage language;

  const CurrencyTotalCard({
    super.key,
    required this.currency,
    required this.amount,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.currency(
      symbol: '',
      locale: language.code,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppCurrencies.getLocalizedCurrency(language, currency),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${numberFormat.format(amount)} $currency',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
