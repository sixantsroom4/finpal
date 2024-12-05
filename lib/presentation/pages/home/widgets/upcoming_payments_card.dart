import 'package:finpal/domain/entities/subscription.dart';
import 'package:flutter/material.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpcomingPayment {
  final Subscription subscription;
  final int daysLeft;

  UpcomingPayment({required this.subscription, required this.daysLeft});
}

class UpcomingPaymentsCard extends StatelessWidget {
  final List<Subscription> subscriptions;

  const UpcomingPaymentsCard({
    super.key,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final upcomingPayments = _getUpcomingPayments();

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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormat('MM월').format(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...upcomingPayments
                .map((payment) => _buildPaymentItem(context, payment)),
            if (upcomingPayments.isEmpty)
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
  }

  Widget _buildPaymentItem(BuildContext context, UpcomingPayment payment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(payment.subscription.category),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.subscription.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _getLocalizedDaysLeft(context, payment.daysLeft),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatAmount(context, payment.subscription.amount,
                payment.subscription.currency),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<UpcomingPayment> _getUpcomingPayments() {
    final now = DateTime.now();
    return subscriptions
        .where((sub) => sub.isActive)
        .map((sub) {
          final daysLeft = _calculateDaysUntilBilling(sub.billingDay, now.day);
          return UpcomingPayment(subscription: sub, daysLeft: daysLeft);
        })
        .where((payment) => payment.daysLeft <= 7)
        .toList()
      ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
  }

  int _calculateDaysUntilBilling(int billingDay, int currentDay) {
    if (billingDay >= currentDay) {
      return billingDay - currentDay;
    } else {
      final now = DateTime.now();
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
      return lastDayOfMonth - currentDay + billingDay;
    }
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final labels = {
      'upcoming_payments': {
        AppLanguage.english: 'Upcoming Payments',
        AppLanguage.korean: '결제 예정',
        AppLanguage.japanese: '支払い予定',
      },
      'no_upcoming_payments': {
        AppLanguage.english: 'No upcoming payments',
        AppLanguage.korean: '예정된 결제가 없습니다',
        AppLanguage.japanese: '予定された支払いはありません',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  String _getLocalizedDaysLeft(BuildContext context, int days) {
    final language = context.read<AppLanguageBloc>().state.language;
    if (days == 0) {
      return {
            AppLanguage.english: 'Due today',
            AppLanguage.korean: '오늘 결제',
            AppLanguage.japanese: '今日支払い',
          }[language] ??
          '오늘 결제';
    }
    return {
          AppLanguage.english: 'In $days days',
          AppLanguage.korean: '$days일 후',
          AppLanguage.japanese: 'あと$days日',
        }[language] ??
        '$days일 후';
  }

  String _formatAmount(BuildContext context, double amount, String currency) {
    final formatter = NumberFormat('#,###');
    final formattedAmount = formatter.format(amount);
    return '$formattedAmount${_getCurrencySymbol(currency)}';
  }

  String _getCurrencySymbol(String currency) {
    return {
          'KRW': '원',
          'JPY': '¥',
          'USD': '\$',
          'EUR': '€',
        }[currency] ??
        '원';
  }

  IconData _getCategoryIcon(String category) {
    return {
          'ott': Icons.movie_outlined,
          'music': Icons.music_note_outlined,
          'game': Icons.games_outlined,
          'fitness': Icons.fitness_center_outlined,
          'productivity': Icons.work_outlined,
          'software': Icons.computer_outlined,
        }[category.toLowerCase()] ??
        Icons.category_outlined;
  }
}
