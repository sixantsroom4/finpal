import 'package:finpal/presentation/pages/settings/widget/setting_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class NotificationSettingsSection extends StatelessWidget {
  const NotificationSettingsSection({super.key});

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'notifications': {
        AppLanguage.english: 'Notifications',
        AppLanguage.korean: '알림 설정',
        AppLanguage.japanese: '通知設定',
      },
      'budget_alert': {
        AppLanguage.english: 'Budget Alert',
        AppLanguage.korean: '예산 초과 알림',
        AppLanguage.japanese: '予算超過通知',
      },
      'budget_alert_desc': {
        AppLanguage.english: 'Alert when budget usage exceeds 80%',
        AppLanguage.korean: '예산의 80% 이상 사용 시 알림',
        AppLanguage.japanese: '予算使用率が80%を超えた時に通知',
      },
      'subscription_alert': {
        AppLanguage.english: 'Subscription Alert',
        AppLanguage.korean: '구독 결제 알림',
        AppLanguage.japanese: 'サブスク決済通知',
      },
      'subscription_alert_desc': {
        AppLanguage.english: 'Alert 3 days before payment',
        AppLanguage.korean: '결제 3일 전 알림',
        AppLanguage.japanese: '決済3日前に通知',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF2C3E50),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Text(
              _getLocalizedLabel(context, 'notifications'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SettingItem(
            icon: Icons.notifications,
            iconColor: const Color(0xFF2C3E50),
            iconBackgroundColor: const Color(0xFF2C3E50).withOpacity(0.1),
            title: _getLocalizedLabel(context, 'budget_alert'),
            subtitle: _getLocalizedLabel(context, 'budget_alert_desc'),
            trailing: Switch(
              value: true,
              activeColor: const Color(0xFF2C3E50),
              onChanged: (value) {
                // TODO: 알림 설정 변경 구현
              },
            ),
          ),
          const Divider(height: 1),
          SettingItem(
            icon: Icons.subscriptions,
            iconColor: const Color(0xFF2C3E50),
            iconBackgroundColor: const Color(0xFF2C3E50).withOpacity(0.1),
            title: _getLocalizedLabel(context, 'subscription_alert'),
            subtitle: _getLocalizedLabel(context, 'subscription_alert_desc'),
            trailing: Switch(
              value: true,
              activeColor: const Color(0xFF2C3E50),
              onChanged: (value) {
                // TODO: 알림 설정 변경 구현
              },
            ),
          ),
        ],
      ),
    );
  }
}
