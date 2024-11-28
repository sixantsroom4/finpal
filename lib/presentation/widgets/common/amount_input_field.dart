import 'package:finpal/core/utils/currency_utils.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/widgets/common/currency_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmountInputField extends StatelessWidget {
  final double? initialValue;
  final String currency;
  final bool showCurrencySelector; // 통화 선택 표시 여부
  final Function(double) onAmountChanged;
  final Function(String)? onCurrencyChanged;

  const AmountInputField({
    super.key,
    this.initialValue,
    required this.currency,
    this.showCurrencySelector = false, // 기본적으로는 숨김
    required this.onAmountChanged,
    this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: initialValue?.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '금액',
              prefixText: CurrencyUtils.getCurrencySymbol(currency),
            ),
            onChanged: (value) {
              final amount = double.tryParse(value) ?? 0;
              onAmountChanged(amount);
            },
          ),
        ),
        if (showCurrencySelector) ...[
          const SizedBox(width: 8),
          CurrencyDropdown(
            selectedCurrency: currency,
            onChanged: (newCurrency) {
              onCurrencyChanged?.call(newCurrency);
            },
            language: context.read<AppLanguageBloc>().state.language,
          ),
        ],
      ],
    );
  }
}
