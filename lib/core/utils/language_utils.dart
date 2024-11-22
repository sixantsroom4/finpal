import 'package:finpal/core/constants/app_languages.dart';

String getLanguageDisplayName(AppLanguage language) {
  return language.label;
}

String getGenderText(String gender, AppLanguage language) {
  switch (gender) {
    case 'male':
      switch (language) {
        case AppLanguage.korean:
          return '남성';
        case AppLanguage.english:
          return 'Male';
        case AppLanguage.japanese:
          return '男性';
      }
    case 'female':
      switch (language) {
        case AppLanguage.korean:
          return '여성';
        case AppLanguage.english:
          return 'Female';
        case AppLanguage.japanese:
          return '女性';
      }
    case 'other':
      switch (language) {
        case AppLanguage.korean:
          return '기타';
        case AppLanguage.english:
          return 'Other';
        case AppLanguage.japanese:
          return 'その他';
      }
    default:
      return '-';
  }
}
