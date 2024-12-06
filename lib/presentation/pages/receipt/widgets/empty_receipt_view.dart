import 'package:flutter/material.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmptyReceiptView extends StatelessWidget {
  const EmptyReceiptView({super.key});

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> texts = {
      AppLanguage.english: 'No Receipts Yet',
      AppLanguage.korean: '등록된 영수증이 없습니다',
      AppLanguage.japanese: 'レシートがありません',
    };
    return texts[language] ?? texts[AppLanguage.korean]!;
  }

  String _getLocalizedSubtitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> texts = {
      AppLanguage.english: 'Scan your first receipt to get started',
      AppLanguage.korean: '영수증을 스캔하여 자동으로 지출을 기록해보세요',
      AppLanguage.japanese: 'レシートをスキャンして支出を記録しましょう',
    };
    return texts[language] ?? texts[AppLanguage.korean]!;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _getLocalizedTitle(context),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _getLocalizedSubtitle(context),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
