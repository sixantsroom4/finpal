import 'package:dartz/dartz.dart';
import '../entities/expense.dart';
import '../../core/errors/failures.dart';

abstract class ExpenseRepository {
  /// 새로운 지출 추가
  Future<Either<Failure, Expense>> addExpense(Expense expense);

  /// 지출 업데이트
  Future<Either<Failure, Expense>> updateExpense(Expense expense);

  /// 지출 삭제
  Future<Either<Failure, void>> deleteExpense(String expenseId);

  /// 특정 사용자의 모든 지출 목록 조회
  Future<Either<Failure, List<Expense>>> getExpenses(String userId);

  /// 특정 기간 동안의 지출 목록 조회
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// 카테고리별 지출 목록 조회
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(
    String userId,
    String category,
  );

  /// 공유된 지출 목록 조회
  Future<Either<Failure, List<Expense>>> getSharedExpenses(String userId);

  /// 특정 지출 상세 정보 조회
  Future<Either<Failure, Expense>> getExpenseById(String expenseId);

  Future<Either<Failure, List<Expense>>> getPreviousMonthExpenses(
      String userId);
  Future<Either<Failure, double>> getMonthlyBudget(String userId);
  Future<Either<Failure, void>> updateMonthlyBudget(
      String userId, double amount);

  Stream<List<Expense>> watchExpenses(String userId);
}
