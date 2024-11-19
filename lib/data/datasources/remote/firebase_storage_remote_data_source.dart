// data/datasources/remote/firebase_storage_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/expense_model.dart';
import '../../models/receipt_model.dart';
import '../../models/subscription_model.dart';

abstract class FirebaseStorageRemoteDataSource {
  // Expense 관련
  Future<ExpenseModel> addExpense(ExpenseModel expense);
  Future<ExpenseModel> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String expenseId);
  Future<List<ExpenseModel>> getExpenses(String userId);
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<ExpenseModel>> getExpensesByCategory(
    String userId,
    String category,
  );
  Future<List<ExpenseModel>> getSharedExpenses(String userId);
  Future<ExpenseModel> getExpenseById(String expenseId);

  // Receipt 관련
  Future<String> uploadReceiptImage(String imagePath, String userId);
  Future<ReceiptModel> saveReceipt(ReceiptModel receipt);
  Future<ReceiptModel> updateReceipt(ReceiptModel receipt);
  Future<void> deleteReceipt(String receiptId);
  Future<List<ReceiptModel>> getReceipts(String userId);
  Future<ReceiptModel?> getReceiptById(String receiptId);
  Future<List<ReceiptModel>> getReceiptsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<ReceiptModel>> getReceiptsByMerchant(
    String userId,
    String merchantName,
  );
  Future<ReceiptModel?> getReceiptByExpenseId(String expenseId);

  // Subscription 관련
  Future<SubscriptionModel> addSubscription(SubscriptionModel subscription);
  Future<SubscriptionModel> updateSubscription(SubscriptionModel subscription);
  Future<void> deleteSubscription(String subscriptionId);
  Future<List<SubscriptionModel>> getSubscriptions(String userId);
  Future<List<SubscriptionModel>> getActiveSubscriptions(String userId);
  Future<SubscriptionModel> getSubscriptionById(String subscriptionId);
  Future<List<SubscriptionModel>> getSubscriptionsByCategory(
    String userId,
    String category,
  );
  Future<List<SubscriptionModel>> getSubscriptionsByBillingDate(
    String userId,
    int billingDay,
  );
  Future<void> createExpenseFromSubscription(SubscriptionModel subscription);
}
