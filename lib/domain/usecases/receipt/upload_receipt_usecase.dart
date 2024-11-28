// domain/usecases/receipt/upload_receipt_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/receipt.dart';
import '../../repositories/receipt_repository.dart';

class UploadReceiptParams {
  final String imagePath;
  final String userId;
  final String? merchantName;
  final DateTime? receiptDate;
  final String? expenseId;
  final String userCurrency;

  UploadReceiptParams({
    required this.imagePath,
    required this.userId,
    required this.userCurrency,
    this.merchantName,
    this.receiptDate,
    this.expenseId,
  });
}

class UploadReceiptUseCase implements UseCase<Receipt, UploadReceiptParams> {
  final ReceiptRepository repository;

  UploadReceiptUseCase(this.repository);

  @override
  Future<Either<Failure, Receipt>> call(UploadReceiptParams params) async {
    try {
      // 영수증 처리 및 OCR
      final result = await repository.processReceipt(
        params.imagePath,
        params.userId,
        params.userCurrency,
      );

      return result.fold(
        (failure) => Left(failure),
        (receipt) async {
          // OCR 처리된 영수증 저장
          final saveResult = await repository.saveReceipt(receipt);
          return saveResult;
        },
      );
    } catch (e) {
      return Left(ServerFailure('영수증 처리 실패: ${e.toString()}'));
    }
  }
}
