// lib/presentation/pages/settings/widgets/preferences_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class PreferencesSection extends StatelessWidget {
  const PreferencesSection({super.key});

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'preferences': {
        AppLanguage.english: 'General',
        AppLanguage.korean: '일반',
        AppLanguage.japanese: '一般',
      },
      'language': {
        AppLanguage.english: 'Language',
        AppLanguage.korean: '언어',
        AppLanguage.japanese: '言語',
      },
      'currency': {
        AppLanguage.english: 'Currency',
        AppLanguage.korean: '통화',
        AppLanguage.japanese: '通貨',
      },
      'theme': {
        AppLanguage.english: 'Theme',
        AppLanguage.korean: '테마',
        AppLanguage.japanese: 'テーマ',
      },
      'system_default': {
        AppLanguage.english: 'System Default',
        AppLanguage.korean: '시스템 설정',
        AppLanguage.japanese: 'システム設定',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  String _getLocalizedLanguageName(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> names = {
      AppLanguage.english: 'English',
      AppLanguage.korean: '한국어',
      AppLanguage.japanese: '日本語',
    };
    return names[language] ?? names[AppLanguage.korean]!;
  }

  String _getLocalizedCurrencyName(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    final currencies = {
      AppLanguage.english: r'USD ($)',
      AppLanguage.korean: r'KRW (₩)',
      AppLanguage.japanese: r'JPY (¥)',
    };
    return currencies[language] ?? currencies[AppLanguage.korean]!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            _getLocalizedLabel(context, 'preferences'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(_getLocalizedLabel(context, 'language')),
          subtitle: Text(_getLocalizedLanguageName(context)),
          onTap: () {
            // TODO: 언어 설정 구현
          },
        ),
        ListTile(
          leading: const Icon(Icons.attach_money),
          title: Text(_getLocalizedLabel(context, 'currency')),
          subtitle: Text(_getLocalizedCurrencyName(context)),
          onTap: () {
            // TODO: 통화 설정 구현
          },
        ),
        ListTile(
          leading: const Icon(Icons.color_lens),
          title: Text(_getLocalizedLabel(context, 'theme')),
          subtitle: Text(_getLocalizedLabel(context, 'system_default')),
          onTap: () {
            // TODO: 테마 설정 구현
          },
        ),
      ],
    );
  }
}
