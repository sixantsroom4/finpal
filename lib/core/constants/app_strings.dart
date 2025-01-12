import 'package:finpal/core/constants/app_languages.dart';

class AppStrings {
  static const Map<String, Map<AppLanguage, String>> labels = {
    'subscription_added': {
      AppLanguage.english: 'Subscription added successfully',
      AppLanguage.korean: '구독이 추가되었습니다',
      AppLanguage.japanese: 'サブスクが追加されました',
    },
    'subscription_updated': {
      AppLanguage.english: 'Subscription updated successfully',
      AppLanguage.korean: '구독이 수정되었습니다',
      AppLanguage.japanese: 'サブスクが更新されました',
    },
    'subscription_deleted': {
      AppLanguage.english: 'Subscription deleted successfully',
      AppLanguage.korean: '구독이 삭제되었습니다',
      AppLanguage.japanese: 'サブスクが削除されました',
    },
    'receipt_saved_success': {
      AppLanguage.english: 'Receipt saved successfully',
      AppLanguage.korean: '영수증이 저장되었습니다',
      AppLanguage.japanese: 'レシートが保存されました',
    },
    'receipt_deleted_success': {
      AppLanguage.english: 'Receipt deleted successfully',
      AppLanguage.korean: '영수증이 삭제되었습니다',
      AppLanguage.japanese: 'レシートが削除されました',
    },
    'receipt_updated_success': {
      AppLanguage.english: 'Receipt updated successfully',
      AppLanguage.korean: '영수증이 수정되었습니다',
      AppLanguage.japanese: 'レシートが更新されました',
    },
  };
}
