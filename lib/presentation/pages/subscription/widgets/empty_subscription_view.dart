import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class EmptySubscriptionView extends StatelessWidget {
  const EmptySubscriptionView({super.key});

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> texts = {
      AppLanguage.english: 'No Subscriptions Yet',
      AppLanguage.korean: '등록된 구독이 없습니다',
      AppLanguage.japanese: 'サブスクはまだありません',
    };
    return texts[language] ?? texts[AppLanguage.korean]!;
  }

  String _getLocalizedSubtitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> texts = {
      AppLanguage.english: 'Add your subscriptions to track monthly expenses',
      AppLanguage.korean: '정기적으로 결제되는 구독을 등록하고 관리해보세요',
      AppLanguage.japanese: '定期的な支払いを登録して管理しましょう',
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
            Icons.subscriptions_outlined,
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
