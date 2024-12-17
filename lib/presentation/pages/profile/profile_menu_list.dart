// lib/presentation/pages/profile/widgets/profile_menu_list.dart
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/pages/onboarding/widgets/terms_content.dart';
import 'package:finpal/presentation/services/terms_service.dart';
import 'package:flutter/material.dart';
import 'package:finpal/domain/entities/user.dart';
import 'package:finpal/presentation/bloc/auth/auth_event.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';

class ProfileMenuList extends StatefulWidget {
  const ProfileMenuList({super.key});

  @override
  State<ProfileMenuList> createState() => _ProfileMenuListState();
}

class _ProfileMenuListState extends State<ProfileMenuList> {
  late List<Map<String, String>> _terms;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  void _loadTerms() {
    final language = context.read<AppLanguageBloc>().state.language;
    setState(() {
      _terms = TermsService.getTermsByLanguage(language);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          context: context,
          icon: Icons.settings_outlined,
          label: 'app_settings',
          onTap: () => context.go('/settings'),
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.description_outlined,
          label: 'terms_and_policies',
          onTap: () => _showTermsBottomSheet(context),
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.help_outline,
          label: 'customer_service',
          onTap: () => context.push('/settings/customer-service'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Divider(height: 32),
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.logout,
          label: 'logout',
          isDestructive: true,
          onTap: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : const Color(0xFF2C3E50);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: color),
      title: Text(
        _getLocalizedLabel(context, label),
        style: TextStyle(
          fontSize: 16,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? Colors.red : Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'app_settings': {
        AppLanguage.english: 'App Settings',
        AppLanguage.korean: '앱 설정',
        AppLanguage.japanese: 'アプリ設定',
      },
      'account_settings': {
        AppLanguage.english: 'Account Settings',
        AppLanguage.korean: '계정 설정',
        AppLanguage.japanese: 'アカウント設定',
      },
      'customer_service': {
        AppLanguage.english: 'Customer Service',
        AppLanguage.korean: '고객 센터',
        AppLanguage.japanese: 'カスタマーサービス',
      },
      'terms_and_policies': {
        AppLanguage.english: 'Terms and Policies',
        AppLanguage.korean: '약관 및 정책',
        AppLanguage.japanese: '利用規約とポリシー',
      },
      'logout': {
        AppLanguage.english: 'Logout',
        AppLanguage.korean: '로그아웃',
        AppLanguage.japanese: 'ログアウト',
      },
      'terms_title': {
        AppLanguage.english: 'Terms and Policies',
        AppLanguage.korean: '약관 및 정책',
        AppLanguage.japanese: '利用規約とポリシー',
      },
      'logout_title': {
        AppLanguage.english: 'Logout',
        AppLanguage.korean: '로그아웃',
        AppLanguage.japanese: 'ログアウト',
      },
      'logout_message': {
        AppLanguage.english: 'Are you sure you want to logout?',
        AppLanguage.korean: '정말 로그아웃 하시겠습니까?',
        AppLanguage.japanese: '本当にログアウトしますか？',
      },
      'cancel': {
        AppLanguage.english: 'Cancel',
        AppLanguage.korean: '취소',
        AppLanguage.japanese: 'キャンセル',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  void _showTermsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getLocalizedLabel(context, 'terms_title'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    TermsContent(
                      expandedItems: const {},
                      terms: _terms,
                      onItemTap: (_) {},
                      readOnly: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedLabel(context, 'logout_title')),
        content: Text(_getLocalizedLabel(context, 'logout_message')),
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
}
