import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_event.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_state.dart';
import 'package:finpal/presentation/pages/user_registration/widgets/birth_year_section.dart';
import 'package:finpal/presentation/pages/user_registration/widgets/gender_selection_section.dart';
import 'package:finpal/presentation/pages/user_registration/widgets/location_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_bloc.dart';
import 'package:go_router/go_router.dart';
import 'widgets/language_setting_section.dart';
import 'widgets/location_setting_section.dart';
import 'widgets/currency_setting_section.dart';
import 'widgets/personal_info_section.dart';

class UserRegistrationPage extends StatelessWidget {
  const UserRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _getLocalizedTitle(context),
          style: const TextStyle(
            color: Color(0xFF1C2833),
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<UserRegistrationBloc, UserRegistrationState>(
        listener: (context, state) {
          if (state is UserRegistrationSuccess) {
            context.go('/home');
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLocalizedDescription(context),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF34495E),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const PersonalInfoSection(),
                  const SizedBox(height: 24),
                  const LocationSection(),
                  const SizedBox(height: 24),
                  const CurrencySettingSection(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Profile Setup',
      AppLanguage.korean: '프로필 설정',
      AppLanguage.japanese: 'プロフィール設定',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  Widget _buildSubmitButton(BuildContext context, UserRegistrationState state) {
    return ElevatedButton(
      onPressed: state is UserRegistrationInProgress &&
              state.location != null &&
              state.gender != null &&
              state.birthYear != null
          ? () {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthRequiresRegistration) {
                context.read<UserRegistrationBloc>().add(
                      UserRegistrationCompleted(
                        userId: authState.user.id,
                        authBloc: context.read<AuthBloc>(),
                      ),
                    );
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0C2340),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        disabledBackgroundColor: const Color(0xFFCCCCCC),
      ),
      child: Text(
        _getLocalizedButtonText(context),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  String _getLocalizedButtonText(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> texts = {
      AppLanguage.english: 'Complete Setup',
      AppLanguage.korean: '설정 완료',
      AppLanguage.japanese: '設定完了',
    };
    return texts[language] ?? texts[AppLanguage.korean]!;
  }

  String _getLocalizedDescription(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> descriptions = {
      AppLanguage.english:
          'Please fill in your basic information to get started.',
      AppLanguage.korean: '서비스 이용을 위해 기본 정보를 입력해주세요.',
      AppLanguage.japanese: 'サービスを利用するために基本情報を入力してください。',
    };
    return descriptions[language] ?? descriptions[AppLanguage.korean]!;
  }
}
