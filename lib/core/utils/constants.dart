// lib/core/utils/constants.dart
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

class CategoryConstants {
  static const food = '식비';
  static const transport = '교통';
  static const shopping = '쇼핑';
  static const entertainment = '여가';
  static const health = '의료';
  static const other = '기타';

  static List<String> getAll() => [
        food,
        transport,
        shopping,
        entertainment,
        health,
        other,
      ];
}

class PrefsKeys {
  static const String isLoggedIn = 'isLoggedIn';
  static const String userId = 'userId';
  static const String loginProvider = 'loginProvider';
  static const String lastLoginAt = 'lastLoginAt';
}
