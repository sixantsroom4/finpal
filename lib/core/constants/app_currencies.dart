import 'package:finpal/core/constants/app_languages.dart';

class AppCurrencies {
  static const Map<String, Map<AppLanguage, String>> currencies = {
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

  static String getLocalizedCurrency(AppLanguage language, String currency) {
    return currencies[currency]?[language] ??
        currencies[currency]![AppLanguage.korean]!;
  }
}
