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
  final Map<String, double> previousMonthCategoryTotals;
  final Map<String, double> monthlyTotals;
  final String userId;

  const ExpenseLoaded({
    required this.expenses,
    required this.totalAmount,
    required this.monthlyBudget,
    required this.previousMonthTotal,
    required this.categoryTotals,
    required this.previousMonthCategoryTotals,
    required this.monthlyTotals,
    required this.userId,
  });

  @override
  List<Object> get props => [
        expenses,
        totalAmount,
        monthlyBudget,
        previousMonthTotal,
        categoryTotals,
        previousMonthCategoryTotals,
        monthlyTotals,
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
