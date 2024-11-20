import 'package:dartz/dartz.dart';
import 'package:finpal/core/errors/failures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final SharedPreferences _prefs;

  BudgetRepositoryImpl(this._prefs);

  @override
  Future<Either<Failure, double>> getBudget(String userId) async {
    try {
      final budget = _prefs.getDouble('budget_$userId') ?? 1000000.0;
      return Right(budget);
    } catch (e) {
      return Left(CacheFailure('예산을 불러오는데 실패했습니다.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateBudget(
      String userId, double amount) async {
    try {
      await _prefs.setDouble('budget_$userId', amount);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('예산을 저장하는데 실패했습니다.'));
    }
  }
}
