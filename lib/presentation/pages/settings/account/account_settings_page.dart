import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/domain/entities/user.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_event.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/pages/settings/account/widgets/account_settings_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_getLocalizedLabel(context, 'account_settings')),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: Column(
            children: [
              AccountSettingsList(user: state.user),
              _buildDeleteAccountButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Colors.red),
      title: Text(
        _getLocalizedLabel(context, 'delete_account'),
        style: const TextStyle(color: Colors.red),
      ),
      onTap: () => _showDeleteAccountConfirmation(context),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedLabel(context, 'delete_account_title')),
        content: Text(_getLocalizedLabel(context, 'delete_account_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getLocalizedLabel(context, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<AuthBloc>()
                  .add(const DeleteAccount(language: AppLanguage.korean));
              Navigator.pop(context);
              context.go('/welcome'); // 웰컴 페이지로 리다이렉트
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(_getLocalizedLabel(context, 'delete')),
          ),
        ],
      ),
    );
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'account_settings': {
        AppLanguage.english: 'Account Settings',
        AppLanguage.korean: '계정 설정',
        AppLanguage.japanese: 'アカウント設定',
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
      'delete_account_message': {
        AppLanguage.english: 'All your data will be permanently deleted.',
        AppLanguage.korean: '모든 데이터가 영구적으로 삭제됩니다.',
        AppLanguage.japanese: 'すべてのデータが完全に削除されます。',
      },
      'cancel': {
        AppLanguage.english: 'Cancel',
        AppLanguage.korean: '취소',
        AppLanguage.japanese: 'キャンセル',
      },
      'delete': {
        AppLanguage.english: 'Delete',
        AppLanguage.korean: '삭제',
        AppLanguage.japanese: '削除',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }
}
