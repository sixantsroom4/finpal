import 'package:dartz/dartz.dart';
import 'package:finpal/core/errors/failures.dart';
import 'package:finpal/core/usecases/usecase.dart';
import 'package:finpal/domain/entities/expense.dart';
import 'package:finpal/domain/repositories/expense_repository.dart';

class AddExpenseUseCase implements UseCase<Expense, Expense> {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, Expense>> call(Expense params) {
    return repository.addExpense(params);
  }
}
