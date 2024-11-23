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
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

import 'widgets/data_management_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'settings': {
        AppLanguage.english: 'Settings',
        AppLanguage.korean: '설정',
        AppLanguage.japanese: '設定',
      },
      'login_required': {
        AppLanguage.english: 'Login required',
        AppLanguage.korean: '로그인이 필요합니다',
        AppLanguage.japanese: 'ログインが必要です',
      },
      'budget_settings': {
        AppLanguage.english: 'Monthly Budget Settings',
        AppLanguage.korean: '월 예산 설정',
        AppLanguage.japanese: '月予算設定',
      },
      'logout': {
        AppLanguage.english: 'Logout',
        AppLanguage.korean: '로그아웃',
        AppLanguage.japanese: 'ログアウト',
      },
      'delete_account': {
        AppLanguage.english: 'Delete Account',
        AppLanguage.korean: '계정 삭제',
        AppLanguage.japanese: 'アカウント削除',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedLabel(context, 'settings')),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) {
            return Center(
              child: Text(_getLocalizedLabel(context, 'login_required')),
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
                title: Text(_getLocalizedLabel(context, 'budget_settings')),
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
      title: Text(
        _getLocalizedLabel(context, 'logout'),
        style: const TextStyle(color: Colors.red),
      ),
      onTap: () => _showLogoutDialog(context),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Colors.red),
      title: Text(
        _getLocalizedLabel(context, 'delete_account'),
        style: const TextStyle(color: Colors.red),
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
