import 'dart:async';

import 'package:finpal/presentation/bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_bloc.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_event.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_state.dart';
import 'package:finpal/presentation/pages/receipt/receipt_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class ReceiptListPage extends StatefulWidget {
  @override
  State<ReceiptListPage> createState() => _ReceiptListPageState();
}

class _ReceiptListPageState extends State<ReceiptListPage> {
  late StreamSubscription<void> _receiptSubscription;

  @override
  void initState() {
    super.initState();
    final receiptBloc = context.read<ReceiptBloc>();
    _receiptSubscription = receiptBloc.receiptStream.listen((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<ReceiptBloc>().add(LoadReceipts(authState.user.id));
      }
    });
  }

  @override
  void dispose() {
    _receiptSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReceiptBloc, ReceiptState>(
      builder: (context, state) {
        if (state is ReceiptScanInProgress) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(_getLocalizedLabel(context, 'analyzing')),
              ],
            ),
          );
        } else if (state is ReceiptAnalysisSuccess) {
          return SnackBar(
            content: Text(_getLocalizedLabel(context, 'analysis_complete')),
            backgroundColor: Colors.green,
          );
        } else if (state is ReceiptError) {
          return SnackBar(
            content:
                Text(state.message ?? _getLocalizedLabel(context, 'error')),
            backgroundColor: Colors.red,
          );
        }

        if (state is ReceiptLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReceiptError) {
          return Center(child: Text(state.message));
        }

        if (state is ReceiptLoaded) {
          if (state.receipts.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            itemCount: state.receipts.length,
            itemBuilder: (context, index) {
              final receipt = state.receipts[index];
              return ReceiptListItem(receipt: receipt);
            },
          );
        }

        return _buildEmptyState(context);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getLocalizedLabel(context, 'empty_title'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(
            _getLocalizedLabel(context, 'empty_subtitle'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'analyzing': {
        AppLanguage.english: 'Analyzing receipt...',
        AppLanguage.korean: '영수증 분석 중...',
        AppLanguage.japanese: 'レシートを分析中...',
      },
      'analysis_complete': {
        AppLanguage.english: 'Receipt analysis completed.',
        AppLanguage.korean: '영수증 분석이 완료되었습니다.',
        AppLanguage.japanese: 'レシートの分析が完了しました。',
      },
      'error': {
        AppLanguage.english: 'An error occurred while processing the receipt.',
        AppLanguage.korean: '영수증 처리 중 오류가 발생했습니다.',
        AppLanguage.japanese: 'レシートの処理中にエラーが発生しました。',
      },
      'empty_title': {
        AppLanguage.english: 'No Saved Receipts',
        AppLanguage.korean: '저장된 영수증이 없습니다',
        AppLanguage.japanese: '保存されたレシートがありません',
      },
      'empty_subtitle': {
        AppLanguage.english: 'Scan receipts to record expenses automatically',
        AppLanguage.korean: '영수증을 스캔하여 자동으로 지출을 기록해보세요',
        AppLanguage.japanese: 'レシートをスキャンして自動的に支出を記録しましょう',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }
}
