import 'package:finpal/core/constants/app_languages.dart';
import 'package:flutter/material.dart';
import 'package:finpal/core/extensions/expense_list_extension.dart';
import 'package:finpal/data/models/expense_model.dart';
import 'package:finpal/presentation/widgets/common/currency_total_card.dart';

class CurrencyTotalsSection extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final AppLanguage language;

  const CurrencyTotalsSection({
    super.key,
    required this.expenses,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final currencyTotals = expenses.groupByCurrency();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '통화별 지출 합계',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: currencyTotals.length,
          itemBuilder: (context, index) {
            final currency = currencyTotals.keys.elementAt(index);
            final amount = currencyTotals[currency]!;

            return CurrencyTotalCard(
              currency: currency,
              amount: amount,
              language: language,
            );
          },
        ),
      ],
    );
  }
}
