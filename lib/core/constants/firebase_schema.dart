class FirebaseSchema {
  // 컬렉션 이름
  static const String users = 'users';
  static const String expenses = 'expenses';
  static const String receipts = 'receipts';
  static const String subscriptions = 'subscriptions';

  // 스키마 정의
  static const Map<String, Map<String, String>> schemas = {
    expenses: {
      'id': 'string',
      'amount': 'number',
      'currency': 'string',
      'description': 'string',
      'date': 'timestamp',
      'category': 'string',
      'userId': 'string',
      'receiptUrl': 'string?',
      'receiptId': 'string?',
      'isShared': 'boolean',
      'sharedWith': 'array?',
      'splitAmounts': 'map?',
      'isSubscription': 'boolean',
      'subscriptionId': 'string?',
      'createdAt': 'timestamp',
    },
    receipts: {
      'id': 'string',
      'imageUrl': 'string',
      'date': 'timestamp',
      'merchantName': 'string',
      'totalAmount': 'number',
      'currency': 'string',
      'items': 'array',
      'userId': 'string',
      'expenseId': 'string?',
    },
    subscriptions: {
      'id': 'string',
      'name': 'string',
      'amount': 'number',
      'currency': 'string',
      'startDate': 'timestamp',
      'endDate': 'timestamp?',
      'billingCycle': 'string',
      'billingDay': 'number',
      'category': 'string',
      'userId': 'string',
      'isActive': 'boolean',
    },
  };
}
