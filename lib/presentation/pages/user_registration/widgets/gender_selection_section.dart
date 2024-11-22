import 'package:finpal/core/constants/app_languages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_event.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_state.dart';
import 'package:finpal/core/utils/language_utils.dart';

class GenderSelectionSection extends StatelessWidget {
  const GenderSelectionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRegistrationBloc, UserRegistrationState>(
      builder: (context, state) {
        return BlocBuilder<AppLanguageBloc, AppLanguageState>(
          builder: (context, languageState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLocalizedTitle(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0C2340),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E8EC)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: state is UserRegistrationInProgress
                        ? state.gender
                        : null,
                    decoration: InputDecoration(
                      labelText: _getLocalizedLabel(context),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
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
      AppLanguage.english: 'Gender',
      AppLanguage.korean: '성별',
      AppLanguage.japanese: '性別',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedLabel(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> labels = {
      AppLanguage.english: 'Select your gender',
      AppLanguage.korean: '성별을 선택해주세요',
      AppLanguage.japanese: '性別を選択してください',
    };
    return labels[language] ?? labels[AppLanguage.korean]!;
  }
}
