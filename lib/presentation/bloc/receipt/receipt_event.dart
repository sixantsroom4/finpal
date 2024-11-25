import 'package:equatable/equatable.dart';
import '../../../domain/entities/receipt.dart';

abstract class ReceiptEvent extends Equatable {
  const ReceiptEvent();

  @override
  List<Object?> get props => [];
}

class ScanReceipt extends ReceiptEvent {
  final String imagePath;
  final String userId;

  const ScanReceipt({
    required this.imagePath,
    required this.userId,
  });

  @override
  List<Object> get props => [imagePath, userId];
}

class SaveReceipt extends ReceiptEvent {
  final Receipt receipt;

  const SaveReceipt(this.receipt);

  @override
  List<Object> get props => [receipt];
}

class UpdateReceipt extends ReceiptEvent {
  final Receipt receipt;

  const UpdateReceipt(this.receipt);

  @override
  List<Object> get props => [receipt];
}

class DeleteReceipt extends ReceiptEvent {
  final String receiptId;

  const DeleteReceipt(this.receiptId);

  @override
  List<Object> get props => [receiptId];
}

class LoadReceipts extends ReceiptEvent {
  final String userId;

  const LoadReceipts(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadReceiptsByDateRange extends ReceiptEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadReceiptsByDateRange({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [userId, startDate, endDate];
}

class LoadReceiptsByMerchant extends ReceiptEvent {
  final String userId;
  final String merchantName;

  const LoadReceiptsByMerchant({
    required this.userId,
    required this.merchantName,
  });

  @override
  List<Object> get props => [userId, merchantName];
}

class ProcessReceiptEvent extends ReceiptEvent {
  final String imagePath;

  const ProcessReceiptEvent(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

class LoadReceiptById extends ReceiptEvent {
  final String receiptId;

  const LoadReceiptById(this.receiptId);

  @override
  List<Object> get props => [receiptId];
}

enum SortOption {
  date,
  store,
  amount,
}

class SortReceipts extends ReceiptEvent {
  final SortOption sortOption;

  const SortReceipts(this.sortOption);

  @override
  List<Object> get props => [sortOption];
}
