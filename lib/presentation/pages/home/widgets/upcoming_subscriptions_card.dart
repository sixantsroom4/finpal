// lib/presentation/pages/home/widgets/upcoming_subscriptions_card.dart
import 'package:finpal/presentation/bloc/subscription/subscription_state.dart';
import 'package:finpal/presentation/pages/home/widgets/upcoming_payments_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../bloc/subscription/subscription_bloc.dart';
import '../../../../domain/entities/subscription.dart';
import '../../../bloc/app_language/app_language_bloc.dart';
import '../../../../core/constants/app_languages.dart';
import '../../../bloc/app_settings/app_settings_bloc.dart';

class UpcomingSubscriptionsCard extends StatelessWidget {
  const UpcomingSubscriptionsCard({super.key});

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'upcoming_payments': {
        AppLanguage.english: 'Upcoming Payments',
        AppLanguage.korean: '다가오는 결제',
        AppLanguage.japanese: '今後の支払い',
      },
      'payment_today': {
        AppLanguage.english: 'Payment due today',
        AppLanguage.korean: '오늘 결제 예정',
        AppLanguage.japanese: '本日支払い予定',
      },
      'monthly_total': {
        AppLanguage.english: 'Monthly',
        AppLanguage.korean: '월',
        AppLanguage.japanese: '月額',
      },
      'no_upcoming_payments': {
        AppLanguage.english: 'No upcoming payments this month',
        AppLanguage.korean: '이번 달 예정된 결제가 없습니다.',
        AppLanguage.japanese: '今月の予定された支払いはありません',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  String _getLocalizedAmount(BuildContext context, double amount) {
    final currency = context.read<AppSettingsBloc>().state.currency;
    final formattedAmount = NumberFormat('#,###').format(amount);

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is! SubscriptionLoaded) {
          return const SizedBox.shrink();
        }

        // 다가오는 결제 계산 (구독 페이지의 로직 사용)
        final now = DateTime.now();
        final upcomingSubscriptions = state.billingDaySubscriptions.entries
            .where((entry) => _isUpcoming(entry.key, now.day))
            .expand((entry) => entry.value)
            .toList()
          ..sort((a, b) {
            final daysUntilA =
                _calculateDaysUntilBilling(a.billingDay, now.day);
            final daysUntilB =
                _calculateDaysUntilBilling(b.billingDay, now.day);
            return daysUntilA.compareTo(daysUntilB);
          });

        // 통화별 총액 계산
        final totalsByCurrency = <String, double>{};
        for (var subscription in upcomingSubscriptions) {
          if (subscription.billingCycle.toLowerCase() == 'monthly') {
            totalsByCurrency.update(
              subscription.currency,
              (value) => value + subscription.amount,
              ifAbsent: () => subscription.amount,
            );
          }
        }

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
                colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getLocalizedLabel(context, 'upcoming_payments'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    // 통화별 총액 표시
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ...totalsByCurrency.entries.map((entry) => Text(
                              _formatAmount(context, entry.value, entry.key),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 결제 예정 목록
                ...upcomingSubscriptions.map((subscription) {
                  final daysLeft = _calculateDaysUntilBilling(
                    subscription.billingDay,
                    DateTime.now().day,
                  );
                  return UpcomingPayment(
                    subscription: subscription,
                    daysLeft: daysLeft,
                  );
                }).map((payment) => _buildPaymentItem(context, payment)),
                if (upcomingSubscriptions.isEmpty)
                  Center(
                    child: Text(
                      _getLocalizedLabel(context, 'no_upcoming_payments'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _calculateDaysUntilBilling(int billingDay, int currentDay) {
    if (billingDay > currentDay) {
      return billingDay - currentDay;
    } else {
      // 다음 달의 결제까지 남은 일수 계산
      final lastDayOfMonth =
          DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
      return lastDayOfMonth - currentDay + billingDay;
    }
  }

  String _formatAmount(BuildContext context, double amount, String currency) {
    final formattedAmount = NumberFormat('#,###').format(amount);
    final currencySymbols = {
      'KRW': '원',
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
    };
    final symbol = currencySymbols[currency] ?? currencySymbols['KRW']!;
    return '$symbol$formattedAmount';
  }

  Widget _buildPaymentItem(BuildContext context, UpcomingPayment payment) {
    final daysUntilBilling = payment.daysLeft;
    final isToday = daysUntilBilling == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          // 카테고리 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getCategoryColor(payment.subscription.category)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(payment.subscription.category),
              color: _getCategoryColor(payment.subscription.category),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // 구독 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.subscription.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  isToday ? '오늘 결제 예정' : '$daysUntilBilling일 후 결제',
                  style: TextStyle(
                    fontSize: 12,
                    color: isToday ? Colors.red : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // 금액
          Text(
            _getLocalizedAmount(context, payment.subscription.amount),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'ott':
        return Colors.red;
      case 'music':
        return Colors.green;
      case 'game':
        return Colors.blue;
      case 'fitness':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
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

  bool _isUpcoming(int billingDay, int currentDay) {
    final daysUntilBilling = _calculateDaysUntilBilling(billingDay, currentDay);
    return daysUntilBilling <= 7; // 7일 이내 결제 예정
  }
}
