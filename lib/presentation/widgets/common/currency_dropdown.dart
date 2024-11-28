import 'package:flutter/material.dart';
import 'package:finpal/core/constants/app_currencies.dart';
import 'package:finpal/core/constants/app_languages.dart';

class CurrencyDropdown extends StatelessWidget {
  final String selectedCurrency;
  final Function(String) onChanged;
  final AppLanguage language;

  const CurrencyDropdown({
    super.key,
    required this.selectedCurrency,
    required this.onChanged,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCurrency,
      decoration: const InputDecoration(
        labelText: '통화 선택',
        border: OutlineInputBorder(),
      ),
      items: AppCurrencies.currencies.keys.map((String currency) {
        return DropdownMenuItem<String>(
          value: currency,
          child: Text(AppCurrencies.getLocalizedCurrency(language, currency)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }
}
