import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

export const createSubscriptionExpenses = functions.pubsub
  .schedule('0 0 * * *')
  .timeZone('Asia/Seoul')
  .onRun(async (context: functions.EventContext) => {
    const now = new Date();
    const today = now.getDate();

    try {
      const subscriptionsSnapshot = await admin.firestore()
        .collection('subscriptions')
        .where('billingDay', '==', today)
        .where('isActive', '==', true)
        .get();

      const batch = admin.firestore().batch();

      for (const doc of subscriptionsSnapshot.docs) {
        const subscription = doc.data();
        
        const expenseRef = admin.firestore().collection('expenses').doc();
        batch.set(expenseRef, {
          id: expenseRef.id,
          amount: subscription.amount,
          description: `${subscription.name} 구독료`,
          category: subscription.category,
          date: now.toISOString(),
          userId: subscription.userId,
          isSubscription: true,
          subscriptionId: subscription.id,
          createdAt: now.toISOString()
        });
      }

      await batch.commit();
      console.log(`${subscriptionsSnapshot.size}개의 구독 지출이 생성되었습니다.`);
      return null;
    } catch (error) {
      console.error('구독 지출 생성 중 오류 발생:', error);
      throw new functions.https.HttpsError('internal', '구독 지출 생성에 실패했습니다.');
    }
  }); 