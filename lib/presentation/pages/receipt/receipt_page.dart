// lib/presentation/pages/receipt/receipt_page.dart
import 'package:finpal/domain/entities/receipt.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_event.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_state.dart';
import 'package:finpal/presentation/pages/receipt/receipt_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../bloc/receipt/receipt_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'widgets/scan_receipt_fab.dart';
import 'widgets/receipt_grid_item.dart';
import 'receipt_scan_result_page.dart';
import 'receipt_preview_page.dart';
import 'package:go_router/go_router.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final _numberFormat = NumberFormat('#,###');
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReceipts();
    });
  }

  void _loadReceipts() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      debugPrint('영수증 목록 로드 시작: ${authState.user.id}');
      context.read<ReceiptBloc>().add(LoadReceipts(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedTitle(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scanReceipt(context),
        tooltip: _getLocalizedTooltip(context),
        child: const Icon(Icons.document_scanner),
      ),
      body: BlocConsumer<ReceiptBloc, ReceiptState>(
        listener: (context, state) {
          if (state is ReceiptError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(_getLocalizedError(context, state.message))),
            );
          }
          if (state is ReceiptOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(_getLocalizedSuccess(context, state.message))),
            );
          }
        },
        builder: (context, state) {
          if (state is ReceiptLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReceiptEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getLocalizedEmptyTitle(context),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getLocalizedEmptySubtitle(context),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_getLocalizedLabel(context, 'this_month')),
                            Text(
                              _getLocalizedCount(
                                  context, state.receipts.length),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_getLocalizedLabel(context, 'total_amount')),
                            Text(
                              _getLocalizedAmount(context, state.totalAmount),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 영수증 그리드
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final receipt = state.receipts[index];
                      return ReceiptGridItem(
                        receipt: receipt,
                        onTap: () => _showReceiptDetails(context, receipt),
                      );
                    },
                    childCount: state.receipts.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.date_range),
            title: Text(_getLocalizedLabel(context, 'sort_by_date')),
            onTap: () {
              context.read<ReceiptBloc>().add(
                    SortReceipts(SortOption.date),
                  );
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: Text(_getLocalizedLabel(context, 'sort_by_store')),
            onTap: () {
              context.read<ReceiptBloc>().add(
                    SortReceipts(SortOption.store),
                  );
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text(_getLocalizedLabel(context, 'sort_by_amount')),
            onTap: () {
              context.read<ReceiptBloc>().add(
                    SortReceipts(SortOption.amount),
                  );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showReceiptDetails(BuildContext context, Receipt receipt) {
    context.go('/receipts/${receipt.id}');
  }

  Future<void> _scanReceipt(BuildContext context) async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null && context.mounted) {
        final shouldRetake = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptPreviewPage(
              imagePath: image.path,
            ),
          ),
        );

        if (shouldRetake == true && context.mounted) {
          _scanReceipt(context); // 재촬영
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('영수증 스캔 중 오류가 발생했습니다: ${e.toString()}')),
      );
    }
  }

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Receipts',
      AppLanguage.korean: '영수증',
      AppLanguage.japanese: 'レシート',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedTooltip(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> tooltips = {
      AppLanguage.english: 'Scan Receipt',
      AppLanguage.korean: '영수증 스캔',
      AppLanguage.japanese: 'レシートをスキャン',
    };
    return tooltips[language] ?? tooltips[AppLanguage.korean]!;
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

  String _getLocalizedSuccess(BuildContext context, String message) {
    final language = context.read<AppLanguageBloc>().state.language;
    Map<AppLanguage, String Function(String)> successes = {
      AppLanguage.english: (msg) => 'Success: $msg',
      AppLanguage.korean: (msg) => '성공: $msg',
      AppLanguage.japanese: (msg) => '成功: $msg',
    };
    return successes[language]?.call(message) ??
        successes[AppLanguage.korean]!(message);
  }

  String _getLocalizedEmptyTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> texts = {
      AppLanguage.english: 'No Receipts',
      AppLanguage.korean: '저장된 영수증이 없습니다',
      AppLanguage.japanese: '保存されたレシートがありません',
    };
    return texts[language] ?? texts[AppLanguage.korean]!;
  }

  String _getLocalizedEmptySubtitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> texts = {
      AppLanguage.english: 'Scan receipts to record expenses automatically',
      AppLanguage.korean: '영수증을 스캔하여 자동으로 지출을 기록해보세요',
      AppLanguage.japanese: 'レシートをスキャンして自動的に支出を記録しましょう',
    };
    return texts[language] ?? texts[AppLanguage.korean]!;
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'this_month': {
        AppLanguage.english: 'This Month',
        AppLanguage.korean: '이번 달 영수증',
        AppLanguage.japanese: '今月のレシート',
      },
      'total_amount': {
        AppLanguage.english: 'Total Amount',
        AppLanguage.korean: '총 지출액',
        AppLanguage.japanese: '総支出額',
      },
      'sort_by_date': {
        AppLanguage.english: 'Date',
        AppLanguage.korean: '날짜',
        AppLanguage.japanese: '日付',
      },
      'sort_by_store': {
        AppLanguage.english: 'Store',
        AppLanguage.korean: '가맹점',
        AppLanguage.japanese: '店舗',
      },
      'sort_by_amount': {
        AppLanguage.english: 'Amount',
        AppLanguage.korean: '금액',
        AppLanguage.japanese: '金額',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  String _getLocalizedCount(BuildContext context, int count) {
    final language = context.read<AppLanguageBloc>().state.language;
    switch (language) {
      case AppLanguage.english:
        return '$count receipts';
      case AppLanguage.japanese:
        return '$count枚';
      case AppLanguage.korean:
      default:
        return '${count}장';
    }
  }

  String _getLocalizedAmount(BuildContext context, double amount) {
    final currency = context.read<AppSettingsBloc>().state.currency;
    final formattedAmount = _numberFormat.format(amount);

    final currencySymbols = {
      'KRW': '원',
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
    };

    final symbol = currencySymbols[currency] ?? currencySymbols['KRW']!;

    // 통화별 표시 형식
    switch (currency) {
      case 'USD':
      case 'EUR':
        return '$symbol$formattedAmount';
      case 'JPY':
        return '¥$formattedAmount';
      case 'KRW':
      default:
        return '$formattedAmount$symbol';
    }
  }
}
