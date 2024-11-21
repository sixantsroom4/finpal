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

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool _isAgreed = false;
  final Set<int> _expandedItems = {};
  AppLanguage _selectedLanguage = AppLanguage.korean;

  List<Map<String, String>> _terms = [];

  @override
  void initState() {
    super.initState();
    _terms = TermsService.getTermsByLanguage(_selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _getLocalizedTitle(),
          style: const TextStyle(
            color: Color(0xFF1C2833),
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: LanguageSelector(
              selectedLanguage: _selectedLanguage,
              onLanguageChanged: (AppLanguage newValue) {
                setState(() {
                  _selectedLanguage = newValue;
                  _terms = TermsService.getTermsByLanguage(newValue);
                });
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  _getLocalizedDescription(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF34495E),
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
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
              ],
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
                  ),
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
                                AuthTermsAcceptanceRequested(accepted: true),
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
    );
  }

  String _getLocalizedTitle() {
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Terms and Conditions',
      AppLanguage.korean: '이용 약관 동의',
      AppLanguage.japanese: '利用規約の同意',
    };
    return titles[_selectedLanguage] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedDescription() {
    const Map<AppLanguage, String> descriptions = {
      AppLanguage.english:
          'Please agree to the following terms to use the service.',
      AppLanguage.korean: '서비스 이용을 위해 아래 약관에 동의해주세요.',
      AppLanguage.japanese: 'サービスを利用するには以下の利用規約に同意してください。',
    };
    return descriptions[_selectedLanguage] ?? descriptions[AppLanguage.korean]!;
  }

  String _getLocalizedAgreement() {
    const Map<AppLanguage, String> agreements = {
      AppLanguage.english: 'I agree to all terms above',
      AppLanguage.korean: '위 약관에 모두 동의합니다',
      AppLanguage.japanese: '上記の利用規約にすべて同意します',
    };
    return agreements[_selectedLanguage] ?? agreements[AppLanguage.korean]!;
  }

  String _getLocalizedButton() {
    const Map<AppLanguage, String> buttons = {
      AppLanguage.english: 'Agree and Continue',
      AppLanguage.korean: '동의하고 계속하기',
      AppLanguage.japanese: '同意して続ける',
    };
    return buttons[_selectedLanguage] ?? buttons[AppLanguage.korean]!;
  }
}
