import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

interface InquiryData {
  template: {
    name: string;
    data: {
      category: string;
      title: string;
      content: string;
      imageUrls: string[];
      userId: string;
    }
  };
  to: string;
  status: string;
  timestamp: admin.firestore.Timestamp;
}

export const sendInquiryEmail = functions.firestore
  .onDocumentCreated('inquiries/{docId}', async (event) => {
    if (!event.data) return;
    
    const inquiryData = event.data.data() as InquiryData;
    if (!inquiryData) return;

    try {
      // 사용자에게 보내는 확인 이메일
      await admin.firestore().collection('mail').add({
        to: inquiryData.to,
        message: {
          subject: '[Finpal] 문의가 접수되었습니다',
          html: `
            <div style="font-family: Arial, sans-serif;">
              <h2 style="color: #2c3e50;">문의가 접수되었습니다</h2>
              <div style="background-color: #f9f9f9; padding: 20px; border-radius: 5px;">
                <p><strong>카테고리:</strong> ${inquiryData.template.data.category}</p>
                <p><strong>제목:</strong> ${inquiryData.template.data.title}</p>
                <p><strong>내용:</strong> ${inquiryData.template.data.content}</p>
              </div>
              <p style="color: #7f8c8d; font-size: 12px; margin-top: 20px;">
                * 이 메일은 자동발송되었습니다. 문의하신 내용은 검토 후 순차적으로 답변드리겠습니다.
              </p>
            </div>
          `
        }
      });

      // 상태 업데이트
      await event.data.ref.update({
        status: 'sent',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 관리자에게 보내는 알림 이메일
      await admin.firestore().collection('mail').add({
        to: 'support@finpal-app.com',
        message: {
          subject: '[Finpal 관리자] 새로운 문의가 접수되었습니다',
          html: `
            <div style="font-family: Arial, sans-serif;">
              <h2 style="color: #2c3e50;">새로운 문의가 접수되었습니다</h2>
              <div style="background-color: #f9f9f9; padding: 20px; border-radius: 5px;">
                <p><strong>사용자 이메일:</strong> ${inquiryData.to}</p>
                <p><strong>사용자 ID:</strong> ${inquiryData.template.data.userId}</p>
                <p><strong>카테고리:</strong> ${inquiryData.template.data.category}</p>
                <p><strong>제목:</strong> ${inquiryData.template.data.title}</p>
                <p><strong>내용:</strong> ${inquiryData.template.data.content}</p>
                ${inquiryData.template.data.imageUrls.length > 0 ? `
                  <p><strong>첨부된 이미지:</strong></p>
                  <ul>
                    ${inquiryData.template.data.imageUrls.map(url => `<li><a href="${url}">이미지 보기</a></li>`).join('')}
                  </ul>
                ` : ''}
              </div>
            </div>
          `
        }
      });

    } catch (error: any) {
      console.error('Error sending email:', error);
      await event.data.ref.update({
        status: 'error',
        error: error.message as string,
      });
    }
  });
