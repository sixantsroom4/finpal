import 'package:equatable/equatable.dart';
import 'package:finpal/data/models/expense_model.dart';
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
  final ExpenseModel expenseModel;

  const AddExpense({required this.expenseModel});

  @override
  List<Object> get props => [expenseModel];
}

class UpdateExpense extends ExpenseEvent {
  final Expense expense;

  const UpdateExpense(this.expense);

  @override
  List<Object> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String id;
  final String? userId;
  final String expenseId;

  const DeleteExpense({required this.id, this.userId, required this.expenseId});

  @override
  List<Object?> get props => [id, userId, expenseId];
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

class UpdateMonthlyBudget extends ExpenseEvent {
  final String userId;
  final double amount;

  const UpdateMonthlyBudget({
    required this.userId,
    required this.amount,
  });
}

class UpdateExpenseList extends ExpenseEvent {
  final List<Expense> expenses;

  const UpdateExpenseList(this.expenses);

  @override
  List<Object> get props => [expenses];
}
