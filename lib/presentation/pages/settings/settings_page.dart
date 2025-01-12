// lib/presentation/pages/settings/settings_page.dart
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_event.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/pages/customer_service/customer_service_page.dart';
import 'package:finpal/presentation/pages/settings/widget/preferences_section.dart';
import 'package:finpal/presentation/pages/settings/widget/profile_section.dart';
import 'package:finpal/presentation/pages/settings/widget/setting_item.dart';
import 'package:finpal/presentation/pages/settings/widgets/notification_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';

import 'widgets/data_management_section.dart';
import 'widget/app_settings_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getLocalizedLabel(context, 'settings'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
              const AppSettingsSection(),
              // const Divider(),
              // const NotificationSettingsSection(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text(_getLocalizedLabel(context, 'customer_service')),
                onTap: () => context.push('/settings/customer-service'),
              ),
              // const DataManagementSection(),
              // const Divider(),
              Card(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C3E50),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Text(
                        _getLocalizedBudgetTitle(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SettingItem(
                      icon: Icons.account_balance_wallet,
                      iconColor: const Color(0xFF2C3E50),
                      iconBackgroundColor:
                          const Color(0xFF2C3E50).withOpacity(0.1),
                      title: _getLocalizedLabel(context, 'monthly_budget'),
                      // subtitle: _getLocalizedLabel(context, 'budget_settings'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF2C3E50),
                      ),
                      onTap: () => context.push('/settings/budget'),
                    ),
                  ],
                ),
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

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'settings': {
        AppLanguage.english: 'Settings',
        AppLanguage.korean: '설정',
        AppLanguage.japanese: '設定',
      },
      'login_required': {
        AppLanguage.english: 'Login Required',
        AppLanguage.korean: '로그인이 필요합니다',
        AppLanguage.japanese: 'ログインが必要です',
      },
      'monthly_budget': {
        AppLanguage.english: 'Monthly Budget',
        AppLanguage.korean: '월 예산 설정',
        AppLanguage.japanese: '月次予算設定',
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
      'delete_account_title': {
        AppLanguage.english: 'Delete Account',
        AppLanguage.korean: '계정 삭제',
        AppLanguage.japanese: 'アカウント削除',
      },
      'delete_account_warning': {
        AppLanguage.english: 'This action cannot be undone.',
        AppLanguage.korean: '이 작업은 취소할 수 없습니다.',
        AppLanguage.japanese: 'この操作は取り消すことができません。',
      },
      'delete_account_confirmation': {
        AppLanguage.english:
            '• All expenses and receipts\n• Subscription information\n• Account settings and preferences',
        AppLanguage.korean: '• 모든 지출 및 영수증\n• 구독 정보\n• 계정 설정 및 환경설정',
        AppLanguage.japanese: '• すべての支出とレシート\n• サブスクリプション情報\n• アカウント設定と環境設定',
      },
      'delete': {
        AppLanguage.english: 'Delete',
        AppLanguage.korean: '삭제',
        AppLanguage.japanese: '削除',
      },
      'cancel': {
        AppLanguage.english: 'Cancel',
        AppLanguage.korean: '취소',
        AppLanguage.japanese: 'キャンセル',
      },
      'logout_confirmation': {
        AppLanguage.english: 'Are you sure you want to logout?',
        AppLanguage.korean: '로그아웃 하시겠습니까?',
        AppLanguage.japanese: 'ログアウトしますか？',
      },
      'customer_service': {
        AppLanguage.english: 'Customer Service',
        AppLanguage.korean: '고객 지원',
        AppLanguage.japanese: 'カスタマーサービス',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  String _getLocalizedBudgetTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    final currency = context.read<AppSettingsBloc>().state.currency;

    final Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Monthly Budget ($currency)',
      AppLanguage.korean: '월 예산 ($currency)',
      AppLanguage.japanese: '月予算 ($currency)',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedLabel(context, 'logout')),
        content: Text(_getLocalizedLabel(context, 'logout_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getLocalizedLabel(context, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignedOut());
              Navigator.pop(context);
            },
            child: Text(_getLocalizedLabel(context, 'logout')),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _getLocalizedLabel(context, 'delete_account_title'),
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getLocalizedLabel(context, 'delete_account_warning')),
            const SizedBox(height: 16),
            Text(
              _getLocalizedLabel(context, 'delete_account_confirmation'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _getLocalizedLabel(context, 'cancel'),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              final language = context.read<AppLanguageBloc>().state.language;
              context.read<AuthBloc>().add(DeleteAccount(language: language));
              Navigator.pop(context);
              context.go('/welcome');
            },
            child: Text(
              _getLocalizedLabel(context, 'delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
