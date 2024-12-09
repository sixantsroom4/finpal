import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finpal/core/constants/firebase_schema.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseMigrationUtils {
  static Future<void> addCurrencyField() async {
    final firestore = FirebaseFirestore.instance;

    // Expenses 마이그레이션
    final expensesSnapshot =
        await firestore.collection(FirebaseSchema.expenses).get();
    for (var doc in expensesSnapshot.docs) {
      if (doc.data()['currency'] == null) {
        await doc.reference.update({
          'currency': 'KRW',
          'userId': FirebaseAuth.instance.currentUser?.uid,
        });
      }
    }

    // Receipts 마이그레이션
    final receiptsSnapshot =
        await firestore.collection(FirebaseSchema.receipts).get();
    for (var doc in receiptsSnapshot.docs) {
      if (doc.data()['currency'] == null) {
        await doc.reference.update({
          'currency': 'KRW',
          'userId': FirebaseAuth.instance.currentUser?.uid,
        });
      }
    }

    // Subscriptions 마이그레이션
    final subscriptionsSnapshot =
        await firestore.collection(FirebaseSchema.subscriptions).get();
    for (var doc in subscriptionsSnapshot.docs) {
      if (doc.data()['currency'] == null) {
        await doc.reference.update({
          'currency': 'KRW',
          'userId': FirebaseAuth.instance.currentUser?.uid,
        });
      }
    }
  }

  /// 앱 시작 시 마이그레이션 실행
  static Future<void> runMigrations() async {
    await addCurrencyField();
  }
}
