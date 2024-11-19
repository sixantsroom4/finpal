import 'package:dartz/dartz.dart';
import 'package:finpal/core/errors/failures.dart';
import 'package:finpal/core/usecases/usecase.dart';
import 'package:finpal/domain/entities/receipt.dart';
import 'package:finpal/domain/repositories/receipt_repository.dart';

class GetReceiptsByDateRangeParams {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  GetReceiptsByDateRangeParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });
}

class GetReceiptsByDateRangeUseCase
    implements UseCase<List<Receipt>, GetReceiptsByDateRangeParams> {
  final ReceiptRepository repository;

  GetReceiptsByDateRangeUseCase(this.repository);

  @override
  Future<Either<Failure, List<Receipt>>> call(
      GetReceiptsByDateRangeParams params) {
    return repository.getReceiptsByDateRange(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}
