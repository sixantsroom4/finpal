// lib/presentation/pages/subscription/widgets/subscription_details_bottom_sheet.dart

import 'package:finpal/presentation/bloc/subscription/subscription_event.dart';
import 'package:finpal/presentation/bloc/subscription/subscription_state.dart';
import 'package:finpal/presentation/pages/subscription/widgets/edit_subscription_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/subscription.dart';
import '../../../bloc/subscription/subscription_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/core/utils/subscription_category_constants.dart';

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
      // 여기서 'paused' key를 추가하거나 'inactive'를 그대로 쓸 수도 있음
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

  String _getLocalizedBillingDay(BuildContext context, int billingDay) {
    final language = context.read<AppLanguageBloc>().state.language;
    switch (language) {
      case AppLanguage.english:
        return 'Day $billingDay';
      case AppLanguage.japanese:
        return '${billingDay}日';
      case AppLanguage.korean:
      default:
        return '매월 ${billingDay}일';
    }
  }

  String _getLocalizedCategory(BuildContext context, String category) {
    return SubscriptionCategoryConstants.getLocalizedCategory(
        context, category);
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
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getLocalizedLabel(context, 'subscription_details'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: subscription.isActive
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          subscription.isActive
                              ? Icons.check_circle
                              : Icons.pause_circle,
                          color: subscription.isActive
                              ? Colors.green
                              : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subscription.isActive
                              ? _getLocalizedLabel(context, 'active')
                              : _getLocalizedLabel(context, 'inactive'),
                          style: TextStyle(
                            color: subscription.isActive
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            // 상세 정보 표시
            _DetailItem(
              title: _getLocalizedLabel(context, 'amount'),
              value: _getLocalizedAmount(context, subscription.amount),
            ),
            _DetailItem(
              title: _getLocalizedLabel(context, 'category'),
              value: _getLocalizedCategory(context, subscription.category),
            ),
            _DetailItem(
              title: _getLocalizedLabel(context, 'billing_cycle'),
              value:
                  _getLocalizedBillingCycle(context, subscription.billingCycle),
            ),
            _DetailItem(
              title: _getLocalizedLabel(context, 'billing_day'),
              value: _getLocalizedBillingDay(context, subscription.billingDay),
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

            // 액션 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditSubscriptionDialog(context),
                    icon: const Icon(Icons.edit),
                    label: Text(_getLocalizedLabel(context, 'edit')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleSubscriptionStatus(context),
                    icon: Icon(
                      subscription.isActive ? Icons.pause : Icons.play_arrow,
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
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showDeleteConfirmation(context),
                icon: const Icon(Icons.delete, color: Colors.red),
                label: Text(_getLocalizedLabel(context, 'delete')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
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

  /// 핵심 변경: async/await로 순차 처리
  Future<void> _toggleSubscriptionStatus(BuildContext context) async {
    final bloc = context.read<SubscriptionBloc>();
    final updatedSubscription =
        subscription.copyWith(isActive: !subscription.isActive);

    // 1) UpdateSubscription 이벤트 전송
    bloc.add(UpdateSubscription(updatedSubscription));

    // 2) 해당 이벤트 처리(성공 또는 에러) 완료 대기
    final firstState = await bloc.stream.firstWhere(
      (state) =>
          state is SubscriptionOperationSuccess || state is SubscriptionError,
    );

    // 3) 성공 시 => LoadActiveSubscriptions 이벤트 전송
    if (firstState is SubscriptionOperationSuccess) {
      bloc.add(LoadActiveSubscriptions(updatedSubscription.userId));

      // 다시 로드된 상태(Loaded or Error) 대기
      final secondState = await bloc.stream.firstWhere(
        (state) => state is SubscriptionLoaded || state is SubscriptionError,
      );

      // 4) 구독 목록이 성공적으로 로드되었다면 창 닫기
      if (secondState is SubscriptionLoaded) {
        Navigator.pop(context);
      }
      // 혹시 에러라면, SnackBar 등을 띄워주는 로직을 넣어도 좋습니다.
    } else if (firstState is SubscriptionError) {
      // 업데이트 실패 시, 에러 메시지를 띄우는 등 UI 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(firstState.message)),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_getLocalizedLabel(context, 'delete_confirmation_title')),
          content:
              Text(_getLocalizedLabel(context, 'delete_confirmation_message')),
          actions: <Widget>[
            TextButton(
              child: Text(_getLocalizedLabel(context, 'cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(_getLocalizedLabel(context, 'delete')),
              onPressed: () {
                context.read<SubscriptionBloc>().add(DeleteSubscription(
                    subscriptionId: subscription.id,
                    userId: subscription.userId));
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
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
