import 'package:finpal/presentation/pages/settings/widget/setting_item.dart';
import 'package:flutter/material.dart';

class NotificationSettingsSection extends StatelessWidget {
  const NotificationSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            '알림 설정',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        SettingItem(
          icon: Icons.notifications,
          title: '예산 초과 알림',
          subtitle: '예산의 80% 이상 사용 시 알림',
          trailing: Switch(
            value: true, // TODO: 실제 값으로 변경
            onChanged: (value) {
              // TODO: 알림 설정 변경 구현
            },
          ),
        ),
        SettingItem(
          icon: Icons.subscriptions,
          title: '구독 결제 알림',
          subtitle: '결제 3일 전 알림',
          trailing: Switch(
            value: true, // TODO: 실제 값으로 변경
            onChanged: (value) {
              // TODO: 알림 설정 변경 구현
            },
          ),
        ),
      ],
    );
  }
}
