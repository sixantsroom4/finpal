/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';
import { onDocumentUpdated } from 'firebase-functions/v2/firestore';

admin.initializeApp();
const db = admin.firestore();

/**
 * 반복 지출 생성 함수
 */
export const generateRecurringExpenses = functions.scheduler.onSchedule('0 0 * * *', async (context: functions.scheduler.ScheduledEvent) => {
  console.log('반복 지출 생성 함수 시작');

  try {
    const subscriptionsSnapshot = await db.collection('subscriptions')
      .where('isActive', '==', true)
      .where('cancelledAt', '==', null)
      .get();
    const subscriptions = subscriptionsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() as { isPaused?: boolean, name: string } }));
    console.log(`활성 구독 수: ${subscriptions.length}`);

    for (const subscription of subscriptions) {
      // 일시정지된 구독은 지출 생성하지 않음
      if (!(subscription.isPaused ?? false)) {
        await generateExpenseForSubscription(subscription);
      } else {
        console.log(`${subscription.name} 구독은 일시정지되어 지출 생성을 건너뜁니다.`);
      }
    }

    console.log('반복 지출 생성 함수 완료');
  } catch (error) {
    console.error('반복 지출 생성 중 오류 발생:', error);
  }
});

/**
 * 구독 일시정지 처리 함수
 */
export const onSubscriptionPaused = onDocumentUpdated('subscriptions/{subscriptionId}', async (event) => {
  const beforeData = event.data?.before.data();
  const afterData = event.data?.after.data();

  // isPaused 필드가 false -> true 로 변경된 경우에만 실행
  if (beforeData && afterData && !beforeData.isPaused && afterData.isPaused) {
    console.log(`구독 일시정지 감지: ${event.params.subscriptionId}`);

    const subscriptionId = event.params.subscriptionId;
    const billingDay = afterData.billingDay;
    const today = new Date();
    const currentYear = today.getFullYear();
    const currentMonth = today.getMonth(); // 0부터 시작

    // 해당 월의 결제일
    const billingDate = new Date(currentYear, currentMonth, billingDay);

    console.log(`결제일: ${billingDate}`);
    console.log(`오늘 날짜: ${today}`);

    // 일시정지 시점이 결제일 이전인 경우
    if (today < billingDate) {
      console.log(`${subscriptionId} 구독은 결제일(${billingDate}) 전에 일시정지되었습니다.`);
      // 추가적인 액션은 필요 없을 수 있음. 다음 결제일에 지출이 생성되지 않도록 처리될 것임.
    }
    // 일시정지 시점이 결제일 이후인 경우
    else {
      console.log(`${subscriptionId} 구독은 결제일(${billingDate}) 이후에 일시정지되었습니다.`);
      // 이번 달 지출이 이미 생성되었을 수 있으므로, 별도의 처리 없이 로그만 남김
    }
  }
});

async function generateExpenseForSubscription(subscription: any) {
  const today = new Date();
  const currentMonth = today.getMonth() + 1;
  const currentYear = today.getFullYear();

  const billingDay = subscription.billingDay;
  const billingDate = new Date(currentYear, currentMonth - 1, billingDay);

  const expenseRef = db.collection('expenses');
  const existingExpenseSnapshot = await expenseRef
    .where('subscriptionId', '==', subscription.id)
    .where('date', '>=', new Date(currentYear, currentMonth - 1, 1))
    .where('date', '<=', new Date(currentYear, currentMonth, 0))
    .get();

  if (existingExpenseSnapshot.empty) {
    const newExpense = {
      userId: subscription.userId,
      subscriptionId: subscription.id,
      amount: subscription.amount,
      currency: subscription.currency,
      description: `${subscription.name} 구독료`,
      category: subscription.category,
      date: billingDate,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await expenseRef.add(newExpense);
    console.log(`${subscription.name} 구독에 대한 지출 생성 완료 (${billingDate.toLocaleDateString()})`);
  } else {
    console.log(`${subscription.name} 구독에 대한 이번 달 지출은 이미 존재합니다.`);
  }
}
