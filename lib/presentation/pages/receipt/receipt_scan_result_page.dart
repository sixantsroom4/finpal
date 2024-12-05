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
import 'package:finpal/core/utils/currency_utils.dart';

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
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        title: Text(
          _getLocalizedTitle(context),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Container(
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
          ),
        ),
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
            return Container(
              color: Colors.white,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C3E50).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF2C3E50)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _getLocalizedLabel(context, 'analyzing'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getLocalizedLabel(context, 'please_wait'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // 분석 단계 표시
                  _buildAnalysisStep('step_scanning', true),
                  _buildAnalysisStep('step_extracting', false),
                  _buildAnalysisStep('step_processing', false),
                ],
              ),
            );
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

  Widget _buildAnalysisStep(String step, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted ? Colors.green : Colors.grey[400],
            size: 24,
          ),
          const SizedBox(width: 16),
          Text(
            step,
            style: TextStyle(
              fontSize: 16,
              color: isCompleted ? const Color(0xFF2C3E50) : Colors.grey[600],
              fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shadowColor: const Color(0xFF2C3E50).withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(File(widget.imagePath)),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            shadowColor: const Color(0xFF2C3E50).withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C3E50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.store,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receipt.merchantName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            Text(
                              _getLocalizedDate(context, receipt.date),
                              style: TextStyle(
                                fontSize: 16,
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...receipt.items
                        .map((item) => _buildItemRow(context, item)),
                    const Divider(height: 32),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getLocalizedLabel(context, 'total'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        _getLocalizedAmount(context, receipt.totalAmount),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditReceipt(context, receipt),
                  icon: const Icon(Icons.edit, color: Color(0xFF2C3E50)),
                  label: Text(
                    _getLocalizedLabel(context, 'edit_receipt'),
                    style: const TextStyle(color: Color(0xFF2C3E50)),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF2C3E50)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _createExpense(context, receipt),
                  icon: const Icon(Icons.add_card, color: Colors.white),
                  label: Text(
                    _getLocalizedLabel(context, 'create_expense'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
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

  String _getLocalizedAmount(BuildContext context, double amount) {
    final currency = context.read<AppSettingsBloc>().state.currency;
    final formatter = NumberFormat('#,###');
    final formattedAmount = formatter.format(amount);
    return '$formattedAmount${CurrencyUtils.getCurrencySymbol(currency)}';
  }

  Widget _buildItemRow(BuildContext context, ReceiptItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(item.name)),
          Text(
              '${_getLocalizedAmount(context, item.price)} x ${item.quantity}'),
          const SizedBox(width: 8),
          Text(
            _getLocalizedAmount(context, item.totalPrice),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showEditReceipt(BuildContext context, Receipt receipt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditReceiptInfoBottomSheet(receipt: receipt),
    );
  }

  void _createExpense(BuildContext context, Receipt receipt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CreateExpenseFromReceipt(receipt: receipt),
    );
  }
}
