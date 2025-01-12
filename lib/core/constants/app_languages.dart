enum AppLanguage {
  english('English', 'en'),
  korean('한국어', 'ko'),
  japanese('日本語', 'ja');

  final String label;
  final String code;
  const AppLanguage(this.label, this.code);
}

class LocalizedStrings {
  static const Map<AppLanguage, Map<String, String>> translations = {
    AppLanguage.english: {
      'continueWithGoogle': 'Continue with Google',
      'continueWithApple': 'Continue with Apple',
      'birthdateConsent':
          'We collect your birthdate information to verify your age. Do you agree?',
      'subscriptionFee': 'Subscription Fee',
    },
    AppLanguage.korean: {
      'continueWithGoogle': 'Google로 계속하기',
      'continueWithApple': 'Apple로 계속하기',
      'birthdateConsent': '연령 확인을 위해 생년월일 정보를 수집합니다. 동의하십니까?',
      'subscriptionFee': '구독료',
    },
    AppLanguage.japanese: {
      'continueWithGoogle': 'Googleで続ける',
      'continueWithApple': 'Appleで続ける',
      'birthdateConsent': '年齢確認のために生年月日情報を収集します。 同意しますか？',
      'subscriptionFee': 'サブスクリプション料金',
    },
  };
}
