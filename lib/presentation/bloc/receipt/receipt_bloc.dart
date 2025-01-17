import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/data/models/receipt_model.dart';
import 'package:finpal/domain/usecases/receipt/scan_receipt_usecase.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/repositories/receipt_repository.dart';
import 'receipt_event.dart';
import 'receipt_state.dart';
import '../../../domain/entities/receipt.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  final ReceiptRepository _receiptRepository;
  final _getIt = GetIt.instance;
  final _receiptController = StreamController<void>.broadcast();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<void> get receiptStream => _receiptController.stream;

  ReceiptBloc({
    required ReceiptRepository receiptRepository,
  })  : _receiptRepository = receiptRepository,
        super(ReceiptInitial()) {
    on<ScanReceipt>(_onScanReceipt);
    on<SaveReceipt>(_onSaveReceipt);
    on<UpdateReceipt>(_onUpdateReceipt);
    on<DeleteReceipt>(_onDeleteReceipt);
    on<LoadReceipts>(_onLoadReceipts);
    on<LoadReceiptsByDateRange>(_onLoadReceiptsByDateRange);
    on<LoadReceiptsByMerchant>(_onLoadReceiptsByMerchant);
    on<LoadReceiptById>((event, emit) async {
      try {
        debugPrint('영수증 ID로 조회 시도: ${event.receiptId}');
        final result = await _receiptRepository.getReceiptById(event.receiptId);

        await result.fold(
          (failure) async {
            debugPrint('영수증 조회 실패: ${failure.message}');
            emit(ReceiptError(failure.message));
          },
          (receipt) async {
            debugPrint('영수증 조회 성공: $receipt');
            if (receipt == null) {
              emit(const ReceiptError('영수증을 찾을 수 없습니다.'));
              return;
            }
            emit(ReceiptLoaded(
              receipts: [receipt],
              merchantTotals: _calculateMerchantTotals([receipt]),
              totalAmount: receipt.totalAmount,
            ));
          },
        );
      } catch (e) {
        debugPrint('영수증 조회 중 예외 발생: $e');
        emit(ReceiptError(e.toString()));
      }
    });
    on<SortReceipts>((event, emit) async {
      if (state is ReceiptLoaded) {
        final currentState = state as ReceiptLoaded;
        final sortedReceipts = List<Receipt>.from(currentState.receipts);

        switch (event.sortOption) {
          case SortOption.date:
            sortedReceipts.sort((a, b) => b.date.compareTo(a.date));
            break;
          case SortOption.store:
            sortedReceipts
                .sort((a, b) => a.merchantName.compareTo(b.merchantName));
            break;
          case SortOption.amount:
            sortedReceipts
                .sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
            break;
        }

        emit(ReceiptLoaded(
          receipts: sortedReceipts,
          merchantTotals: currentState.merchantTotals,
          totalAmount: currentState.totalAmount,
          currentSortOption: event.sortOption,
        ));
      }
    });
    on<CancelReceiptScan>((event, emit) async {
      await _onCancelReceiptScan(event, emit);
    });
  }

  Future<void> _onScanReceipt(
    ScanReceipt event,
    Emitter<ReceiptState> emit,
  ) async {
    debugPrint('===== 영수증 스캔 시작 =====');
    debugPrint('이미지 경로: ${event.imagePath}');
    debugPrint('사용자 ID: ${event.userId}');

    emit(ReceiptScanInProgress());

    try {
      final result = await _receiptRepository.processReceipt(
        event.imagePath,
        event.userId,
        event.userCurrency,
      );

      await result.fold(
        (failure) async {
          debugPrint('영수증 처리 실패: ${failure.message}');
          emit(ReceiptError(failure.message));
        },
        (receipt) async {
          debugPrint('영수증 처리 성공: $receipt');
          emit(ReceiptScanSuccess(receipt));
        },
      );
    } catch (e) {
      debugPrint('영수증 처리 중 예외 발생: $e');
      emit(ReceiptError('영수증 처리 중 오류가 발생했습니다.'));
    }
  }

  Future<void> _onSaveReceipt(
    SaveReceipt event,
    Emitter<ReceiptState> emit,
  ) async {
    try {
      final result = await _receiptRepository.saveReceipt(event.receipt);

      await result.fold(
        (failure) async {
          emit(ReceiptError(failure.message));
        },
        (savedReceipt) async {
          _receiptController.add(null);
          emit(const ReceiptOperationSuccess('receipt_saved_success'));
          add(LoadReceipts(event.receipt.userId));
        },
      );
    } catch (e) {
      emit(ReceiptError(e.toString()));
    }
  }

  Future<void> _onUpdateReceipt(
    UpdateReceipt event,
    Emitter<ReceiptState> emit,
  ) async {
    if (event.receipt.expenseId != null) {
      return;
    }

    emit(ReceiptLoading());
    final result = await _receiptRepository.updateReceipt(event.receipt);

    result.fold(
      (failure) => emit(ReceiptError(failure.message)),
      (receipt) {
        emit(const ReceiptOperationSuccess('receipt_updated_success'));
        add(LoadReceipts(event.receipt.userId));
      },
    );
  }

  Future<void> _onDeleteReceipt(
    DeleteReceipt event,
    Emitter<ReceiptState> emit,
  ) async {
    try {
      if (state is ReceiptLoaded) {
        final currentState = state as ReceiptLoaded;
        emit(ReceiptLoading(
          currentState.receipts,
          currentState.merchantTotals,
          currentState.totalAmount,
        ));
      } else {
        emit(ReceiptLoading());
      }

      final result = await _receiptRepository.deleteReceipt(event.receiptId);

      await result.fold(
        (failure) async {
          emit(ReceiptError(failure.message));
        },
        (_) async {
          if (state is ReceiptLoading) {
            final currentState = state as ReceiptLoading;
            final updatedReceipts = currentState.receipts
                .where((r) => r.id != event.receiptId)
                .toList();

            if (updatedReceipts.isEmpty) {
              emit(const ReceiptEmpty());
            } else {
              final merchantTotals = _calculateMerchantTotals(updatedReceipts);
              final totalAmount = updatedReceipts.fold(
                0.0,
                (sum, receipt) => sum + receipt.totalAmount,
              );

              emit(ReceiptOperationSuccess(
                'receipt_deleted_success',
                receipts: updatedReceipts,
                merchantTotals: merchantTotals,
                totalAmount: totalAmount,
              ));
            }
          }

          _receiptController.add(null);

          final reloadResult =
              await _receiptRepository.getReceipts(event.userId);

          await reloadResult.fold(
            (failure) async {
              emit(ReceiptError(failure.message));
            },
            (receipts) async {
              final merchantTotals = _calculateMerchantTotals(receipts);
              final totalAmount = receipts.fold(
                0.0,
                (sum, receipt) => sum + receipt.totalAmount,
              );

              emit(ReceiptLoaded(
                receipts: receipts,
                merchantTotals: merchantTotals,
                totalAmount: totalAmount,
              ));
            },
          );
        },
      );
    } catch (e) {
      debugPrint('영수증 삭제 중 오류 발생: $e');
      emit(ReceiptError(e.toString()));
    }
  }

  Future<void> _onLoadReceipts(
    LoadReceipts event,
    Emitter<ReceiptState> emit,
  ) async {
    try {
      emit(ReceiptLoading());
      debugPrint('영수증 목록 로드 시도 - 사용자 ID: ${event.userId}');

      final result = await _receiptRepository.getReceipts(event.userId);
      debugPrint('영수증 목록 조회 결과: $result');

      result.fold(
        (failure) {
          debugPrint('영수증 목록 로드 실패: ${failure.message}');
          emit(ReceiptError(failure.message));
        },
        (receipts) {
          if (receipts.isEmpty) {
            debugPrint('영수증이 없습니다');
            emit(const ReceiptEmpty());
            return;
          }

          debugPrint('영수증 ${receipts.length}개 로드됨');
          final totalAmount = receipts.fold(
            0.0,
            (sum, receipt) => sum + receipt.totalAmount,
          );

          final merchantTotals = <String, double>{};
          for (var receipt in receipts) {
            merchantTotals[receipt.merchantName] =
                (merchantTotals[receipt.merchantName] ?? 0.0) +
                    receipt.totalAmount;
          }

          emit(ReceiptLoaded(
            receipts: receipts,
            merchantTotals: merchantTotals,
            totalAmount: totalAmount,
          ));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('영수증 목록 로드 중 예외 발생: $e');
      debugPrint('스택 트레이스: $stackTrace');
      emit(ReceiptError(e.toString()));
    }
  }

  Future<void> _onLoadReceiptsByDateRange(
    LoadReceiptsByDateRange event,
    Emitter<ReceiptState> emit,
  ) async {
    emit(ReceiptLoading());
    final result = await _receiptRepository.getReceiptsByDateRange(
      event.userId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(ReceiptError(failure.message)),
      (receipts) {
        final totalAmount = receipts.fold(
          0.0,
          (sum, receipt) => sum + receipt.totalAmount,
        );

        final merchantTotals = <String, double>{};
        for (var receipt in receipts) {
          merchantTotals[receipt.merchantName] =
              (merchantTotals[receipt.merchantName] ?? 0.0) +
                  receipt.totalAmount;
        }

        emit(ReceiptLoaded(
          receipts: receipts,
          merchantTotals: merchantTotals,
          totalAmount: totalAmount,
        ));
      },
    );
  }

  Future<void> _onLoadReceiptsByMerchant(
    LoadReceiptsByMerchant event,
    Emitter<ReceiptState> emit,
  ) async {
    emit(ReceiptLoading());
    final result = await _receiptRepository.getReceiptsByMerchant(
      event.userId,
      event.merchantName,
    );

    result.fold(
      (failure) => emit(ReceiptError(failure.message)),
      (receipts) {
        final totalAmount = receipts.fold(
          0.0,
          (sum, receipt) => sum + receipt.totalAmount,
        );

        final merchantTotals = <String, double>{};
        merchantTotals[event.merchantName] = totalAmount;

        emit(ReceiptLoaded(
          receipts: receipts,
          merchantTotals: merchantTotals,
          totalAmount: totalAmount,
        ));
      },
    );
  }

  Future<void> _onCancelReceiptScan(
    CancelReceiptScan event,
    Emitter<ReceiptState> emit,
  ) async {
    if (event.imageUrl != null) {
      // Firebase Storage에서 이미지 삭제
      await _storage.refFromURL(event.imageUrl!).delete();
    }
    if (event.receiptId != null) {
      // Firestore에서 영수증 데이터 삭제
      await _receiptRepository.deleteReceipt(event.receiptId!);
    }
    emit(ReceiptInitial());
  }

  Map<String, double> _calculateMerchantTotals(List<Receipt> receipts) {
    final merchantTotals = <String, double>{};
    for (var receipt in receipts) {
      merchantTotals[receipt.merchantName] =
          (merchantTotals[receipt.merchantName] ?? 0.0) + receipt.totalAmount;
    }
    return merchantTotals;
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'receipt_saved_success': {
        AppLanguage.english: 'Receipt saved successfully',
        AppLanguage.korean: '영수증이 성공적으로 저장되었습니다.',
        AppLanguage.japanese: '領収書が正常に保存されました。',
      },
      'receipt_deleted_success': {
        AppLanguage.english: 'Receipt deleted successfully',
        AppLanguage.korean: '영수증이 성공적으로 삭제되었습니다.',
        AppLanguage.japanese: '領収書が正常に削除されました。',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }
}
