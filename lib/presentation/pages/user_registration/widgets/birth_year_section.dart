import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_event.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BirthYearSection extends StatelessWidget {
  const BirthYearSection({super.key});

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
              child: ListTile(
                title: Text(
                  state.birthYear != null
                      ? '${state.birthYear}년'
                      : _getLocalizedHint(context),
                  style: TextStyle(
                    color: state.birthYear != null ? Colors.black : Colors.grey,
                  ),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _showYearPicker(context, state.birthYear),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Birth Year',
      AppLanguage.korean: '출생년도',
      AppLanguage.japanese: '生年',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedHint(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> hints = {
      AppLanguage.english: 'Select your birth year',
      AppLanguage.korean: '출생년도를 선택해주세요',
      AppLanguage.japanese: '生年を選択してください',
    };
    return hints[language] ?? hints[AppLanguage.korean]!;
  }

  String _getLocalizedCancel(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> texts = {
      AppLanguage.english: 'Cancel',
      AppLanguage.korean: '취소',
      AppLanguage.japanese: 'キャンセル',
    };
    return texts[language] ?? texts[AppLanguage.korean]!;
  }

  String _getLocalizedConfirm(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> texts = {
      AppLanguage.english: 'Confirm',
      AppLanguage.korean: '확인',
      AppLanguage.japanese: '確認',
    };
    return texts[language] ?? texts[AppLanguage.korean]!;
  }

  void _showYearPicker(BuildContext context, int? currentYear) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(_getLocalizedCancel(context)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(_getLocalizedConfirm(context)),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime(currentYear ?? 2000),
                  maximumDate: DateTime.now(),
                  minimumDate: DateTime(1900),
                  onDateTimeChanged: (DateTime dateTime) {
                    context.read<UserRegistrationBloc>().add(
                          BirthYearChanged(dateTime.year),
                        );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
