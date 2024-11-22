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
                const Row(
                  children: [
                    Text(
                      '개인정보',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0C2340),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.person, color: Color(0xFF0C2340)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '서비스 이용을 위한 마지막 단계입니다! 🎉',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
                // 성별 선택
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E8EC)),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: state is UserRegistrationInProgress
                        ? state.gender
                        : null,
                    decoration: const InputDecoration(
                      labelText: '성별 선택 👤',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'male',
                        child: Row(
                          children: [
                            const Text('👨 '),
                            Text(getGenderText('male', languageState.language)),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'female',
                        child: Row(
                          children: [
                            const Text('👩 '),
                            Text(getGenderText(
                                'female', languageState.language)),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Row(
                          children: [
                            const Text('🧑 '),
                            Text(
                                getGenderText('other', languageState.language)),
                          ],
                        ),
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
                const SizedBox(height: 20),
                // 출생년도 선택
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('출생년도 선택 🎉'),
                          content: SizedBox(
                            height: 300,
                            width: 300,
                            child: YearPicker(
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              selectedDate:
                                  state is UserRegistrationInProgress &&
                                          state.birthYear != null
                                      ? DateTime(state.birthYear!)
                                      : DateTime.now(),
                              onChanged: (DateTime dateTime) {
                                context.read<UserRegistrationBloc>().add(
                                      BirthYearChanged(dateTime.year),
                                    );
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E8EC)),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state is UserRegistrationInProgress &&
                                  state.birthYear != null
                              ? '${state.birthYear}년'
                              : '출생년도를 선택해주세요',
                          style: TextStyle(
                            color: state is UserRegistrationInProgress &&
                                    state.birthYear != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '* 입력하신 정보는 서비스 개선을 위서만 사용됩니다 🔒',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontStyle: FontStyle.italic,
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
