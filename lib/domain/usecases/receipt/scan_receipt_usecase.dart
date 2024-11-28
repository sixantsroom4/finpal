import 'package:dartz/dartz.dart';
import 'package:finpal/core/errors/failures.dart';
import 'package:finpal/core/usecases/usecase.dart';
import 'package:finpal/domain/entities/receipt.dart';
import 'package:finpal/domain/repositories/receipt_repository.dart';

class ScanReceiptParams {
  final String imagePath;
  final String userId;
  final String userCurrency;

  ScanReceiptParams({
    required this.imagePath,
    required this.userId,
    required this.userCurrency,
  });
}

class ScanReceiptUseCase implements UseCase<Receipt, ScanReceiptParams> {
  final ReceiptRepository repository;

  ScanReceiptUseCase(this.repository);

  @override
  Future<Either<Failure, Receipt>> call(ScanReceiptParams params) {
    return repository.processReceipt(
      params.imagePath,
      params.userId,
      params.userCurrency,
    );
  }
}
