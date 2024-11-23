// data/models/receipt_model.dart
import '../../domain/entities/receipt.dart';

class ReceiptItemModel extends ReceiptItem {
  const ReceiptItemModel({
    required String name,
    required double price,
    required int quantity,
    required double totalPrice,
  }) : super(
          name: name,
          price: price,
          quantity: quantity,
          totalPrice: totalPrice,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }

  factory ReceiptItemModel.fromEntity(ReceiptItem item) {
    return ReceiptItemModel(
      name: item.name,
      price: item.price,
      quantity: item.quantity,
      totalPrice: item.totalPrice,
    );
  }
}

class ReceiptModel extends Receipt {
  const ReceiptModel({
    required String id,
    required String imageUrl,
    required DateTime date,
    required String currency,
    required String merchantName,
    required double totalAmount,
    required List<ReceiptItem> items,
    required String userId,
    String? expenseId,
  }) : super(
          id: id,
          imageUrl: imageUrl,
          date: date,
          currency: currency,
          merchantName: merchantName,
          totalAmount: totalAmount,
          items: items,
          userId: userId,
          expenseId: expenseId,
        );

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      id: json['id'],
      imageUrl: json['imageUrl'],
      date: DateTime.parse(json['date']),
      currency: json['currency'],
      merchantName: json['merchantName'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      items: (json['items'] as List)
          .map((item) => ReceiptItemModel.fromJson(item))
          .toList(),
      userId: json['userId'],
      expenseId: json['expenseId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'date': date.toIso8601String(),
      'currency': currency,
      'merchantName': merchantName,
      'totalAmount': totalAmount,
      'items': items
          .map((item) => (item is ReceiptItemModel
                  ? item
                  : ReceiptItemModel.fromEntity(item))
              .toJson())
          .toList(),
      'userId': userId,
      'expenseId': expenseId,
    };
  }

  factory ReceiptModel.fromEntity(Receipt receipt) {
    return ReceiptModel(
      id: receipt.id,
      imageUrl: receipt.imageUrl,
      date: receipt.date,
      currency: receipt.currency,
      merchantName: receipt.merchantName,
      totalAmount: receipt.totalAmount,
      items: receipt.items
          .map((item) => ReceiptItemModel.fromEntity(item))
          .toList(),
      userId: receipt.userId,
      expenseId: receipt.expenseId,
    );
  }

  /// OCR 결과로부터 Receipt 모델 생성
  factory ReceiptModel.fromOCRResult({
    required String id,
    required String imageUrl,
    required Map<String, dynamic> ocrResult,
    required String userId,
  }) {
    final items = (ocrResult['items'] as List).map((item) {
      return ReceiptItemModel(
        name: item['name'],
        price: (item['price'] as num).toDouble(),
        quantity: item['quantity'] ?? 1,
        totalPrice: (item['totalPrice'] as num).toDouble(),
      );
    }).toList();

    return ReceiptModel(
      id: id,
      imageUrl: imageUrl,
      date: DateTime.tryParse(ocrResult['date'] ?? '') ?? DateTime.now(),
      currency: ocrResult['currency'] ?? 'USD',
      merchantName: ocrResult['merchantName'] ?? 'Unknown',
      totalAmount: (ocrResult['totalAmount'] as num?)?.toDouble() ??
          items.fold(0, (sum, item) => sum + item.totalPrice),
      items: items,
      userId: userId,
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
      items: items ?? this.items,
    );
  }
}
