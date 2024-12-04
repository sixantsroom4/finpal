// lib/presentation/pages/subscription/widgets/subscription_statistics_card.dart
import 'package:finpal/domain/entities/subscription.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class SubscriptionStatisticsCard extends StatelessWidget {
  final List<Subscription> subscriptions;

  const SubscriptionStatisticsCard({
    super.key,
    required this.subscriptions,
  });

  // 통화별로 구독을 그룹화하고 합계를 계산
  Map<String, double> _calculateTotalsByCurrency() {
    final totals = <String, double>{};
    for (var sub in subscriptions) {
      if (sub.isCurrentlyActive) {
        totals.update(
          sub.currency,
          (value) => value + sub.amount,
          ifAbsent: () => sub.amount,
        );
      }
    }
    return totals;
  }

  // 연간 총액도 통화별로 계산
  Map<String, double> _calculateYearlyTotalsByCurrency() {
    final totals = <String, double>{};
    for (var sub in subscriptions) {
      if (sub.isCurrentlyActive) {
        final yearlyAmount = sub.billingCycle.toLowerCase() == 'monthly'
            ? sub.amount * 12
            : sub.amount;
        totals.update(
          sub.currency,
          (value) => value + yearlyAmount,
          ifAbsent: () => yearlyAmount,
        );
      }
    }
    return totals;
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'monthly_total': {
        AppLanguage.english: 'Expected Monthly Subscription',
        AppLanguage.korean: '이번 달 예상 구독료',
        AppLanguage.japanese: '今月の予想サブスク料金',
      },
      'yearly_total': {
        AppLanguage.english: 'Yearly Total',
        AppLanguage.korean: '연간 총액',
        AppLanguage.japanese: '年間総額',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final monthlyTotals = _calculateTotalsByCurrency();
    final yearlyTotals = _calculateYearlyTotalsByCurrency();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getLocalizedLabel(context, 'monthly_total'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            // 통화별 월간 구독료 표시
            ...monthlyTotals.entries.map((entry) => Text(
                  _formatAmount(context, entry.value, entry.key),
                  style: Theme.of(context).textTheme.headlineSmall,
                )),
            const Divider(height: 24),
            Text(
              _getLocalizedLabel(context, 'yearly_total'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            // 통화별 연간 구독료 표시
            ...yearlyTotals.entries.map((entry) => Text(
                  _formatAmount(context, entry.value, entry.key),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                )),
          ],
        ),
      ),
    );
  }

  String _formatAmount(BuildContext context, double amount, String currency) {
    final formatter = NumberFormat('#,###');
    final formattedAmount = formatter.format(amount);
    final currencySymbols = {
      'KRW': '원',
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
    };

    final symbol = currencySymbols[currency] ?? currencySymbols['KRW']!;

    switch (currency) {
      case 'USD':
      case 'EUR':
        return '$symbol$formattedAmount';
      case 'JPY':
        return '¥$formattedAmount';
      case 'KRW':
      default:
        return '$formattedAmount$symbol';
    }
  }
}
