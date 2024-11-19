import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Expense extends Equatable {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final String category;
  final String? receiptUrl;
  final String userId;
  final bool isShared;
  final List<String>? sharedWith;
  final Map<String, double>? splitAmounts;

  const Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
    required this.userId,
    this.receiptUrl,
    this.isShared = false,
    this.sharedWith,
    this.splitAmounts,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        description,
        date,
        category,
        receiptUrl,
        userId,
        isShared,
        sharedWith,
        splitAmounts,
      ];

  factory Expense.create({
    required double amount,
    required String description,
    required String category,
    required String userId,
    String? receiptUrl,
    bool isShared = false,
    List<String>? sharedWith,
    Map<String, double>? splitAmounts,
  }) {
    return Expense(
      id: const Uuid().v4(),
      amount: amount,
      description: description,
      date: DateTime.now(),
      category: category,
      userId: userId,
      receiptUrl: receiptUrl,
      isShared: isShared,
      sharedWith: sharedWith,
      splitAmounts: splitAmounts,
    );
  }
}
