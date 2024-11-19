import 'package:dartz/dartz.dart';
import 'package:finpal/core/errors/failures.dart';
import 'package:finpal/core/usecases/usecase.dart';
import 'package:finpal/domain/entities/expense.dart';
import 'package:finpal/domain/repositories/expense_repository.dart';

class GetExpensesParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? category;

  GetExpensesParams({
    required this.userId,
    this.startDate,
    this.endDate,
    this.category,
  });
}

class GetExpensesUseCase implements UseCase<List<Expense>, GetExpensesParams> {
  final ExpenseRepository repository;

  GetExpensesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(GetExpensesParams params) {
    if (params.startDate != null && params.endDate != null) {
      return repository.getExpensesByDateRange(
        params.userId,
        params.startDate!,
        params.endDate!,
      );
    } else if (params.category != null) {
      return repository.getExpensesByCategory(params.userId, params.category!);
    }
    return repository.getExpenses(params.userId);
  }
}
