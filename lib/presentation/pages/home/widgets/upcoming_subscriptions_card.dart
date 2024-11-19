// lib/presentation/pages/home/widgets/upcoming_subscriptions_card.dart
import 'package:finpal/presentation/bloc/subscription/subscription_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../bloc/subscription/subscription_bloc.dart';
import '../../../../domain/entities/subscription.dart';

class UpcomingSubscriptionsCard extends StatelessWidget {
  const UpcomingSubscriptionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is! SubscriptionLoaded) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final upcomingSubscriptions =
            _getUpcomingSubscriptions(state.billingDaySubscriptions);

        if (upcomingSubscriptions.isEmpty) {
          return Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '다가오는 결제',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '월 ${NumberFormat('#,###').format(state.monthlyTotal)}원',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      '이번 달 예정된 결제가 없습니다.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '다가오는 결제',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '월 ${NumberFormat('#,###').format(state.monthlyTotal)}원',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...upcomingSubscriptions.map(
                  (subscription) =>
                      _SubscriptionTile(subscription: subscription),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Subscription> _getUpcomingSubscriptions(
      Map<int, List<Subscription>> billingDaySubscriptions) {
    final now = DateTime.now();
    final currentDay = now.day;

    // 다음 7일 동안의 결제 예정 구독들을 가져옴
    final List<Subscription> upcoming = [];
    for (var i = 0; i < 7; i++) {
      final checkDay = (currentDay + i) % 31;
      if (billingDaySubscriptions.containsKey(checkDay)) {
        upcoming.addAll(billingDaySubscriptions[checkDay]!);
      }
    }

    // 결제일 기준으로 정렬
    upcoming.sort((a, b) => a.billingDay.compareTo(b.billingDay));

    // 최대 3개만 반환
    return upcoming.take(3).toList();
  }
}

class _SubscriptionTile extends StatelessWidget {
  final Subscription subscription;

  const _SubscriptionTile({
    required this.subscription,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntilBilling = _calculateDaysUntilBilling();
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
              color: _getCategoryColor(subscription.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(subscription.category),
              color: _getCategoryColor(subscription.category),
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
                  subscription.name,
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
            '${NumberFormat('#,###').format(subscription.amount)}원',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateDaysUntilBilling() {
    final now = DateTime.now();
    final currentDay = now.day;

    if (subscription.billingDay > currentDay) {
      return subscription.billingDay - currentDay;
    } else {
      // 다음 달의 결제일까지 남은 일수 계산
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
      return lastDayOfMonth - currentDay + subscription.billingDay;
    }
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
}
