import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Receipt extends Equatable {
  final String id;
  final String imageUrl;
  final DateTime date;
  final String merchantName;
  final double totalAmount;
  final List<ReceiptItem> items;
  final String userId;
  final String? expenseId;

  const Receipt({
    required this.id,
    required this.imageUrl,
    required this.date,
    required this.merchantName,
    required this.totalAmount,
    required this.items,
    required this.userId,
    this.expenseId,
  });

  @override
  List<Object?> get props => [
        id,
        imageUrl,
        date,
        merchantName,
        totalAmount,
        items,
        userId,
        expenseId,
      ];

  factory Receipt.create({
    required String imageUrl,
    required String merchantName,
    required double totalAmount,
    required List<ReceiptItem> items,
    required String userId,
    String? expenseId,
  }) {
    return Receipt(
      id: const Uuid().v4(),
      imageUrl: imageUrl,
      date: DateTime.now(),
      merchantName: merchantName,
      totalAmount: totalAmount,
      items: items,
      userId: userId,
      expenseId: expenseId,
    );
  }
}

class ReceiptItem extends Equatable {
  final String name;
  final double price;
  final int quantity;
  final double totalPrice;

  const ReceiptItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  });

  @override
  List<Object> get props => [name, price, quantity, totalPrice];
}
