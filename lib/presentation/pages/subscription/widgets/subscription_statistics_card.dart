// lib/presentation/pages/subscription/widgets/subscription_statistics_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '이번 달 예상 구독료',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${NumberFormat('#,###').format(monthlyTotal)}원',
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
                  label: '연간 총액',
                  value: '${NumberFormat('#,###').format(yearlyTotal)}원',
                ),
                _StatisticItem(
                  label: '활성 구독',
                  value: '$activeCount개',
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
