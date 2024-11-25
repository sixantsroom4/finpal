import 'package:flutter/material.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_event.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_state.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/utils/language_utils.dart';

class LanguageSettingSection extends StatelessWidget {
  const LanguageSettingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRegistrationBloc, UserRegistrationState>(
      builder: (context, state) {
        if (state is! UserRegistrationInProgress) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '앱 언어 설정',
              style: TextStyle(
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
              child: BlocBuilder<AppLanguageBloc, AppLanguageState>(
                builder: (context, languageState) {
                  return DropdownButtonFormField<AppLanguage>(
                    value: languageState.language,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    items: AppLanguage.values.map((language) {
                      return DropdownMenuItem(
                        value: language,
                        child: Text(getLanguageDisplayName(language)),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        context
                            .read<AppLanguageBloc>()
                            .add(AppLanguageChanged(newValue));
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
