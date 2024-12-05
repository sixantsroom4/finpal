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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 월간 구독료
            Text(
              _getLocalizedLabel(context, 'monthly_total'),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...monthlyTotals.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    _formatAmount(context, entry.value, entry.key),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.white24),
            ),

            // 연간 총액
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLocalizedLabel(context, 'yearly_total'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...yearlyTotals.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            _formatAmount(context, entry.value, entry.key),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${DateTime.now().year}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
