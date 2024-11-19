import 'package:equatable/equatable.dart';
import '../../../domain/entities/expense.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  final String userId;

  const LoadExpenses(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddExpense extends ExpenseEvent {
  final Expense expense;

  const AddExpense(this.expense);

  @override
  List<Object> get props => [expense];
}

class UpdateExpense extends ExpenseEvent {
  final Expense expense;

  const UpdateExpense(this.expense);

  @override
  List<Object> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String expenseId;

  const DeleteExpense(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

class LoadExpensesByDateRange extends ExpenseEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadExpensesByDateRange({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [userId, startDate, endDate];
}

class LoadExpensesByCategory extends ExpenseEvent {
  final String userId;
  final String category;

  const LoadExpensesByCategory({
    required this.userId,
    required this.category,
  });

  @override
  List<Object> get props => [userId, category];
}
