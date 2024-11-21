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
    },
    AppLanguage.korean: {
      'continueWithGoogle': 'Google로 계속하기',
      'continueWithApple': 'Apple로 계속하기',
    },
    AppLanguage.japanese: {
      'continueWithGoogle': 'Googleで続ける',
      'continueWithApple': 'Appleで続ける',
    },
  };
}
