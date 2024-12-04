import 'dart:io';
import 'package:finpal/domain/entities/receipt.dart';
import 'package:finpal/presentation/pages/receipt/widgets/create_expense_from_receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/receipt/receipt_bloc.dart';
import '../../bloc/receipt/receipt_event.dart';
import '../../bloc/receipt/receipt_state.dart';
import 'receipt_page.dart';
import 'package:intl/intl.dart';
import 'widgets/edit_receipt_info_bottom_sheet.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';

class ReceiptScanResultPage extends StatefulWidget {
  final String imagePath;

  const ReceiptScanResultPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<ReceiptScanResultPage> createState() => _ReceiptScanResultPageState();
}

class _ReceiptScanResultPageState extends State<ReceiptScanResultPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScanningReceipt();
    });
  }

  void _startScanningReceipt() {
    debugPrint('영수증 스캔 시작');
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      debugPrint('사용자 인증됨: ${authState.user.id}');
      context.read<ReceiptBloc>().add(ScanReceipt(
            imagePath: widget.imagePath,
            userId: authState.user.id,
            userCurrency: authState.user.settings?['currency'] ?? 'KRW',
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedTitle(context)),
      ),
      body: BlocConsumer<ReceiptBloc, ReceiptState>(
        listener: (context, state) {
          if (state is ReceiptOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is ReceiptError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ReceiptScanInProgress) {
            return _buildLoadingState(context);
          }

          if (state is ReceiptScanSuccess || state is ReceiptLoaded) {
            final receipt = state is ReceiptScanSuccess
                ? state.receipt
                : (state as ReceiptLoaded).receipts.first;
            return _buildResultState(context, receipt);
          }

          if (state is ReceiptError) {
            return Center(
              child: Text(_getLocalizedError(context, state.message)),
            );
          }

          return Center(
            child: Text(_getLocalizedDefaultError(context)),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            _getLocalizedLabel(context, 'analyzing'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            _getLocalizedLabel(context, 'please_wait'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Receipt Analysis Result',
      AppLanguage.korean: '영수증 분석 결',
      AppLanguage.japanese: 'レシート分析結果',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'analyzing': {
        AppLanguage.english: 'AI is analyzing your receipt',
        AppLanguage.korean: 'AI가 영수증을 분석하고 있습니다',
        AppLanguage.japanese: 'AIがレシートを分析しています',
      },
      'please_wait': {
        AppLanguage.english: 'Please wait...',
        AppLanguage.korean: '잠시만 기다려주세요...',
        AppLanguage.japanese: 'お待ちください...',
      },
      'items': {
        AppLanguage.english: 'Items',
        AppLanguage.korean: '구매 항목',
        AppLanguage.japanese: '購入項目',
      },
      'total': {
        AppLanguage.english: 'Total',
        AppLanguage.korean: '총액',
        AppLanguage.japanese: '合計',
      },
      'create_expense': {
        AppLanguage.english: 'Create Expense',
        AppLanguage.korean: '지출 내역 생성',
        AppLanguage.japanese: '支出を作成',
      },
      'edit_receipt': {
        AppLanguage.english: 'Edit Receipt Info',
        AppLanguage.korean: '영수증 정보 수정',
        AppLanguage.japanese: 'レシート情報を編集',
      },
      'retake_receipt': {
        AppLanguage.english: 'Retake Receipt',
        AppLanguage.korean: '영수증 재촬영',
        AppLanguage.japanese: 'レシートを撮り直す',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  Widget _buildResultState(BuildContext context, Receipt receipt) {
    final formatter = _getCurrencyFormatter(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showFullScreenImage(context, widget.imagePath),
            child: Hero(
              tag: 'receipt_image',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(widget.imagePath)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(Icons.store,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receipt.merchantName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              _getLocalizedDate(context, receipt.date),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  if (receipt.items.isNotEmpty) ...[
                    Text(
                      _getLocalizedLabel(context, 'items'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...receipt.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(item.name),
                              ),
                              Text(
                                  '${formatter.format(item.price)} x ${item.quantity}'),
                              const SizedBox(width: 8),
                              Text(
                                formatter.format(item.totalPrice),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )),
                    const Divider(height: 32),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getLocalizedLabel(context, 'total'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        formatter.format(receipt.totalAmount),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (receipt.expenseId == null) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => CreateExpenseFromReceipt(
                            receipt: receipt,
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_card),
                      label:
                          Text(_getLocalizedLabel(context, 'create_expense')),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => EditReceiptInfoBottomSheet(
                            receipt: receipt,
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: Text(_getLocalizedLabel(context, 'edit_receipt')),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _retakeReceipt(context),
                      icon: const Icon(Icons.camera_alt),
                      label:
                          Text(_getLocalizedLabel(context, 'retake_receipt')),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Hero(
                  tag: 'receipt_image',
                  child: Image.file(File(imagePath)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _retakeReceipt(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ReceiptPage(),
      ),
    );
  }

  String _getLocalizedError(BuildContext context, String message) {
    final language = context.read<AppLanguageBloc>().state.language;
    Map<AppLanguage, String Function(String)> errors = {
      AppLanguage.english: (msg) => 'Error: $msg',
      AppLanguage.korean: (msg) => '오류: $msg',
      AppLanguage.japanese: (msg) => 'エラー: $msg',
    };
    return errors[language]?.call(message) ??
        errors[AppLanguage.korean]!(message);
  }

  String _getLocalizedDefaultError(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> errors = {
      AppLanguage.english: 'An error occurred while analyzing the receipt.',
      AppLanguage.korean: '영수증 분석 중 오류가 발생했습니다.',
      AppLanguage.japanese: 'レシートの分析中にラーが発生しました。',
    };
    return errors[language] ?? errors[AppLanguage.korean]!;
  }

  String _getLocalizedDate(BuildContext context, DateTime date) {
    final language = context.read<AppLanguageBloc>().state.language;
    switch (language) {
      case AppLanguage.english:
        return DateFormat('MMM d, yyyy').format(date);
      case AppLanguage.japanese:
        return DateFormat('yyyy年 M月 d日').format(date);
      case AppLanguage.korean:
      default:
        return DateFormat('yyyy년 M월 d일').format(date);
    }
  }

  String _getLocalizedSuccessMessage(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> messages = {
      AppLanguage.english: 'Receipt has been saved.',
      AppLanguage.korean: '영수증이 저장되었습니다.',
      AppLanguage.japanese: 'レシートが保存されました。',
    };
    return messages[language] ?? messages[AppLanguage.korean]!;
  }

  NumberFormat _getCurrencyFormatter(BuildContext context) {
    final currency = context.read<AppSettingsBloc>().state.currency;

    final Map<String, NumberFormat> formatters = {
      'USD': NumberFormat.currency(locale: 'en_US', symbol: '\$'),
      'JPY': NumberFormat.currency(locale: 'ja_JP', symbol: '¥'),
      'EUR': NumberFormat.currency(locale: 'de_DE', symbol: '€'),
      'KRW': NumberFormat.currency(locale: 'ko_KR', symbol: '₩'),
    };

    return formatters[currency] ?? formatters['KRW']!;
  }
}
