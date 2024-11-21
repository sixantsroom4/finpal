import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/data/terms/jp/data_processing_jp.dart';
import 'package:finpal/presentation/data/terms/kr/service_terms.dart';
import 'package:finpal/presentation/data/terms/kr/data_processing.dart';
import 'package:finpal/presentation/data/terms/kr/user_responsibility.dart';
import 'package:finpal/presentation/data/terms/kr/terms_changes.dart';
import 'package:finpal/presentation/data/terms/kr/privacy_policy.dart';
import 'package:finpal/presentation/data/terms/kr/contact_info.dart';

import 'package:finpal/presentation/data/terms/en/service_terms_en.dart';
import 'package:finpal/presentation/data/terms/en/data_processing_en.dart';
import 'package:finpal/presentation/data/terms/en/user_responsibility_en.dart';
import 'package:finpal/presentation/data/terms/en/terms_changes_en.dart';
import 'package:finpal/presentation/data/terms/en/privacy_policy_en.dart';
import 'package:finpal/presentation/data/terms/en/contact_info_en.dart';

import 'package:finpal/presentation/data/terms/jp/service_terms_jp.dart';

import 'package:finpal/presentation/data/terms/jp/user_responsibility_jp.dart';
import 'package:finpal/presentation/data/terms/jp/terms_changes_jp.dart';
import 'package:finpal/presentation/data/terms/jp/privacy_policy_jp.dart';
import 'package:finpal/presentation/data/terms/jp/contact_info_jp.dart';

class TermsService {
  static List<Map<String, String>> getTermsByLanguage(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return [
          {'title': ServiceTermsEn.title, 'content': ServiceTermsEn.content},
          {
            'title': DataProcessingEn.title,
            'content': DataProcessingEn.content
          },
          {
            'title': UserResponsibilityEn.title,
            'content': UserResponsibilityEn.content
          },
          {'title': TermsChangesEn.title, 'content': TermsChangesEn.content},
          {'title': PrivacyPolicyEn.title, 'content': PrivacyPolicyEn.content},
          {'title': ContactInfoEn.title, 'content': ContactInfoEn.content},
        ];
      case AppLanguage.japanese:
        return [
          {'title': ServiceTermsJp.title, 'content': ServiceTermsJp.content},
          {
            'title': DataProcessingJp.title,
            'content': DataProcessingJp.content
          },
          {
            'title': UserResponsibilityJp.title,
            'content': UserResponsibilityJp.content
          },
          {'title': TermsChangesJp.title, 'content': TermsChangesJp.content},
          {'title': PrivacyPolicyJp.title, 'content': PrivacyPolicyJp.content},
          {'title': ContactInfoJp.title, 'content': ContactInfoJp.content},
        ];
      case AppLanguage.korean:
      default:
        return [
          {'title': ServiceTerms.title, 'content': ServiceTerms.content},
          {'title': DataProcessing.title, 'content': DataProcessing.content},
          {
            'title': UserResponsibility.title,
            'content': UserResponsibility.content
          },
          {'title': TermsChanges.title, 'content': TermsChanges.content},
          {'title': PrivacyPolicy.title, 'content': PrivacyPolicy.content},
          {'title': ContactInfo.title, 'content': ContactInfo.content},
        ];
    }
  }
}
