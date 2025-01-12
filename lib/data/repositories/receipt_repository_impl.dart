// data/repositories/receipt_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../datasources/remote/firebase_storage_remote_data_source.dart';
import '../datasources/remote/gemini_remote_data_source.dart';
import '../models/receipt_model.dart';
import 'package:uuid/uuid.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final FirebaseStorageRemoteDataSource storageDataSource;
  final GeminiRemoteDataSource geminiDataSource;

  ReceiptRepositoryImpl({
    required this.storageDataSource,
    required this.geminiDataSource,
  });

  @override
  Future<Either<Failure, Receipt>> processReceipt(
    String imagePath,
    String userId,
    String userCurrency,
  ) async {
    try {
      // 이미지 업로드
      final imageUrl =
          await storageDataSource.uploadReceiptImage(imagePath, userId);

      // Gemini API로 OCR 처리 및 통화 추출 시도
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          final ocrResult = await geminiDataSource.processReceiptImage(
            imagePath,
          );

          // OCR 결과로 Receipt 생성
          final receipt = ReceiptModel.fromOCRResult(
            id: const Uuid().v4(),
            imageUrl: imageUrl,
            ocrResult: ocrResult,
            userId: userId,
            userCurrency: userCurrency, // 사용자 기본 통화 전달
          );

          // 영수증 저장
          final savedReceipt = await storageDataSource.saveReceipt(receipt);
          return Right(savedReceipt);
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) rethrow;
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      throw ServerException(message: '영수증 처리에 실패했습니다.');
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Receipt>> saveReceipt(Receipt receipt) async {
    try {
      debugPrint('===== 영수증 저장 시작 =====');
      debugPrint('저장할 영수증: $receipt');

      // Receipt를 ReceiptModel로 변환
      final receiptModel =
          receipt is ReceiptModel ? receipt : ReceiptModel.fromEntity(receipt);

      final savedReceipt = await storageDataSource.saveReceipt(receiptModel);

      debugPrint('저장된 영수증: ${savedReceipt.toJson()}');
      return Right(savedReceipt);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Receipt>> updateReceipt(Receipt receipt) async {
    try {
      final receiptModel = ReceiptModel.fromEntity(receipt);
      final updatedReceipt =
          await storageDataSource.updateReceipt(receiptModel);
      return Right(updatedReceipt);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReceipt(String receiptId) async {
    try {
      await storageDataSource.deleteReceipt(receiptId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Receipt>>> getReceipts(String userId) async {
    try {
      final receipts = await storageDataSource.getReceipts(userId);
      return Right(receipts);
    } on DatabaseException catch (e) {
      debugPrint('데이터베이스 에러 발생: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('예상치 못한 에러 발생: $e');
      return Left(ServerFailure('영수증 목록 조회 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Either<Failure, Receipt>> getReceiptById(String receiptId) async {
    try {
      final receipt = await storageDataSource.getReceiptById(receiptId);
      if (receipt == null) {
        return Left(ServerFailure('Receipt not found'));
      }
      return Right(receipt);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Receipt>>> getReceiptsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final receipts = await storageDataSource.getReceiptsByDateRange(
        userId,
        startDate,
        endDate,
      );
      return Right(receipts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Receipt>>> getReceiptsByMerchant(
    String userId,
    String merchantName,
  ) async {
    try {
      final receipts = await storageDataSource.getReceiptsByMerchant(
        userId,
        merchantName,
      );
      return Right(receipts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Receipt?>> getReceiptByExpenseId(
    String expenseId,
  ) async {
    try {
      final receipt = await storageDataSource.getReceiptByExpenseId(expenseId);
      return Right(receipt);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateReceiptExpenseId(
    String receiptId,
    String? expenseId,
  ) async {
    try {
      final receipt = await storageDataSource.getReceiptById(receiptId);
      if (receipt == null) {
        return Left(ServerFailure('영수증을 찾을 수 없습니다.'));
      }

      final updatedReceipt = receipt.copyWith(expenseId: expenseId);
      await storageDataSource.updateReceipt(updatedReceipt);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
