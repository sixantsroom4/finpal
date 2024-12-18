import 'package:finpal/presentation/bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_event.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/pages/onboarding/widgets/terms_content.dart';
import 'package:finpal/presentation/widgets/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/services/terms_service.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/data/terms/kr/personal_data_collection.dart';
import 'package:finpal/presentation/data/terms/en/personal_data_collection_en.dart';
import 'package:finpal/presentation/data/terms/jp/personal_data_collection_jp.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool _isAgreed = false;
  final Set<int> _expandedItems = {};
  late List<Map<String, String>> _terms;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLanguageBloc, AppLanguageState>(
      builder: (context, state) {
        _terms = TermsService.getTermsByLanguage(state.language);

        final personalDataCollection =
            _getLocalizedPersonalDataCollection(state.language);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.read<AuthBloc>().add(AuthSignedOut());
                context.go('/welcome');
              },
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  '📋 ${_getLocalizedTitle()}',
                  style: const TextStyle(
                    color: Color(0xFF1C2833),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getLocalizedSubtitle(),
                  style: const TextStyle(
                    color: Color(0xFF34495E),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TermsContent(
                          terms: _terms,
                          expandedItems: _expandedItems,
                          onItemTap: (index) {
                            setState(() {
                              if (_expandedItems.contains(index)) {
                                _expandedItems.remove(index);
                              } else {
                                _expandedItems.add(index);
                              }
                            });
                          },
                        ),
                        ExpansionTile(
                          title: Text(
                            personalDataCollection['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                personalDataCollection['content']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text(
                          _getLocalizedAgreement(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2C3E50),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        contentPadding: EdgeInsets.zero,
                        value: _isAgreed,
                        onChanged: (value) {
                          setState(() {
                            _isAgreed = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF2C3E50),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isAgreed
                            ? () {
                                context.read<AuthBloc>().add(
                                      AuthTermsAcceptanceRequested(
                                          accepted: true),
                                    );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C3E50),
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _getLocalizedButton(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getLocalizedTitle() {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Terms of Service',
      AppLanguage.korean: '이용약관',
      AppLanguage.japanese: '利用規約',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedSubtitle() {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> subtitles = {
      AppLanguage.english: 'Please review and agree',
      AppLanguage.korean: '서비스 이용을 위해 검토해주세요',
      AppLanguage.japanese: 'サービス利用のため確認してください',
    };
    return subtitles[language] ?? subtitles[AppLanguage.korean]!;
  }

  String _getLocalizedAgreement() {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> agreements = {
      AppLanguage.english: 'I agree to all terms above',
      AppLanguage.korean: '위 약관에 모두 동의합니다',
      AppLanguage.japanese: '上記の利用規約にすべて同意します',
    };
    return agreements[language] ?? agreements[AppLanguage.korean]!;
  }

  String _getLocalizedButton() {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> buttons = {
      AppLanguage.english: 'Agree and Continue',
      AppLanguage.korean: '동의하고 계속하기',
      AppLanguage.japanese: '同意して続ける',
    };
    return buttons[language] ?? buttons[AppLanguage.korean]!;
  }

  Map<String, String> _getLocalizedPersonalDataCollection(
      AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return {
          'title': PersonalDataCollectionEn.title,
          'content': PersonalDataCollectionEn.content,
        };
      case AppLanguage.japanese:
        return {
          'title': PersonalDataCollectionJp.title,
          'content': PersonalDataCollectionJp.content,
        };
      case AppLanguage.korean:
      default:
        return {
          'title': PersonalDataCollection.title,
          'content': PersonalDataCollection.content,
        };
    }
  }
}
