// lib/presentation/pages/subscription/widgets/subscription_details_bottom_sheet.dart
import 'package:finpal/presentation/bloc/subscription/subscription_event.dart';
import 'package:finpal/presentation/pages/subscription/widgets/edit_subscription_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/subscription.dart';
import '../../../bloc/subscription/subscription_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class SubscriptionDetailsBottomSheet extends StatelessWidget {
  final Subscription subscription;
  final _numberFormat = NumberFormat('#,###');

  SubscriptionDetailsBottomSheet({
    super.key,
    required this.subscription,
  });

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'subscription_details': {
        AppLanguage.english: 'Subscription Details',
        AppLanguage.korean: '구독 상세',
        AppLanguage.japanese: 'サブスク詳細',
      },
      'service': {
        AppLanguage.english: 'Service',
        AppLanguage.korean: '서비스',
        AppLanguage.japanese: 'サービス',
      },
      'amount': {
        AppLanguage.english: 'Amount',
        AppLanguage.korean: '금액',
        AppLanguage.japanese: '金額',
      },
      'category': {
        AppLanguage.english: 'Category',
        AppLanguage.korean: '카테고리',
        AppLanguage.japanese: 'カテゴリー',
      },
      'billing_cycle': {
        AppLanguage.english: 'Billing Cycle',
        AppLanguage.korean: '결제 주기',
        AppLanguage.japanese: '決済周期',
      },
      'billing_day': {
        AppLanguage.english: 'Billing Day',
        AppLanguage.korean: '결제일',
        AppLanguage.japanese: '決済日',
      },
      'start_date': {
        AppLanguage.english: 'Start Date',
        AppLanguage.korean: '시작일',
        AppLanguage.japanese: '開始日',
      },
      'end_date': {
        AppLanguage.english: 'End Date',
        AppLanguage.korean: '종료일',
        AppLanguage.japanese: '終了日',
      },
      'status': {
        AppLanguage.english: 'Status',
        AppLanguage.korean: '상태',
        AppLanguage.japanese: 'ステータス',
      },
      'active': {
        AppLanguage.english: 'Active',
        AppLanguage.korean: '사용중',
        AppLanguage.japanese: '利用中',
      },
      'inactive': {
        AppLanguage.english: 'Inactive',
        AppLanguage.korean: '해지됨',
        AppLanguage.japanese: '解約済み',
      },
      'edit': {
        AppLanguage.english: 'Edit',
        AppLanguage.korean: '수정',
        AppLanguage.japanese: '編集',
      },
      'pause': {
        AppLanguage.english: 'Pause',
        AppLanguage.korean: '일시정지',
        AppLanguage.japanese: '一時停止',
      },
      'resume': {
        AppLanguage.english: 'Resume',
        AppLanguage.korean: '재시작',
        AppLanguage.japanese: '再開',
      },
      'delete': {
        AppLanguage.english: 'Delete',
        AppLanguage.korean: '삭제',
        AppLanguage.japanese: '削除',
      },
      'delete_confirmation_title': {
        AppLanguage.english: 'Delete Subscription',
        AppLanguage.korean: '구독 삭제',
        AppLanguage.japanese: 'サブスク削除',
      },
      'delete_confirmation_message': {
        AppLanguage.english:
            'Are you sure you want to delete this subscription?',
        AppLanguage.korean: '이 구독을 정말 삭제하시겠습니까?',
        AppLanguage.japanese: 'このサブスクを本当に削除しますか？',
      },
      'cancel': {
        AppLanguage.english: 'Cancel',
        AppLanguage.korean: '취소',
        AppLanguage.japanese: 'キャンセル',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  String _getLocalizedBillingCycle(BuildContext context, String cycle) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> cycles = {
      'monthly': {
        AppLanguage.english: 'Monthly',
        AppLanguage.korean: '월간',
        AppLanguage.japanese: '月間',
      },
      'yearly': {
        AppLanguage.english: 'Yearly',
        AppLanguage.korean: '연간',
        AppLanguage.japanese: '年間',
      },
      'weekly': {
        AppLanguage.english: 'Weekly',
        AppLanguage.korean: '주간',
        AppLanguage.japanese: '週間',
      },
    };
    return cycles[cycle.toLowerCase()]?[language] ??
        cycles[cycle.toLowerCase()]?[AppLanguage.korean] ??
        cycle;
  }

  String _getLocalizedDate(BuildContext context, DateTime date) {
    final language = context.read<AppLanguageBloc>().state.language;
    switch (language) {
      case AppLanguage.english:
        return DateFormat('MMM d, yyyy').format(date);
      case AppLanguage.japanese:
        return DateFormat('yyyy年 M月 d日').format(date);
      case AppLanguage.korean:
      default:
        return DateFormat('yyyy년 M월 d일').format(date);
    }
  }

  String _getLocalizedAmount(BuildContext context, double amount) {
    final language = context.read<AppLanguageBloc>().state.language;
    final formattedAmount = _numberFormat.format(amount);
    switch (language) {
      case AppLanguage.english:
        return '\$$formattedAmount';
      case AppLanguage.japanese:
        return '¥$formattedAmount';
      case AppLanguage.korean:
      default:
        return '${formattedAmount}원';
    }
  }

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
                _getLocalizedLabel(context, 'subscription_details'),
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
            title: _getLocalizedLabel(context, 'service'),
            value: subscription.name,
          ),
          _DetailItem(
            title: _getLocalizedLabel(context, 'amount'),
            value: _getLocalizedAmount(context, subscription.amount),
          ),
          _DetailItem(
            title: _getLocalizedLabel(context, 'category'),
            value: subscription.category,
          ),
          _DetailItem(
            title: _getLocalizedLabel(context, 'billing_cycle'),
            value:
                _getLocalizedBillingCycle(context, subscription.billingCycle),
          ),
          _DetailItem(
            title: _getLocalizedLabel(context, 'billing_day'),
            value: '매월 ${subscription.billingDay}일',
          ),
          _DetailItem(
            title: _getLocalizedLabel(context, 'start_date'),
            value: _getLocalizedDate(context, subscription.startDate),
          ),
          if (subscription.endDate != null)
            _DetailItem(
              title: _getLocalizedLabel(context, 'end_date'),
              value: _getLocalizedDate(context, subscription.endDate!),
            ),
          _DetailItem(
            title: _getLocalizedLabel(context, 'status'),
            value: subscription.isActive
                ? _getLocalizedLabel(context, 'active')
                : _getLocalizedLabel(context, 'inactive'),
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
                  label: Text(
                    _getLocalizedLabel(context, 'edit'),
                  ),
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
                    subscription.isActive
                        ? _getLocalizedLabel(context, 'pause')
                        : _getLocalizedLabel(context, 'resume'),
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
              label: Text(
                _getLocalizedLabel(context, 'delete'),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
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
        title: Text(
          _getLocalizedLabel(context, 'delete_confirmation_title'),
        ),
        content: Text(
          _getLocalizedLabel(context, 'delete_confirmation_message'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _getLocalizedLabel(context, 'cancel'),
            ),
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
            child: Text(
              _getLocalizedLabel(context, 'delete'),
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
