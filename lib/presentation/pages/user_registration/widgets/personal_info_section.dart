import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_event.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_bloc.dart';
import 'package:finpal/core/utils/language_utils.dart';

class PersonalInfoSection extends StatelessWidget {
  const PersonalInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRegistrationBloc, UserRegistrationState>(
      builder: (context, state) {
        return BlocBuilder<AppLanguageBloc, AppLanguageState>(
          builder: (context, languageState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '개인정보',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0C2340),
                  ),
                ),
                const SizedBox(height: 12),
                // 성별 선택
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E8EC)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: state is UserRegistrationInProgress
                        ? state.gender
                        : null,
                    decoration: const InputDecoration(
                      labelText: '성별',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'male',
                        child:
                            Text(getGenderText('male', languageState.language)),
                      ),
                      DropdownMenuItem(
                        value: 'female',
                        child: Text(
                            getGenderText('female', languageState.language)),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Text(
                            getGenderText('other', languageState.language)),
                      ),
                    ],
                    onChanged: (newValue) {
                      if (newValue != null) {
                        context
                            .read<UserRegistrationBloc>()
                            .add(GenderChanged(newValue));
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // 출생년도 선택
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E8EC)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: '출생년도 (예: 1990)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      helperText: '4자리 숫자로 입력해주세요',
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    onChanged: (value) {
                      if (value.length == 4) {
                        final year = int.tryParse(value);
                        if (year != null &&
                            year >= 1900 &&
                            year <= DateTime.now().year) {
                          context.read<UserRegistrationBloc>().add(
                                BirthYearChanged(year),
                              );
                        }
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '출생년도를 입력해주세요';
                      }
                      final year = int.tryParse(value);
                      if (year == null ||
                          year < 1900 ||
                          year > DateTime.now().year) {
                        return '올바른 출생년도를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
