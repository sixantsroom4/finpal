import 'package:finpal/core/constants/app_languages.dart';

class UserSettings {
  final AppLanguage language;
  final String currency;
  final Map<String, bool> notifications;

  const UserSettings({
    this.language = AppLanguage.korean,
    this.currency = 'KRW',
    this.notifications = const {},
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      language: AppLanguage.values.firstWhere(
        (e) => e.name == (json['language'] ?? 'korean'),
        orElse: () => AppLanguage.korean,
      ),
      currency: json['currency'] ?? 'KRW',
      notifications: Map<String, bool>.from(json['notifications'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language.name,
        'currency': currency,
        'notifications': notifications,
      };
}
