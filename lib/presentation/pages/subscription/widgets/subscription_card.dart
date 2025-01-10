// lib/presentation/pages/subscription/widgets/subscription_card.dart
import 'package:finpal/core/utils/subscription_category_constants.dart';
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
      'paused': {
        AppLanguage.english: 'Paused',
        AppLanguage.korean: '일시정지',
        AppLanguage.japanese: '一時停止',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  String _getLocalizedAmount(BuildContext context, double amount) {
    final formatter = NumberFormat('#,###');
    final formattedAmount = formatter.format(amount);

    final currencySymbols = {
      'KRW': '원',
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
    };

    final symbol =
        currencySymbols[subscription.currency] ?? currencySymbols['KRW']!;

    // 통화별 표시 형식
    switch (subscription.currency) {
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
    return Opacity(
      opacity: subscription.isActive ? 1.0 : 0.6,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 아이콘 부분
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3E50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    SubscriptionCategoryConstants
                        .categoryIcons[subscription.category]!,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(width: 16),
                // 정보 부분
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            subscription.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          if (!subscription.isActive)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getLocalizedLabel(context, 'paused'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getLocalizedAmount(context, subscription.amount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      if (daysUntilBilling != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          daysUntilBilling == 0
                              ? _getLocalizedLabel(context, 'billing_today')
                              : _getLocalizedLabel(
                                  context, 'billing_days_left'),
                          style: TextStyle(
                            fontSize: 12,
                            color: daysUntilBilling == 0
                                ? Colors.red
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
