// lib/presentation/pages/subscription/widgets/subscription_details_bottom_sheet.dart
import 'package:finpal/presentation/bloc/subscription/subscription_event.dart';
import 'package:finpal/presentation/pages/subscription/widgets/edit_subscription_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/subscription.dart';
import '../../../bloc/subscription/subscription_bloc.dart';

class SubscriptionDetailsBottomSheet extends StatelessWidget {
  final Subscription subscription;
  final _numberFormat = NumberFormat('#,###');

  SubscriptionDetailsBottomSheet({
    super.key,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '구독 상세',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),

          _DetailItem(
            title: '서비스',
            value: subscription.name,
          ),
          _DetailItem(
            title: '금액',
            value: '${_numberFormat.format(subscription.amount)}원',
          ),
          _DetailItem(
            title: '카테고리',
            value: subscription.category,
          ),
          _DetailItem(
            title: '결제 주기',
            value: _getBillingCycleText(subscription.billingCycle),
          ),
          _DetailItem(
            title: '결제일',
            value: '매월 ${subscription.billingDay}일',
          ),
          _DetailItem(
            title: '시작일',
            value: DateFormat('yyyy년 M월 d일').format(subscription.startDate),
          ),
          if (subscription.endDate != null)
            _DetailItem(
              title: '종료일',
              value: DateFormat('yyyy년 M월 d일').format(subscription.endDate!),
            ),
          _DetailItem(
            title: '상태',
            value: subscription.isActive ? '사용중' : '해지됨',
            valueColor: subscription.isActive ? Colors.blue : Colors.grey,
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              // 수정 버튼
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditSubscriptionDialog(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('수정'),
                ),
              ),
              const SizedBox(width: 8),
              // 구독 상태 변경 버튼
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _toggleSubscriptionStatus(context),
                  icon: Icon(
                    subscription.isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                  ),
                  label: Text(
                    subscription.isActive ? '일시정지' : '재시작',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        subscription.isActive ? Colors.orange : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 삭제 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteConfirmation(context),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('삭제'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBillingCycleText(String cycle) {
    switch (cycle.toLowerCase()) {
      case 'monthly':
        return '월간';
      case 'yearly':
        return '연간';
      case 'weekly':
        return '주간';
      default:
        return cycle;
    }
  }

  void _showEditSubscriptionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditSubscriptionBottomSheet(
        subscription: subscription,
      ),
    );
  }

  void _toggleSubscriptionStatus(BuildContext context) {
    final updatedSubscription = Subscription(
      id: subscription.id,
      name: subscription.name,
      amount: subscription.amount,
      startDate: subscription.startDate,
      billingCycle: subscription.billingCycle,
      billingDay: subscription.billingDay,
      category: subscription.category,
      userId: subscription.userId,
      endDate: subscription.endDate,
      isActive: !subscription.isActive,
    );

    context.read<SubscriptionBloc>().add(
          UpdateSubscription(updatedSubscription),
        );
    Navigator.pop(context);
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('구독 삭제'),
        content: const Text('이 구독을 정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<SubscriptionBloc>().add(
                    DeleteSubscription(subscription.id),
                  );
              // 다이얼로그와 바텀시트를 닫고 구독 페이지로 이동
              if (context.mounted) {
                Navigator.pop(context); // 다이얼로그 닫기
                context.pop(); // 바텀시트 닫기 (GoRouter 사용)
              }
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _DetailItem({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
