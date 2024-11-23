import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_event.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_bloc.dart';
import 'package:finpal/core/utils/language_utils.dart';
import 'package:finpal/core/constants/app_languages.dart';

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
                Row(
                  children: [
                    Text(
                      _getLocalizedTitle(context),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0C2340),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.person, color: Color(0xFF0C2340)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getLocalizedDescription(context),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
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
                    decoration: InputDecoration(
                      labelText: _getLocalizedGenderLabel(context),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
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
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(_getLocalizedBirthYearTitle(context)),
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
                              ? '${state.birthYear}${_getLocalizedYear(context)}'
                              : _getLocalizedBirthYearHint(context),
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
                Text(
                  _getLocalizedNote(context),
                  style: const TextStyle(
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

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Personal Information',
      AppLanguage.korean: '개인정보',
      AppLanguage.japanese: '個人情報',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedDescription(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> descriptions = {
      AppLanguage.english: 'Last step for using the service! 🎉',
      AppLanguage.korean: '서비스 이용을 위한 마지막 단계입니다! 🎉',
      AppLanguage.japanese: 'サービス利用のための最後のステップです! 🎉',
    };
    return descriptions[language] ?? descriptions[AppLanguage.korean]!;
  }

  String _getLocalizedGenderLabel(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> labels = {
      AppLanguage.english: 'Select Gender 👤',
      AppLanguage.korean: '성별 선택 👤',
      AppLanguage.japanese: '性別選択 👤',
    };
    return labels[language] ?? labels[AppLanguage.korean]!;
  }

  String _getLocalizedBirthYearTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Select Birth Year 🎉',
      AppLanguage.korean: '출생년도 선택 🎉',
      AppLanguage.japanese: '生年選択 🎉',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedBirthYearHint(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> hints = {
      AppLanguage.english: 'Select your birth year',
      AppLanguage.korean: '출생년도를 선택해주세요',
      AppLanguage.japanese: '生年を選択してください',
    };
    return hints[language] ?? hints[AppLanguage.korean]!;
  }

  String _getLocalizedYear(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> years = {
      AppLanguage.english: '',
      AppLanguage.korean: '년',
      AppLanguage.japanese: '年',
    };
    return years[language] ?? years[AppLanguage.korean]!;
  }

  String _getLocalizedNote(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> notes = {
      AppLanguage.english:
          '* The information provided will only be used for service improvement 🔒',
      AppLanguage.korean: '* 입력하신 정보는 서비스 개선을 위해서만 사용됩니다 🔒',
      AppLanguage.japanese: '* 入力された情報はサービス改善のためにのみ使用されます 🔒',
    };
    return notes[language] ?? notes[AppLanguage.korean]!;
  }
}
