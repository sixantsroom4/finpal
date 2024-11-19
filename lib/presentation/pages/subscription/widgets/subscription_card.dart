// lib/presentation/pages/subscription/widgets/subscription_card.dart
import 'package:finpal/domain/entities/subscription.dart';
import 'package:finpal/presentation/pages/subscription/widgets/add_subscription_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
              '매월 ${subscription.billingDay}일',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (daysUntilBilling != null)
              Text(
                daysUntilBilling == 0 ? '오늘 결제 예정' : '$daysUntilBilling일 후 결제',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: daysUntilBilling == 0
                          ? Theme.of(context).colorScheme.error
                          : Colors.grey,
                    ),
              ),
          ],
        ),
        trailing: Text(
          '${NumberFormat('#,###').format(subscription.amount)}원',
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
