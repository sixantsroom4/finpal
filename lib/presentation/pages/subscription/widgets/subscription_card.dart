// lib/presentation/pages/subscription/widgets/subscription_card.dart
import 'package:finpal/domain/entities/subscription.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/presentation/pages/subscription/widgets/add_subscription_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final int? daysUntilBilling;
  final VoidCallback onTap;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.daysUntilBilling,
    required this.onTap,
  });

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'billing_day_format': {
        AppLanguage.english: 'Day ${subscription.billingDay} of every month',
        AppLanguage.korean: '매월 ${subscription.billingDay}일',
        AppLanguage.japanese: '毎月${subscription.billingDay}日',
      },
      'billing_today': {
        AppLanguage.english: 'Payment due today',
        AppLanguage.korean: '오늘 결제 예정',
        AppLanguage.japanese: '本日支払い予定',
      },
      'billing_days_left': {
        AppLanguage.english: 'Payment in $daysUntilBilling days',
        AppLanguage.korean: '$daysUntilBilling일 후 결제',
        AppLanguage.japanese: '支払いまで残り$daysUntilBilling日',
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            _getSubscriptionIcon(subscription.category),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(subscription.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getLocalizedLabel(context, 'billing_day_format'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (daysUntilBilling != null)
              Text(
                daysUntilBilling == 0
                    ? _getLocalizedLabel(context, 'billing_today')
                    : _getLocalizedLabel(context, 'billing_days_left'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: daysUntilBilling == 0
                          ? Theme.of(context).colorScheme.error
                          : Colors.grey,
                    ),
              ),
          ],
        ),
        trailing: Text(
          _getLocalizedAmount(context, subscription.amount),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _getSubscriptionIcon(String category) {
    switch (category.toLowerCase()) {
      case 'ott':
        return Icons.movie_outlined;
      case 'music':
        return Icons.music_note_outlined;
      case 'game':
        return Icons.games_outlined;
      case 'fitness':
        return Icons.fitness_center_outlined;
      default:
        return Icons.subscriptions_outlined;
    }
  }
}

// lib/presentation/pages/subscription/widgets/
class AddSubscriptionFab extends StatelessWidget {
  const AddSubscriptionFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddSubscriptionDialog(context),
      child: const Icon(Icons.add),
    );
  }

  void _showAddSubscriptionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddSubscriptionBottomSheet(),
    );
  }
}
