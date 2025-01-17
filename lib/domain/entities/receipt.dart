import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Receipt extends Equatable {
  final String id;
  final String imageUrl;
  final DateTime date;
  final String merchantName;
  final double totalAmount;
  final String currency;
  final List<ReceiptItem> items;
  final String userId;
  final String? expenseId;

  const Receipt({
    required this.id,
    required this.imageUrl,
    required this.date,
    required this.merchantName,
    required this.totalAmount,
    required this.currency,
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
        currency,
        items,
        userId,
        expenseId,
      ];

  factory Receipt.create({
    required String imageUrl,
    required String merchantName,
    required double totalAmount,
    required String currency,
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
      currency: currency,
      items: items,
      userId: userId,
      expenseId: expenseId,
    );
  }

  Receipt copyWith({
    String? id,
    String? imageUrl,
    DateTime? date,
    String? merchantName,
    double? totalAmount,
    String? currency,
    List<ReceiptItem>? items,
    String? userId,
    String? expenseId,
  }) {
    return Receipt(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      merchantName: merchantName ?? this.merchantName,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      items: items ?? this.items,
      userId: userId ?? this.userId,
      expenseId: expenseId ?? this.expenseId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'date': date.toIso8601String(),
      'merchantName': merchantName,
      'totalAmount': totalAmount,
      'currency': currency,
      'items': items.map((item) => item.toJson()).toList(),
      'userId': userId,
      'expenseId': expenseId,
    };
  }
}

class ReceiptItem extends Equatable {
  final String name;
  final double price;
  final int quantity;
  final double totalPrice;
  final String currency;

  const ReceiptItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.currency,
  });

  @override
  List<Object> get props => [name, price, quantity, totalPrice, currency];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'currency': currency,
    };
  }

  ReceiptItem copyWith({
    String? name,
    double? price,
    int? quantity,
    double? totalPrice,
    String? currency,
  }) {
    return ReceiptItem(
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      currency: currency ?? this.currency,
    );
  }
}
