// data/models/receipt_model.dart
import '../../domain/entities/receipt.dart';

class ReceiptItemModel extends ReceiptItem {
  const ReceiptItemModel({
    required String name,
    required double price,
    required int quantity,
    required double totalPrice,
    required String currency,
  }) : super(
          name: name,
          price: price,
          quantity: quantity,
          totalPrice: totalPrice,
          currency: currency,
        );

  factory ReceiptItemModel.fromJson(Map<String, dynamic> json) {
    return ReceiptItemModel(
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0) is int
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0) as double,
      quantity: (json['quantity'] ?? 1) as int,
      totalPrice: (json['totalPrice'] ?? 0.0) is int
          ? (json['totalPrice'] as int).toDouble()
          : (json['totalPrice'] ?? 0.0) as double,
      currency: json['currency'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'currency': currency,
    };
  }
}

class ReceiptModel extends Receipt {
  const ReceiptModel({
    required String id,
    required String imageUrl,
    required DateTime date,
    required String merchantName,
    required double totalAmount,
    required String currency,
    required List<ReceiptItemModel> items,
    required String userId,
    String? expenseId,
  }) : super(
          id: id,
          imageUrl: imageUrl,
          date: date,
          merchantName: merchantName,
          totalAmount: totalAmount,
          currency: currency,
          items: items,
          userId: userId,
          expenseId: expenseId,
        );

  factory ReceiptModel.fromJson(Map<String, dynamic> json,
      {String? userCurrency}) {
    final currency = userCurrency ?? json['currency'] ?? '';
    return ReceiptModel(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      merchantName: json['merchantName'] ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currency: currency,
      items: (json['items'] as List?)
              ?.map((item) => ReceiptItemModel.fromJson({
                    ...item as Map<String, dynamic>,
                    'currency': currency,
                  }))
              .toList() ??
          [],
      userId: json['userId'] ?? '',
      expenseId: json['expenseId'],
    );
  }

  factory ReceiptModel.fromEntity(Receipt receipt) {
    return ReceiptModel(
      id: receipt.id,
      imageUrl: receipt.imageUrl,
      date: receipt.date,
      merchantName: receipt.merchantName,
      totalAmount: receipt.totalAmount,
      currency: receipt.currency,
      items: receipt.items
          .map((item) => item is ReceiptItemModel
              ? item
              : ReceiptItemModel(
                  name: item.name,
                  price: item.price,
                  quantity: item.quantity,
                  totalPrice: item.totalPrice,
                  currency: item.currency,
                ))
          .toList(),
      userId: receipt.userId,
      expenseId: receipt.expenseId,
    );
  }

  factory ReceiptModel.fromOCRResult({
    required String id,
    required String imageUrl,
    required Map<String, dynamic> ocrResult,
    required String userId,
    required String userCurrency,
  }) {
    final items = (ocrResult['items'] as List).map((item) {
      return ReceiptItemModel(
        name: item['name'] as String? ?? '',
        price: (item['price'] as num).toDouble(),
        quantity: item['quantity'] as int? ?? 1,
        totalPrice: (item['totalPrice'] as num).toDouble(),
        currency: userCurrency,
      );
    }).toList();

    return ReceiptModel(
      id: id,
      imageUrl: imageUrl,
      date: DateTime.tryParse(ocrResult['date'] ?? '') ?? DateTime.now(),
      merchantName: ocrResult['merchantName'] ?? 'Unknown',
      totalAmount: (ocrResult['totalAmount'] as num?)?.toDouble() ??
          items.fold(0, (sum, item) => sum + item.totalPrice),
      currency: userCurrency,
      items: items,
      userId: userId,
      expenseId: ocrResult['expenseId'],
    );
  }

  @override
  ReceiptModel copyWith({
    String? id,
    String? userId,
    String? merchantName,
    DateTime? date,
    double? totalAmount,
    String? currency,
    String? imageUrl,
    String? expenseId,
    List<ReceiptItem>? items,
  }) {
    return ReceiptModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      merchantName: merchantName ?? this.merchantName,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      imageUrl: imageUrl ?? this.imageUrl,
      expenseId: expenseId ?? this.expenseId,
      items: (items ?? this.items)
          .map((item) => item is ReceiptItemModel
              ? item
              : ReceiptItemModel(
                  name: item.name,
                  price: item.price,
                  quantity: item.quantity,
                  totalPrice: item.totalPrice,
                  currency: item.currency,
                ))
          .toList(),
    );
  }
}
