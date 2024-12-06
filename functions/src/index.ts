import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

interface EmailData {
  to: string;
  template: {
    name: string;
    data: {
      category: string;
      title: string;
      content: string;
      imageUrls: string[];
      userId: string;
      timestamp: any;
      status: string;
    };
  };
}

export const sendInquiryEmail = functions.firestore
  .onDocumentCreated('inquiries/{docId}', async (event) => {
    if (!event.data) return;
    
    const data = event.data.data() as EmailData;
    if (!data) return;

    try {
      await admin.firestore().collection('mail').add({
        to: data.to,
        from: 'noreply@finpal-app.firebaseapp.com',
        message: {
          subject: '[Finpal] 문의가 접수되었습니다',
          text: `카테고리: ${data.template.data.category}\n제목: ${data.template.data.title}\n내용: ${data.template.data.content}`,
          html: `
            <h2>문의가 접수되었습니다</h2>
            <p>카테고리: ${data.template.data.category}</p>
            <p>제목: ${data.template.data.title}</p>
            <p>내용: ${data.template.data.content}</p>
          `
        }
      });

      await event.data.ref.update({
        status: 'sent',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (error: any) {
      console.error('Error sending email:', error);
      await event.data.ref.update({
        status: 'error',
        error: error.message as string,
      });
    }
  });
