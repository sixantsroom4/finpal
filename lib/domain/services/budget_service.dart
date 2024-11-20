import 'package:dartz/dartz.dart';
import 'package:finpal/core/errors/failures.dart';

import '../repositories/budget_repository.dart';

class BudgetService {
  final BudgetRepository _budgetRepository;

  BudgetService(this._budgetRepository);

  Future<Either<Failure, double>> getBudget(String userId) {
    return _budgetRepository.getBudget(userId);
  }

  Future<Either<Failure, void>> updateBudget(String userId, double amount) {
    return _budgetRepository.updateBudget(userId, amount);
  }
}
