// lib/core/utils/expense_category_constants.dart
import 'package:finpal/core/constants/app_languages.dart';
import 'package:flutter/material.dart';

class FirebaseCollections {
  static const String users = 'users';
  static const String expenses = 'expenses';
  static const String receipts = 'receipts';
  static const String subscriptions = 'subscriptions';
}

class FirebaseStoragePaths {
  static const String receipts = 'receipts';
  static const String profiles = 'profiles';
}

class ExpenseCategoryConstants {
  static const Map<String, Map<AppLanguage, String>> categories = {
    'food': {
      AppLanguage.english: 'Food',
      AppLanguage.korean: '식비',
      AppLanguage.japanese: '食費',
    },
    'transport': {
      AppLanguage.english: 'Transport',
      AppLanguage.korean: '교통',
      AppLanguage.japanese: '交通',
    },
    'shopping': {
      AppLanguage.english: 'Shopping',
      AppLanguage.korean: '쇼핑',
      AppLanguage.japanese: '買物',
    },
    'entertainment': {
      AppLanguage.english: 'Entertainment',
      AppLanguage.korean: '여가',
      AppLanguage.japanese: '娯楽',
    },
    'health': {
      AppLanguage.english: 'Medical',
      AppLanguage.korean: '의료',
      AppLanguage.japanese: '医療',
    },
    'beauty': {
      AppLanguage.english: 'Beauty',
      AppLanguage.korean: '미용',
      AppLanguage.japanese: '美容',
    },
    'utilities': {
      AppLanguage.english: 'Utilities',
      AppLanguage.korean: '공과금',
      AppLanguage.japanese: '公共料金',
    },
    'education': {
      AppLanguage.english: 'Education',
      AppLanguage.korean: '교육',
      AppLanguage.japanese: '教育',
    },
    'savings': {
      AppLanguage.english: 'Savings',
      AppLanguage.korean: '저축',
      AppLanguage.japanese: '貯蓄',
    },
    'travel': {
      AppLanguage.english: 'Travel',
      AppLanguage.korean: '여행',
      AppLanguage.japanese: '旅行',
    },
    'social': {
      AppLanguage.english: 'Social Expenses',
      AppLanguage.korean: '교제비',
      AppLanguage.japanese: '交際費',
    },
    'household': {
      AppLanguage.english: 'Household',
      AppLanguage.korean: '일용품',
      AppLanguage.japanese: '日用品',
    },
    'other': {
      AppLanguage.english: 'Others',
      AppLanguage.korean: '기타',
      AppLanguage.japanese: 'その他',
    },
  };

  static final Map<String, IconData> categoryIcons = {
    'food': Icons.restaurant_outlined,
    'transport': Icons.directions_bus_outlined,
    'shopping': Icons.shopping_cart_outlined,
    'entertainment': Icons.movie_outlined,
    'health': Icons.local_hospital_outlined,
    'beauty': Icons.spa_outlined,
    'utilities': Icons.power_outlined,
    'education': Icons.school_outlined,
    'savings': Icons.savings_outlined,
    'travel': Icons.flight_outlined,
    'social': Icons.people_outlined,
    'household': Icons.home_outlined,
    'other': Icons.category_outlined,
  };

  static List<String> getAll() => categories.keys.toList();

  static String getLocalizedCategory(String key, AppLanguage language) {
    return categories[key]?[language] ??
        categories[key]?[AppLanguage.korean] ??
        key;
  }
}

class PrefsKeys {
  static const String isLoggedIn = 'isLoggedIn';
  static const String userId = 'userId';
  static const String loginProvider = 'loginProvider';
  static const String lastLoginAt = 'lastLoginAt';
}
