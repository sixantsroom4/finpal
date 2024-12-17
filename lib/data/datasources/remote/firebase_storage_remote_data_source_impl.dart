import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finpal/data/models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:google_generative_ai/google_generative_ai.dart' as genai;
import '../../../core/errors/exceptions.dart';
import '../../models/expense_model.dart';
import '../../models/receipt_model.dart';
import '../../models/subscription_model.dart';
import 'firebase_storage_remote_data_source.dart';

class FirebaseStorageRemoteDataSourceImpl
    implements FirebaseStorageRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final genai.GenerativeModel _model;

  FirebaseStorageRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required genai.GenerativeModel model,
  })  : _firestore = firestore,
        _storage = storage,
        _model = model;

  // Receipt 관련 구현
  @override
  Future<String> uploadReceiptImage(String imagePath, String userId) async {
    try {
      final file = File(imagePath);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imagePath)}';
      final storageRef = _storage.ref().child('receipts/$userId/$fileName');

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('이미지 업로드 중 오류 발생: $e');
      throw ServerException(message: '이미지 업로드 실패: ${e.toString()}');
    }
  }

  @override
  Future<ReceiptModel> saveReceipt(ReceiptModel receipt) async {
    try {
      final receiptRef = _firestore.collection('receipts').doc();

      // 트랜잭션 내에서 한 번만 저장되도록 수정
      return await _firestore.runTransaction<ReceiptModel>((transaction) async {
        final existingReceipts = await _firestore
            .collection('receipts')
            .where('imageUrl', isEqualTo: receipt.imageUrl)
            .get();

        if (existingReceipts.docs.isNotEmpty) {
          return receipt; // 이미 존재하는 경우 기존 영수증 반환
        }

        // 영수증 저장 전에 통화 설정 확인
        final userDoc =
            await _firestore.collection('users').doc(receipt.userId).get();

        final userSettings =
            userDoc.data()?['settings'] as Map<String, dynamic>?;
        final userCurrency = userSettings?['currency'] as String? ?? 'KRW';

        // 사용자의 통화 설정을 사용하여 영수증 모델 업데이트
        final receiptWithCurrency = receipt.copyWith(
          currency: userCurrency,
          items: receipt.items
              .map((item) =>
                  (item as ReceiptItemModel).copyWith(currency: userCurrency))
              .toList(),
        );

        final receiptWithId = receiptWithCurrency.copyWith(id: receiptRef.id);
        transaction.set(receiptRef, receiptWithId.toJson());

        // items 컬렉션에 각 아이템 저장
        if (receiptWithId.items.isNotEmpty) {
          for (var item in receiptWithId.items) {
            final itemRef = receiptRef.collection('items').doc();
            final itemData = (item as ReceiptItemModel).toJson();
            transaction.set(itemRef, {
              ...itemData,
              'id': itemRef.id,
              'receiptId': receiptRef.id,
            });
          }
        }

        return receiptWithId;
      });
    } catch (e) {
      debugPrint('영수증 저장 실패: $e');
      throw DatabaseException('영수증 저장 실패: ${e.toString()}');
    }
  }

  @override
  Future<ReceiptModel> updateReceipt(ReceiptModel receipt) async {
    try {
      final batch = _firestore.batch();
      final receiptRef = _firestore.collection('receipts').doc(receipt.id);

      batch.update(receiptRef, receipt.toJson());

      final existingItems = await receiptRef.collection('items').get();
      for (var doc in existingItems.docs) {
        batch.delete(doc.reference);
      }

      for (var item in receipt.items) {
        final itemRef = receiptRef.collection('items').doc();
        batch.set(itemRef, {
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'totalPrice': item.totalPrice,
          'id': itemRef.id,
          'receiptId': receipt.id,
        });
      }

      await batch.commit();
      return receipt;
    } catch (e) {
      throw DatabaseException('영수증 업데이트 실패: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteReceipt(String receiptId) async {
    try {
      final receiptRef = _firestore.collection('receipts').doc(receiptId);
      final receiptDoc = await receiptRef.get();

      if (!receiptDoc.exists) {
        throw DatabaseException('영수증을 찾을 수 없습니다');
      }

      final receiptData = receiptDoc.data()!;
      final imageUrl = receiptData['imageUrl'] as String?;
      final expenseId = receiptData['expenseId'] as String?;

      final batch = _firestore.batch();

      // Firebase Storage 이미지 삭제
      if (imageUrl != null &&
          imageUrl.startsWith('https://firebasestorage.googleapis.com')) {
        try {
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
          debugPrint('이미지 삭제 성공: $imageUrl');
        } catch (e) {
          debugPrint('이미지 삭제 실패: $e');
        }
      }

      // 연결된 지출 삭제
      if (expenseId != null) {
        final expenseRef = _firestore.collection('expenses').doc(expenseId);
        batch.delete(expenseRef);
      }

      // 영수증 항목 삭제
      final itemsSnapshot = await receiptRef.collection('items').get();
      for (var doc in itemsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 영수증 문서 삭제
      batch.delete(receiptRef);

      // 일괄 처리 실행
      await batch.commit();
      debugPrint('영수증과 연결된 지출 삭제 성공: $receiptId');
    } catch (e) {
      debugPrint('영수증 삭제 실패: $e');
      throw DatabaseException('영수증 삭제 실패: ${e.toString()}');
    }
  }

  @override
  Future<List<ReceiptModel>> getReceipts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('receipts')
          .where('userId', isEqualTo: userId)
          .get();

      return Future.wait(snapshot.docs.map((doc) async {
        final itemsSnapshot = await doc.reference.collection('items').get();
        final items = itemsSnapshot.docs
            .map((itemDoc) => ReceiptItemModel.fromJson(itemDoc.data()))
            .toList();

        final receiptData = doc.data();
        // items를 Map 리스트로 ��환
        final itemsMapList = items.map((item) => item.toJson()).toList();

        return ReceiptModel.fromJson({
          ...receiptData,
          'items': itemsMapList,
        });
      }));
    } catch (e) {
      debugPrint('예상치 못한 에러 발생: $e');
      throw DatabaseException('영수증 목록 조회 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  @override
  Future<ReceiptModel?> getReceiptById(String receiptId) async {
    try {
      final doc = await _firestore.collection('receipts').doc(receiptId).get();
      if (!doc.exists) return null;

      final itemsSnapshot = await doc.reference.collection('items').get();
      final items = itemsSnapshot.docs
          .map((itemDoc) => ReceiptItemModel.fromJson(itemDoc.data()))
          .toList();

      // currency 필드를 그대로 사용
      final receiptData = doc.data()!;
      return ReceiptModel.fromJson({
        ...receiptData,
        'items': items,
      });
    } catch (e) {
      throw DatabaseException('영수증 조회 실패: ${e.toString()}');
    }
  }

  // 이미지 전처리 헬퍼 메서드
  Future<File> _preprocessImage(String imagePath) async {
    try {
      debugPrint('===== 이미지 전처리 시작 =====');

      final bytes = await File(imagePath).readAsBytes();
      var processed = img.decodeImage(bytes);

      if (processed == null) {
        debugPrint('이미지 디코딩 실패');
        return File(imagePath);
      }

      processed = img.grayscale(processed);
      processed = img.adjustColor(processed, contrast: 1.5);
      processed = img.gaussianBlur(processed, radius: 1);

      final compressedJpg = img.encodeJpg(processed, quality: 85);
      final outputPath = imagePath.replaceAll(
        RegExp(r'\.[^\.]+$'),
        '_processed.jpg',
      );

      await File(outputPath).writeAsBytes(compressedJpg);
      return File(outputPath);
    } catch (e) {
      debugPrint('이미지 전처리 실패: $e');
      return File(imagePath);
    }
  }

  // Expense 관련 구현
  @override
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    try {
      final docRef = _firestore.collection('expenses').doc();
      final expenseWithId = ExpenseModel.fromEntity(expense).toJson()
        ..['id'] = docRef.id;

      await docRef.set(expenseWithId);
      return ExpenseModel.fromJson(expenseWithId);
    } catch (e) {
      throw DatabaseException('Failed to add expense: ${e.toString()}');
    }
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    try {
      await _firestore
          .collection('expenses')
          .doc(expense.id)
          .update(expense.toJson());
      return expense;
    } catch (e) {
      throw DatabaseException('Failed to update expense: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      // 관련된 영수증도 함께 삭제
      final receipt = await getReceiptByExpenseId(expenseId);
      if (receipt != null) {
        await deleteReceipt(receipt.id);
      }

      await _firestore.collection('expenses').doc(expenseId).delete();
    } catch (e) {
      throw DatabaseException('Failed to delete expense: ${e.toString()}');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpenses(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ExpenseModel.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      debugPrint('지출 목록 조회 실패: $e');
      throw DatabaseException('지출 목록 조회 실패: ${e.toString()}');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      debugPrint('조회 시작일: $startDate');
      debugPrint('조회 종료일: $endDate');

      // userId로만 먼저 쿼리해서 결과 확인
      final snapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          // .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          // .where('date', isLessThan: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      debugPrint('조회된 문서 수: ${snapshot.docs.length}');

      // 각 문서의 전체 데이터를 로그로 확인
      for (var doc in snapshot.docs) {
        debugPrint('문서 ID: ${doc.id}');
        debugPrint('문서 데이터: ${doc.data()}');
      }

      // 날짜 필터링을 메모리에서 수행
      final expenses = snapshot.docs
          .map((doc) => ExpenseModel.fromJson(doc.data()))
          .where((expense) {
        final expenseDate = expense.date;
        return expenseDate.isAfter(startDate) && expenseDate.isBefore(endDate);
      }).toList();

      debugPrint('필터링 후 지출 수: ${expenses.length}');
      return expenses;
    } catch (e) {
      debugPrint('Firebase 조회 에러: $e');
      throw DatabaseException('지출 목록 조회 실��: ${e.toString()}');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByCategory(
    String userId,
    String category,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ExpenseModel.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      debugPrint('카테고리별 지출 목록 조회 실패: $e');
      throw DatabaseException('카테고리별 지출 목록 조회 실패: ${e.toString()}');
    }
  }

  @override
  Future<List<ExpenseModel>> getSharedExpenses(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('sharedWith', arrayContains: userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ExpenseModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw DatabaseException(
          'Failed to fetch shared expenses: ${e.toString()}');
    }
  }

  @override
  Future<ExpenseModel> getExpenseById(String expenseId) async {
    try {
      final doc = await _firestore.collection('expenses').doc(expenseId).get();

      if (!doc.exists) {
        throw DatabaseException('Expense not found');
      }

      return ExpenseModel.fromJson(doc.data()!);
    } catch (e) {
      throw DatabaseException('Failed to fetch expense: ${e.toString()}');
    }
  }

  // Subscription 관련 구현
  @override
  Future<SubscriptionModel> addSubscription(
      SubscriptionModel subscription) async {
    try {
      final docRef = _firestore.collection('subscriptions').doc();
      final subscriptionWithId = subscription.copyWith(id: docRef.id);
      await docRef.set(subscriptionWithId.toJson());
      return subscriptionWithId;
    } catch (e) {
      throw DatabaseException('구독 추가 실패: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSubscription(String subscriptionId) async {
    try {
      await _firestore.collection('subscriptions').doc(subscriptionId).delete();
    } catch (e) {
      throw DatabaseException('구독 삭제 실패: ${e.toString()}');
    }
  }

  @override
  Future<List<SubscriptionModel>> getActiveSubscriptions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => SubscriptionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw DatabaseException('활성 구독 회 실패: ${e.toString()}');
    }
  }

  @override
  Future<ReceiptModel?> getReceiptByExpenseId(String expenseId) async {
    try {
      final snapshot = await _firestore
          .collection('receipts')
          .where('expenseId', isEqualTo: expenseId)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final itemsSnapshot = await doc.reference.collection('items').get();
      final items = itemsSnapshot.docs
          .map((itemDoc) => ReceiptItemModel.fromJson(itemDoc.data()))
          .toList();

      return ReceiptModel.fromJson({
        ...doc.data(),
        'items': items,
      });
    } catch (e) {
      throw DatabaseException('영수증 조회 실패: ${e.toString()}');
    }
  }

  @override
  Future<List<ReceiptModel>> getReceiptsByDateRange(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      final receipts = await getReceipts(userId);
      return receipts.where((receipt) {
        return receipt.date.isAfter(startDate) &&
            receipt.date.isBefore(endDate);
      }).toList();
    } catch (e) {
      throw DatabaseException('짜별 영수증 조회 실패: ${e.toString()}');
    }
  }

  @override
  Future<List<ReceiptModel>> getReceiptsByMerchant(
      String userId, String merchant) async {
    try {
      final snapshot = await _firestore
          .collection('receipts')
          .where('userId', isEqualTo: userId)
          .where('merchant', isEqualTo: merchant)
          .get();
      return Future.wait(snapshot.docs.map((doc) async {
        final itemsSnapshot = await doc.reference.collection('items').get();
        final items = itemsSnapshot.docs
            .map((itemDoc) => ReceiptItemModel.fromJson(itemDoc.data()))
            .toList();
        return ReceiptModel.fromJson({...doc.data(), 'items': items});
      }));
    } catch (e) {
      throw DatabaseException('가점별 영수증 조회 실패: ${e.toString()}');
    }
  }

  @override
  Future<SubscriptionModel> getSubscriptionById(String subscriptionId) async {
    try {
      final doc = await _firestore
          .collection('subscriptions')
          .doc(subscriptionId)
          .get();
      if (!doc.exists) {
        throw DatabaseException('구독을 찾을 수 없습니다');
      }
      return SubscriptionModel.fromJson(doc.data()!);
    } catch (e) {
      throw DatabaseException('구독 조회 실패: ${e.toString()}');
    }
  }

  @override
  Future<List<SubscriptionModel>> getSubscriptions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => SubscriptionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw DatabaseException('구독 목록 조회 실패: ${e.toString()}');
    }
  }

  @override
  Future<List<SubscriptionModel>> getSubscriptionsByBillingDate(
      String userId, int billingDay) async {
    try {
      final snapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .where('billingDay', isEqualTo: billingDay)
          .get();
      return snapshot.docs
          .map((doc) => SubscriptionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw DatabaseException('청구일자별 구독 조회 실패: ${e.toString()}');
    }
  }

  @override
  Future<List<SubscriptionModel>> getSubscriptionsByCategory(
      String userId, String category) async {
    try {
      final snapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs
          .map((doc) => SubscriptionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw DatabaseException('카테고리별 구독 조회 실패: ${e.toString()}');
    }
  }

  @override
  Future<SubscriptionModel> updateSubscription(
      SubscriptionModel subscription) async {
    try {
      await _firestore
          .collection('subscriptions')
          .doc(subscription.id)
          .update(subscription.toJson());
      return subscription;
    } catch (e) {
      throw DatabaseException('구독 업데이트 실패: ${e.toString()}');
    }
  }

  @override
  Future<ReceiptModel> scanReceipt(String imagePath, String userId) async {
    try {
      debugPrint('===== 영수증 스캔 시작 =====');

      // 1. 사용자 설정 확인
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw DatabaseException('사용자를 찾을 수 없습니다');
      }

      final userSettings = userDoc.data()?['settings'] as Map<String, dynamic>?;
      final userCurrency = userSettings?['currency'] as String?;
      if (userCurrency == null) {
        throw DatabaseException('사용자의 통화 설정이 없습니다');
      }

      // 2. 이미지 전처리
      final processedImage = await _preprocessImage(imagePath);
      final bytes = await processedImage.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 3. Gemini로 영수증 분석
      final prompt = '''
      이 영수증 이미지를 분석해서 다음 정보를 JSON 형식으로 출력해주세요:
      {
        "merchant": "상명",
        "totalAmount": 숫자로된 총액,
        "date": "YYYY-MM-DD" 형식의 날짜,
        "items": [
          {
            "name": "상품명",
            "price": 숫��로된 가격,
            "quantity": 1
          }
        ]
      }
      ''';

      final response = await _model.generateContent([
        genai.Content.multi(
            [genai.TextPart(prompt), genai.DataPart('image/jpeg', bytes)])
      ]);

      final responseText = response.text ?? '{}';
      final parsedData = jsonDecode(responseText);

      // 4. 이미지 저장 및 URL 획득
      final imageUrl = await uploadReceiptImage(imagePath, userId);

      // items 데이터 변환 로직 수정
      final items = (parsedData['items'] as List<dynamic>)
          .map((item) => ReceiptItemModel(
                name: item['name'] as String,
                price: (item['price'] as num).toDouble(),
                quantity: (item['quantity'] as num).toInt(),
                currency: userCurrency,
                totalPrice: (item['price'] as num).toDouble() *
                    (item['quantity'] as num).toInt(),
              ))
          .toList();

      // Receipt 모델 생성
      final receipt = ReceiptModel(
        id: '', // Firestore에서 자동 생성
        userId: userId,
        merchantName: parsedData['merchant'] as String,
        date: DateTime.parse(parsedData['date'] as String),
        totalAmount: (parsedData['totalAmount'] as num).toDouble(),
        imageUrl: imageUrl,
        items: items,
        currency: userCurrency,
      );

      return await saveReceipt(receipt);
    } catch (e) {
      debugPrint('영수증 처리 실패: $e');
      throw ServerException(message: '영수증 처리 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  Future<String> getReceiptImage(String imageUrl) async {
    try {
      if (imageUrl.startsWith('data:image/jpeg;base64,')) {
        return imageUrl;
      }

      if (imageUrl.startsWith('firestore://')) {
        final imageId = imageUrl.substring(12);
        final docSnapshot =
            await _firestore.collection('receipt_images').doc(imageId).get();

        if (!docSnapshot.exists) {
          throw DatabaseException('이미지를 찾을 수 없습니다');
        }

        final imageData = docSnapshot.data()?['imageData'] as String?;
        if (imageData == null) {
          throw DatabaseException('이미지 데이터가 없습니다');
        }

        return 'data:image/jpeg;base64,$imageData';
      }

      throw DatabaseException('잘못된 이미지 URL 형식입니다');
    } catch (e) {
      debugPrint('이미지 데이터 조회 실패: $e');
      throw DatabaseException('이미지 데이터 조회 실패: ${e.toString()}');
    }
  }

  Future<void> createExpenseFromSubscription(
      SubscriptionModel subscription) async {
    try {
      // 다음 결제일 산
      final nextBillingDate = subscription.calculateNextBillingDate();

      // 지출 생성
      final expenseRef = _firestore.collection('expenses').doc();
      final expense = ExpenseModel(
        id: expenseRef.id,
        amount: subscription.amount,
        currency: subscription.currency,
        description: '${subscription.name} 구독료',
        category: subscription.category,
        date: nextBillingDate,
        userId: subscription.userId,
        isSubscription: true,
        subscriptionId: subscription.id,
        createdAt: DateTime.now(),
      );

      await expenseRef.set(expense.toJson());
    } catch (e) {
      debugPrint('구독 지출 생성 실패: $e');
      throw DatabaseException('구독 지출 생성 실패: ${e.toString()}');
    }
  }

  @override
  Future<double> getMonthlyBudget(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return (doc.data()?['monthlyBudget'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw DatabaseException('월간 예산 조회 실패: ${e.toString()}');
    }
  }

  @override
  Future<List<ExpenseModel>> getPreviousMonthExpenses(String userId) async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - 1, 1);
      final endDate = DateTime(now.year, now.month, 0);

      return getExpensesByDateRange(userId, startDate, endDate);
    } catch (e) {
      throw DatabaseException('지난달 지출 조회 실패: ${e.toString()}');
    }
  }

  @override
  Future<void> updateMonthlyBudget(String userId, double amount) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'monthlyBudget': amount,
      });
    } catch (e) {
      throw DatabaseException('월간 예산 업데이트 실패: ${e.toString()}');
    }
  }

  @override
  Stream<List<ExpenseModel>> watchExpenses(String userId) {
    return _firestore
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return ExpenseModel.fromJson({
                ...data,
                'id': doc.id,
              });
            }).toList());
  }

  @override
  Future<ReceiptModel> processAndUploadReceipt(
      String imagePath, String userId) async {
    try {
      // 1. 이미지 전처리
      final file = File(imagePath);
      final bytes = await file.readAsBytes();

      // 2. 현재 사용자의 ��화 설정 가져오기
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw DatabaseException('사용자를 찾을 수 없습니다');
      }
      final userCurrency = userDoc.data()?['settings']?['currency'] ?? 'KRW';

      // 3. Gemini로 영수증 분석
      final prompt = '''
      이 영수증 이미지를 분석해서 다음 정보를 JSON 형식으로 출력해주세요:
      {
        "merchantName": "상점명",
        "totalAmount": 숫자로된 총액,
        "date": "YYYY-MM-DD" 형식의 날짜,
        "items": [
          {
            "name": "상품명",
            "price": 숫자로된 가격,
            "quantity": 1
          }
        ]
      }
      ''';

      final response = await _model.generateContent([
        genai.Content.multi(
            [genai.TextPart(prompt), genai.DataPart('image/jpeg', bytes)])
      ]);

      final responseText = response.text ?? '{}';
      final parsedData = jsonDecode(responseText);

      // 4. 이미지 저장 및 URL 획득
      final imageUrl = await uploadReceiptImage(imagePath, userId);

      // 5. Receipt 모델 생성 및 저장 (사용자의 현재 통화 설정 사용)
      final receipt = ReceiptModel.fromJson({
        ...parsedData,
        'userId': userId,
        'imageUrl': imageUrl,
        'currency': userCurrency, // 현재 사용자의 통화 설정 사용
        'createdAt': DateTime.now().toIso8601String(),
      });

      return await saveReceipt(receipt);
    } catch (e) {
      debugPrint('영수증 처리 실패: $e');
      throw ServerException(message: '영수증 처리 중 오류가 발생했습니다: ${e.toString()}');
    }
  }
}
