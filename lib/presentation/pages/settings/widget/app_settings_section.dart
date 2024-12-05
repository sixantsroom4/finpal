import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_event.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_state.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_event.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_state.dart';
import 'package:finpal/presentation/pages/settings/widget/setting_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/utils/language_utils.dart';
import 'package:finpal/core/utils/currency_utils.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2C3E50),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Text(
                          _getLocalizedLabel(context, 'settings'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SettingItem(
                        icon: Icons.language,
                        iconColor: const Color(0xFF2C3E50),
                        iconBackgroundColor:
                            const Color(0xFF2C3E50).withOpacity(0.1),
                        title: _getLocalizedLabel(context, 'language'),
                        subtitle: _getLocalizedLanguageName(context),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF2C3E50),
                        ),
                        onTap: () => _showLanguageDialog(context),
                      ),
                      const Divider(height: 1),
                      SettingItem(
                        icon: Icons.attach_money,
                        iconColor: const Color(0xFF2C3E50),
                        iconBackgroundColor:
                            const Color(0xFF2C3E50).withOpacity(0.1),
                        title: _getLocalizedLabel(context, 'currency'),
                        subtitle:
                            _getLocalizedCurrency(context, currentCurrency),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF2C3E50),
                        ),
                        onTap: () => _showCurrencyDialog(context),
                      ),
                    ],
                  ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          _getLocalizedLabel(context, 'select_language'),
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values
              .map((language) => Card(
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      title: Text(
                        getLanguageDisplayName(language),
                        style: const TextStyle(color: Color(0xFF2C3E50)),
                      ),
                      onTap: () {
                        context
                            .read<AppLanguageBloc>()
                            .add(AppLanguageChanged(language));
                        Navigator.pop(context);

                        // 앱 전체 새로고침
                        Phoenix.rebirth(context);
                      },
                    ),
                  ))
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          _getLocalizedLabel(context, 'select_currency'),
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['KRW', 'JPY', 'USD', 'EUR']
              .map((currency) => Card(
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      title: Text(
                        _getLocalizedCurrency(context, currency),
                        style: const TextStyle(color: Color(0xFF2C3E50)),
                      ),
                      onTap: () {
                        context
                            .read<AppSettingsBloc>()
                            .add(UpdateCurrency(currency));
                        Navigator.pop(context);
                      },
                    ),
                  ))
              .toList(),
        ),
      ),
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
