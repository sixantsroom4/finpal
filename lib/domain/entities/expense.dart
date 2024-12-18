import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Expense extends Equatable {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final String category;
  final String userId;
  final String? receiptUrl;
  final String? receiptId;
  final bool isShared;
  final List<String>? sharedWith;
  final Map<String, double>? splitAmounts;
  final bool isSubscription;
  final String? subscriptionId;
  final DateTime createdAt;
  final String currency;
  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
    required this.userId,
    this.receiptUrl,
    this.receiptId,
    this.isShared = false,
    this.sharedWith,
    this.splitAmounts,
    this.isSubscription = false,
    this.subscriptionId,
    DateTime? createdAt,
    required this.currency,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  List<Object?> get props => [
        id,
        amount,
        description,
        date,
        category,
        userId,
        receiptUrl,
        receiptId,
        isShared,
        sharedWith,
        splitAmounts,
        isSubscription,
        subscriptionId,
        createdAt,
        currency,
      ];

  factory Expense.create({
    required double amount,
    required String description,
    required String category,
    required String userId,
    String? receiptUrl,
    String? receiptId,
    bool isShared = false,
    List<String>? sharedWith,
    Map<String, double>? splitAmounts,
    bool isSubscription = false,
    String? subscriptionId,
    required String currency,
  }) {
    return Expense(
      id: const Uuid().v4(),
      amount: amount,
      description: description,
      date: DateTime.now(),
      category: category,
      userId: userId,
      receiptUrl: receiptUrl,
      receiptId: receiptId,
      isShared: isShared,
      sharedWith: sharedWith,
      splitAmounts: splitAmounts,
      isSubscription: isSubscription,
      subscriptionId: subscriptionId,
      createdAt: DateTime.now(),
      currency: currency,
    );
  }

  Expense copyWith({
    String? id,
    double? amount,
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
    String? currency,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
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
      currency: currency ?? this.currency,
    );
  }
}
