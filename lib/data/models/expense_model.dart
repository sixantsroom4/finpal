// data/models/expense_model.dart
import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required String id,
    required double amount,
    required String description,
    required DateTime date,
    required String category,
    required String userId,
    String? receiptUrl,
    String? receiptId,
    bool isShared = false,
    List<String>? sharedWith,
    Map<String, double>? splitAmounts,
  }) : super(
          id: id,
          amount: amount,
          description: description,
          date: date,
          category: category,
          userId: userId,
          receiptUrl: receiptUrl,
          receiptId: receiptId,
          isShared: isShared,
          sharedWith: sharedWith,
          splitAmounts: splitAmounts,
        );

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
      'userId': userId,
      'receiptUrl': receiptUrl,
      'receiptId': receiptId,
      'isShared': isShared,
      'sharedWith': sharedWith,
      'splitAmounts': splitAmounts,
    };
  }

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      amount: expense.amount,
      description: expense.description,
      date: expense.date,
      category: expense.category,
      userId: expense.userId,
      receiptUrl: expense.receiptUrl,
      receiptId: expense.receiptId,
      isShared: expense.isShared,
      sharedWith: expense.sharedWith,
      splitAmounts: expense.splitAmounts,
    );
  }
}
