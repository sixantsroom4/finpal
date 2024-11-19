// domain/repositories/receipt_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/receipt.dart';
import '../../core/errors/failures.dart';

abstract class ReceiptRepository {
  /// 영수증 이미지 업로드 및 OCR 처리
  Future<Either<Failure, Receipt>> processReceipt(
    String imagePath,
    String userId,
  );

  /// OCR 처리된 영수증 정보 저장
  Future<Either<Failure, Receipt>> saveReceipt(Receipt receipt);

  /// 영수증 정보 업데이트
  Future<Either<Failure, Receipt>> updateReceipt(Receipt receipt);

  /// 영수증 삭제
  Future<Either<Failure, void>> deleteReceipt(String receiptId);

  /// 특정 사용자의 모든 영수증 목록 조회
  Future<Either<Failure, List<Receipt>>> getReceipts(String userId);

  /// 특정 영수증 상세 정보 조회
  Future<Either<Failure, Receipt>> getReceiptById(String receiptId);

  /// 날짜 범위로 영수증 조회
  Future<Either<Failure, List<Receipt>>> getReceiptsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// 특정 가맹점의 영수증 조회
  Future<Either<Failure, List<Receipt>>> getReceiptsByMerchant(
    String userId,
    String merchantName,
  );

  /// 특정 지출에 연결된 영수증 조회
  Future<Either<Failure, Receipt?>> getReceiptByExpenseId(String expenseId);
}
