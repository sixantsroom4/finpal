import 'package:equatable/equatable.dart';
import '../../../domain/entities/expense.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;
  final double totalAmount;
  final double monthlyBudget;
  final double previousMonthTotal;
  final Map<String, double> categoryTotals;
  final String userId;

  ExpenseLoaded({
    required this.expenses,
    required this.totalAmount,
    required this.monthlyBudget,
    required this.previousMonthTotal,
    required this.categoryTotals,
    required this.userId,
  });

  @override
  List<Object> get props => [
        expenses,
        totalAmount,
        monthlyBudget,
        previousMonthTotal,
        categoryTotals,
        userId
      ];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object> get props => [message];
}

class ExpenseOperationSuccess extends ExpenseState {
  final String message;

  const ExpenseOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
