// lib/presentation/pages/subscription/widgets/subscription_statistics_card.dart
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class SubscriptionStatisticsCard extends StatelessWidget {
  final double monthlyTotal;
  final double yearlyTotal;
  final int activeCount;

  const SubscriptionStatisticsCard({
    super.key,
    required this.monthlyTotal,
    required this.yearlyTotal,
    required this.activeCount,
  });

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'monthly_subscription': {
        AppLanguage.english: 'Expected Monthly Subscription',
        AppLanguage.korean: '이번 달 예상 구독료',
        AppLanguage.japanese: '今月の予想サブスク料金',
      },
      'yearly_total': {
        AppLanguage.english: 'Yearly Total',
        AppLanguage.korean: '연간 총액',
        AppLanguage.japanese: '年間総額',
      },
      'active_subscriptions': {
        AppLanguage.english: 'Active Subscriptions',
        AppLanguage.korean: '활성 구독',
        AppLanguage.japanese: '利用中のサブスク',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  String _getLocalizedAmount(BuildContext context, double amount) {
    final currency = context.read<AppSettingsBloc>().state.currency;
    final formatter = NumberFormat('#,###');
    final formattedAmount = formatter.format(amount);

    final currencySymbols = {
      'KRW': '원',
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
    };

    final symbol = currencySymbols[currency] ?? currencySymbols['KRW']!;

    // 통화별 표시 형식
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

  String _getLocalizedCount(BuildContext context, int count) {
    final language = context.read<AppLanguageBloc>().state.language;
    switch (language) {
      case AppLanguage.english:
        return count.toString();
      case AppLanguage.japanese:
        return '$count個';
      case AppLanguage.korean:
      default:
        return '${count}개';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _getLocalizedLabel(context, 'monthly_subscription'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _getLocalizedAmount(context, monthlyTotal),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatisticItem(
                  label: _getLocalizedLabel(context, 'yearly_total'),
                  value: _getLocalizedAmount(context, yearlyTotal),
                ),
                _StatisticItem(
                  label: _getLocalizedLabel(context, 'active_subscriptions'),
                  value: _getLocalizedCount(context, activeCount),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatisticItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
