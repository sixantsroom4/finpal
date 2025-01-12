import 'package:equatable/equatable.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_event.dart';
import '../../../domain/entities/receipt.dart';

abstract class ReceiptState extends Equatable {
  final List<Receipt> receipts;
  final Map<String, double> merchantTotals;
  final double totalAmount;
  final String? message;
  final bool isAnalysisComplete;

  const ReceiptState({
    this.receipts = const [],
    this.merchantTotals = const {},
    this.totalAmount = 0,
    this.message,
    this.isAnalysisComplete = false,
  });

  @override
  List<Object?> get props =>
      [receipts, merchantTotals, totalAmount, message, isAnalysisComplete];
}

class ReceiptInitial extends ReceiptState {}

class ReceiptLoading extends ReceiptState {
  final List<Receipt> receipts;
  final Map<String, double> merchantTotals;
  final double totalAmount;
  final String? message;
  final bool isAnalysisComplete;

  const ReceiptLoading([
    this.receipts = const [],
    this.merchantTotals = const {},
    this.totalAmount = 0,
    this.message,
    this.isAnalysisComplete = false,
  ]);

  @override
  List<Object?> get props =>
      [receipts, merchantTotals, totalAmount, message, isAnalysisComplete];
}

class ReceiptScanInProgress extends ReceiptState {}

class ReceiptScanSuccess extends ReceiptState {
  final Receipt receipt;

  const ReceiptScanSuccess(this.receipt);

  @override
  List<Object?> get props => [receipt];
}

class ReceiptLoaded extends ReceiptState {
  final List<Receipt> receipts;
  final Map<String, double> merchantTotals;
  final double totalAmount;
  final String? message;
  final bool isAnalysisComplete;
  final SortOption? currentSortOption;

  const ReceiptLoaded({
    required this.receipts,
    required this.merchantTotals,
    required this.totalAmount,
    this.message,
    this.isAnalysisComplete = false,
    this.currentSortOption,
  });

  @override
  List<Object?> get props => [
        receipts,
        merchantTotals,
        totalAmount,
        message,
        isAnalysisComplete,
        currentSortOption,
      ];
}

class ReceiptError extends ReceiptState {
  final String message;

  const ReceiptError(this.message);

  @override
  List<Object?> get props =>
      [receipts, merchantTotals, totalAmount, message, isAnalysisComplete];
}

class ReceiptOperationSuccess extends ReceiptState {
  final String message;

  const ReceiptOperationSuccess(
    this.message, {
    List<Receipt> receipts = const [],
    Map<String, double> merchantTotals = const {},
    double totalAmount = 0,
  }) : super(
          receipts: receipts,
          merchantTotals: merchantTotals,
          totalAmount: totalAmount,
          message: message,
        );
}

class ReceiptEmpty extends ReceiptState {
  const ReceiptEmpty();

  @override
  List<Object?> get props =>
      [receipts, merchantTotals, totalAmount, message, isAnalysisComplete];
}

class ReceiptAnalysisSuccess extends ReceiptState {
  const ReceiptAnalysisSuccess({
    required List<Receipt> receipts,
    required Map<String, double> merchantTotals,
    required double totalAmount,
    String? message,
  }) : super(
          receipts: receipts,
          merchantTotals: merchantTotals,
          totalAmount: totalAmount,
          message: message,
          isAnalysisComplete: true,
        );
}
