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
import 'package:intl/date_symbol_data_local.dart';
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
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Receipt List에 대한 extension 추가
extension ReceiptListExtension on List<Receipt> {
  Map<String, double> groupByCurrency() {
    final totals = <String, double>{};
    for (var receipt in this) {
      totals.update(
        receipt.currency,
        (value) => value + receipt.totalAmount,
        ifAbsent: () => receipt.totalAmount,
      );
    }
    return totals;
  }
}

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final _numberFormat = NumberFormat('#,###');
  final _imagePicker = ImagePicker();

  // 정렬 관련 상태 추가
  SortOption _sortOption = SortOption.date;
  bool _ascending = false;

  // SharedPreferences 키
  static const String _sortOptionKey = 'receipt_sort_option';
  static const String _sortAscendingKey = 'receipt_sort_ascending';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _loadSortPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReceipts();
    });
  }

  // 정렬 설정 불러오기
  Future<void> _loadSortPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sortOption = SortOption.values[prefs.getInt(_sortOptionKey) ?? 0];
      _ascending = prefs.getBool(_sortAscendingKey) ?? false;
    });
  }

  // 정렬 설정 저장
  Future<void> _saveSortPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sortOptionKey, _sortOption.index);
    await prefs.setBool(_sortAscendingKey, _ascending);
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
      appBar: _buildAppBar(),
      body: BlocBuilder<ReceiptBloc, ReceiptState>(
        builder: (context, state) {
          if (state is ReceiptLoaded) {
            if (state.receipts.isEmpty) {
              return _buildEmptyState(context);
            }

            final sortedReceipts = _sortReceipts(state.receipts);
            final groupedReceipts = _groupReceiptsByYearMonth(sortedReceipts);

            return CustomScrollView(
              slivers: [
                // 월별 요약 카드
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
                          ...state.receipts.groupByCurrency().entries.map(
                                (entry) =>
                                    _buildCurrencyTotalRow(context, entry),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 연도/월별 그룹화된 영수증 목록
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final yearMonth = groupedReceipts.keys.elementAt(index);
                      final receipts = groupedReceipts[yearMonth]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0 || _isNewYear(index, groupedReceipts))
                            _buildYearDivider(yearMonth),
                          _buildMonthDivider(context, yearMonth, receipts),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: receipts.length,
                              itemBuilder: (context, idx) {
                                final receipt = receipts[idx];
                                return ReceiptGridItem(
                                  receipt: receipt,
                                  onTap: () {
                                    debugPrint('영수증 상세 페이지로 이동 시도');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ReceiptDetailsPage(
                                                receiptId: receipt.id),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                    childCount: groupedReceipts.length,
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: ScanReceiptFab(
        onImageSelected: (String imagePath) async {
          debugPrint('ReceiptPage - onImageSelected 시작: $imagePath');
          try {
            if (mounted) {
              debugPrint('ReceiptPreviewPage로 이동 시도');
              final shouldProceed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ReceiptPreviewPage(imagePath: imagePath),
                ),
              );

              debugPrint('ReceiptPreviewPage 결과: $shouldProceed');

              if (shouldProceed == true && mounted) {
                debugPrint('ReceiptScanResultPage로 이동 시도');
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReceiptScanResultPage(imagePath: imagePath),
                    fullscreenDialog: true,
                  ),
                );
                debugPrint('ReceiptScanResultPage 완료');

                if (mounted) {
                  debugPrint('영수증 목록 새로고침');
                  _loadReceipts();
                }
              } else {
                debugPrint('영수증 스캔 취소됨');
              }
            }
          } catch (e) {
            debugPrint('영수증 처리 중 오류 발생: $e');
          }
        },
      ),
    );
  }

  // 정렬 관련 메서드
  List<Receipt> _sortReceipts(List<Receipt> receipts) {
    final List<Receipt> sorted = List.from(receipts);

    switch (_sortOption) {
      case SortOption.date:
        sorted.sort((a, b) =>
            _ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date));
        break;
      case SortOption.amount:
        sorted.sort((a, b) {
          if (a.currency == b.currency) {
            return _ascending
                ? a.totalAmount.compareTo(b.totalAmount)
                : b.totalAmount.compareTo(a.totalAmount);
          }
          return a.currency.compareTo(b.currency);
        });
        break;
      case SortOption.store:
        sorted.sort((a, b) => _ascending
            ? a.merchantName.compareTo(b.merchantName)
            : b.merchantName.compareTo(a.merchantName));
        break;
    }

    return sorted;
  }

  PopupMenuItem<SortOption> _buildSortMenuItem(
      SortOption option, IconData icon) {
    return PopupMenuItem(
      value: option,
      child: Row(
        children: [
          Icon(
            icon,
            color:
                _sortOption == option ? Theme.of(context).primaryColor : null,
          ),
          const SizedBox(width: 8),
          Text(_getLocalizedLabel(context, 'sort_by_${option.name}')),
          if (_sortOption == option)
            Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
        ],
      ),
    );
  }

  void _handleSortChange(SortOption option) {
    setState(() {
      if (_sortOption == option) {
        _ascending = !_ascending;
      } else {
        _sortOption = option;
        _ascending = false;
      }
      _saveSortPreferences(); // 변경사항 저장
    });
  }

  // 빈 상태 위젯
  Widget _buildEmptyState(BuildContext context) {
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

  // 네비게이션
  void _navigateToReceiptDetails(BuildContext context, Receipt receipt) {
    debugPrint('영수증 상세 페이지로 이동 시도');
    try {
      context.push('/receipt/details', extra: receipt);
    } catch (e) {
      debugPrint('라우팅 에러: $e');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptDetailsPage(receiptId: receipt.id),
        ),
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
      AppLanguage.japanese: 'レシートをスャン',
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
      AppLanguage.japanese: '保存さたレシートがありません',
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
        AppLanguage.japanese: '今月のレシト',
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

  String _getLocalizedAmount(
      BuildContext context, double amount, String currency) {
    final formattedAmount = _numberFormat.format(amount);
    final currencySymbols = {
      'KRW': '원',
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
    };

    final symbol = currencySymbols[currency] ?? currencySymbols['KRW']!;

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

  Widget _buildYearDivider(DateTime yearMonth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        children: [
          Text(
            yearMonth.year.toString(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey[300],
              thickness: 1,
              indent: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDivider(
      BuildContext context, DateTime yearMonth, List<Receipt> receipts) {
    final currencyGroups = _groupByCurrency(receipts);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateFormat('MMMM',
                        context.read<AppLanguageBloc>().state.language.code)
                    .format(yearMonth),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                  indent: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: currencyGroups.entries.map((entry) {
              return Chip(
                label: Text(
                  _getLocalizedAmount(context, entry.value, entry.key),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<Receipt>> _groupReceiptsByYearMonth(
      List<Receipt> receipts) {
    final grouped = <DateTime, List<Receipt>>{};

    for (var receipt in receipts) {
      final yearMonth = DateTime(receipt.date.year, receipt.date.month);
      grouped.update(
        yearMonth,
        (list) => list..add(receipt),
        ifAbsent: () => [receipt],
      );
    }

    return Map.fromEntries(grouped.entries.toList()
      ..sort((a, b) =>
          _ascending ? a.key.compareTo(b.key) : b.key.compareTo(a.key)));
  }

  Map<String, double> _groupByCurrency(List<Receipt> receipts) {
    final currencyTotals = <String, double>{};

    for (var receipt in receipts) {
      currencyTotals.update(
        receipt.currency,
        (total) => total + receipt.totalAmount,
        ifAbsent: () => receipt.totalAmount,
      );
    }

    return currencyTotals;
  }

  bool _isNewYear(int index, Map<DateTime, List<Receipt>> groupedReceipts) {
    if (index == 0) return true;
    final currentYear = groupedReceipts.keys.elementAt(index).year;
    final previousYear = groupedReceipts.keys.elementAt(index - 1).year;
    return currentYear != previousYear;
  }

  Widget _buildCurrencyTotalRow(
      BuildContext context, MapEntry<String, double> entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_getLocalizedLabel(context, 'total_amount')),
          Text(
            _getLocalizedAmount(context, entry.value, entry.key),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  // AppBar 수정
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(_getLocalizedTitle(context)),
      actions: [
        PopupMenuButton<SortOption>(
          icon: Stack(
            children: [
              const Icon(Icons.sort),
              if (_sortOption != SortOption.date) // 기본값이 아닐 때만 표시
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          onSelected: _handleSortChange,
          itemBuilder: (context) => [
            _buildSortMenuItem(SortOption.date, Icons.calendar_today),
            _buildSortMenuItem(SortOption.amount, Icons.attach_money),
            _buildSortMenuItem(SortOption.store, Icons.store),
          ],
        ),
      ],
    );
  }
}

// ReceiptListItem 위젯 추가 (클래스 외부에)
class ReceiptListItem extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onTap;

  const ReceiptListItem({
    Key? key,
    required this.receipt,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(receipt.merchantName),
      subtitle: Text(DateFormat('yyyy-MM-dd').format(receipt.date)),
      trailing: Text('${receipt.currency} ${receipt.totalAmount}'),
      onTap: onTap,
    );
  }
}

// 정렬 옵션 enum 추가
enum SortOption {
  date,
  amount,
  store,
}
