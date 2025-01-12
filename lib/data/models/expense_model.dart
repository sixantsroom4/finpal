// data/models/expense_model.dart

import 'package:cloud_firestore/cloud_firestore.dart'; // Timestamp 처리를 위해 필요
import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  final String? subscriptionId;

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
    this.subscriptionId,
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
    // ─────────────────────────────────────
    // Firestore에선 date/createdAt이 Timestamp로 들어올 수 있으므로 안전 처리
    // ─────────────────────────────────────

    // 1) date 필드 처리
    final dynamic dateRaw = json['date'];
    late DateTime parsedDate;
    if (dateRaw is Timestamp) {
      // Firestore Timestamp → DateTime
      parsedDate = dateRaw.toDate();
    } else if (dateRaw is String) {
      // String → DateTime
      parsedDate = DateTime.parse(dateRaw);
    } else {
      // null 또는 다른 타입이면 에러처리 or 기본값 사용
      throw FormatException("Invalid or missing 'date' field: $dateRaw");
    }

    // 2) createdAt 필드 처리 (nullable)
    final dynamic createdAtRaw = json['createdAt'];
    DateTime? parsedCreatedAt;
    if (createdAtRaw == null) {
      parsedCreatedAt = null;
    } else if (createdAtRaw is Timestamp) {
      parsedCreatedAt = createdAtRaw.toDate();
    } else if (createdAtRaw is String) {
      parsedCreatedAt = DateTime.parse(createdAtRaw);
    } else {
      // createdAt이 이상한 타입이면 null 처리 or 예외
      parsedCreatedAt = null;
    }

    return ExpenseModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'KRW',
      description: json['description'],
      date: parsedDate,
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
      createdAt: parsedCreatedAt,
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
