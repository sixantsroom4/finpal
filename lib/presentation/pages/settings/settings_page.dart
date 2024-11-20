// lib/presentation/pages/settings/settings_page.dart
import 'package:finpal/presentation/bloc/auth/auth_event.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/pages/settings/widget/preferences_section.dart';
import 'package:finpal/presentation/pages/settings/widget/profile_section.dart';
import 'package:finpal/presentation/pages/settings/widget/setting_item.dart';
import 'package:finpal/presentation/pages/settings/widgets/notification_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';

import 'widgets/data_management_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) {
            return const Center(
              child: Text('로그인이 필요합니다'),
            );
          }

          return ListView(
            children: [
              ProfileSection(user: state.user),
              const Divider(),
              const NotificationSettingsSection(),
              const Divider(),
              const DataManagementSection(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('월 예산 설정'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/budget'),
              ),
              _buildLogoutButton(context),
              _buildDeleteAccountButton(context),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text(
        '로그아웃',
        style: TextStyle(color: Colors.red),
      ),
      onTap: () => _showLogoutDialog(context),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Colors.red),
      title: const Text(
        '계정 삭제',
        style: TextStyle(color: Colors.red),
      ),
      onTap: () => _showDeleteAccountDialog(context),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    // 로그아웃 다이얼로그 구현
  }

  void _showDeleteAccountDialog(BuildContext context) {
    // 계정 삭제 다이얼로그 구현
  }
}
