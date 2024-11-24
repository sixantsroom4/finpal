import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_event.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_state.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_event.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/utils/language_utils.dart';

class AppSettingsSection extends StatelessWidget {
  const AppSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRegistrationBloc, UserRegistrationState>(
      builder: (context, registrationState) {
        return BlocBuilder<AppLanguageBloc, AppLanguageState>(
          builder: (context, languageState) {
            return BlocBuilder<AppSettingsBloc, AppSettingsState>(
              builder: (context, settingsState) {
                final String currentCurrency = settingsState.currency;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                      child: Text(
                        _getLocalizedLabel(context, 'settings'),
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
                      onTap: () => _showLanguageDialog(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.attach_money),
                      title: Text(_getLocalizedLabel(context, 'currency')),
                      subtitle:
                          Text(_getLocalizedCurrency(context, currentCurrency)),
                      onTap: () => _showCurrencyDialog(context),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedLabel(context, 'select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values
              .map(
                (language) => ListTile(
                  title: Text(getLanguageDisplayName(language)),
                  onTap: () {
                    context
                        .read<AppLanguageBloc>()
                        .add(AppLanguageChanged(language));
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
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
      'select_language': {
        AppLanguage.english: 'Select Language',
        AppLanguage.korean: '언어 선택',
        AppLanguage.japanese: '言語選択',
      },
      'select_currency': {
        AppLanguage.english: 'Select Currency',
        AppLanguage.korean: '통화 선택',
        AppLanguage.japanese: '通貨選択',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  String _getLocalizedCurrency(BuildContext context, String currency) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> currencies = {
      'KRW': {
        AppLanguage.english: '🇰🇷 Korean Won (KRW)',
        AppLanguage.korean: '🇰🇷 원화 (KRW)',
        AppLanguage.japanese: '🇰🇷 ウォン (KRW)',
      },
      'JPY': {
        AppLanguage.english: '🇯🇵 Japanese Yen (JPY)',
        AppLanguage.korean: '🇯🇵 엔화 (JPY)',
        AppLanguage.japanese: '🇯🇵 円 (JPY)',
      },
      'USD': {
        AppLanguage.english: '🇺🇸 US Dollar (USD)',
        AppLanguage.korean: '🇺🇸 달러 (USD)',
        AppLanguage.japanese: '🇺🇸 ドル (USD)',
      },
      'EUR': {
        AppLanguage.english: '🇪🇺 Euro (EUR)',
        AppLanguage.korean: '🇪🇺 유로 (EUR)',
        AppLanguage.japanese: '🇪🇺 ユーロ (EUR)',
      },
    };
    return currencies[currency]?[language] ??
        currencies[currency]![AppLanguage.korean]!;
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedLabel(context, 'select_currency')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyItem(context, 'KRW'),
            _buildCurrencyItem(context, 'JPY'),
            _buildCurrencyItem(context, 'USD'),
            _buildCurrencyItem(context, 'EUR'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyItem(BuildContext context, String currency) {
    return ListTile(
      title: Text(_getLocalizedCurrency(context, currency)),
      onTap: () {
        context.read<AppSettingsBloc>().add(UpdateCurrency(currency));
        Navigator.pop(context);
      },
    );
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
}
