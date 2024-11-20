import 'package:dartz/dartz.dart';
import 'package:finpal/core/errors/failures.dart';
import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<Either<Failure, double>> getBudget(String userId);
  Future<Either<Failure, void>> updateBudget(String userId, double amount);
}
