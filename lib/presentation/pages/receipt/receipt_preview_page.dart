import 'dart:io';
import 'package:finpal/presentation/pages/receipt/receipt_scan_result_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/receipt/receipt_bloc.dart';
import '../../bloc/receipt/receipt_event.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class ReceiptPreviewPage extends StatelessWidget {
  final String imagePath;

  const ReceiptPreviewPage({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedTitle(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_getLocalizedLabel(context, 'retake')),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _analyzeReceipt(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(_getLocalizedLabel(context, 'analyze')),
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Receipt Preview',
      AppLanguage.korean: '영수증 미리보기',
      AppLanguage.japanese: 'レシートプレビュー',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'retake': {
        AppLanguage.english: 'Retake',
        AppLanguage.korean: '다시 찍기',
        AppLanguage.japanese: '撮り直す',
      },
      'analyze': {
        AppLanguage.english: 'Analyze Receipt',
        AppLanguage.korean: '영수증 분석하기',
        AppLanguage.japanese: 'レシートを分析する',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  void _analyzeReceipt(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ReceiptBloc>().add(
            ScanReceipt(
              imagePath: imagePath,
              userId: authState.user.id,
            ),
          );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScanResultPage(
            imagePath: imagePath,
          ),
        ),
      );
    }
  }
}
