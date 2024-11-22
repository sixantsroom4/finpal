import 'package:finpal/presentation/bloc/user_registration/user_registration_event.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_state.dart';
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
        title: const Text(
          '프로필 설정',
          style: TextStyle(
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
                  const Text(
                    '환영합니다!\n서비스 이용을 위해 기본 정보를 입력해주세요.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF34495E),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const LanguageSettingSection(),
                  const SizedBox(height: 24),
                  const LocationSettingSection(),
                  const SizedBox(height: 24),
                  const CurrencySettingSection(),
                  const SizedBox(height: 24),
                  const PersonalInfoSection(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: state is UserRegistrationInProgress &&
                            state.location != null &&
                            state.gender != null &&
                            state.birthYear != null
                        ? () {
                            context.read<UserRegistrationBloc>().add(
                                  const UserRegistrationCompleted(userId: ''),
                                );
                            context.go('/home');
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C2340),
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: const Text(
                      '시작하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
