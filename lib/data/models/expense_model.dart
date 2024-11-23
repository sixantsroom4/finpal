// data/models/expense_model.dart
import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  ExpenseModel({
    required String id,
    required double amount,
    required String currency,
    required String description,
    required DateTime date,
    required String category,
    required String userId,
    String? receiptUrl,
    String? receiptId,
    bool isShared = false,
    List<String>? sharedWith,
    Map<String, double>? splitAmounts,
    bool isSubscription = false,
    String? subscriptionId,
    DateTime? createdAt,
  }) : super(
          id: id,
          amount: amount,
          currency: currency,
          description: description,
          date: date,
          category: category,
          userId: userId,
          receiptUrl: receiptUrl,
          receiptId: receiptId,
          isShared: isShared,
          sharedWith: sharedWith,
          splitAmounts: splitAmounts,
          isSubscription: isSubscription,
          subscriptionId: subscriptionId,
          createdAt: createdAt,
        );

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'KRW',
      description: json['description'],
      date: DateTime.parse(json['date']),
      category: json['category'],
      userId: json['userId'],
      receiptUrl: json['receiptUrl'],
      receiptId: json['receiptId'],
      isShared: json['isShared'] ?? false,
      sharedWith: json['sharedWith'] != null
          ? List<String>.from(json['sharedWith'])
          : null,
      splitAmounts: json['splitAmounts'] != null
          ? Map<String, double>.from(json['splitAmounts'])
          : null,
      isSubscription: json['isSubscription'] ?? false,
      subscriptionId: json['subscriptionId'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
      'userId': userId,
      'receiptUrl': receiptUrl,
      'receiptId': receiptId,
      'isShared': isShared,
      'sharedWith': sharedWith,
      'splitAmounts': splitAmounts,
      'isSubscription': isSubscription,
      'subscriptionId': subscriptionId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      amount: expense.amount,
      currency: expense.currency,
      description: expense.description,
      date: expense.date,
      category: expense.category,
      userId: expense.userId,
      receiptUrl: expense.receiptUrl,
      receiptId: expense.receiptId,
      isShared: expense.isShared,
      sharedWith: expense.sharedWith,
      splitAmounts: expense.splitAmounts,
      isSubscription: expense.isSubscription,
      subscriptionId: expense.subscriptionId,
      createdAt: expense.createdAt,
    );
  }

  ExpenseModel copyWith({
    String? id,
    double? amount,
    String? currency,
    String? description,
    DateTime? date,
    String? category,
    String? userId,
    String? receiptUrl,
    String? receiptId,
    bool? isShared,
    List<String>? sharedWith,
    Map<String, double>? splitAmounts,
    bool? isSubscription,
    String? subscriptionId,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      receiptId: receiptId ?? this.receiptId,
      isShared: isShared ?? this.isShared,
      sharedWith: sharedWith ?? this.sharedWith,
      splitAmounts: splitAmounts ?? this.splitAmounts,
      isSubscription: isSubscription ?? this.isSubscription,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
