// lib/presentation/pages/receipt/receipt_page.dart
import 'package:finpal/core/constants/app_strings.dart';
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
import 'widgets/empty_receipt_view.dart';

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

  // 선택된 영수증들을 저장할 Set 추가
  final Set<String> _selectedReceipts = {};
  // 선택 모드 상태 추가
  bool _isSelectionMode = false;

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
      body: BlocConsumer<ReceiptBloc, ReceiptState>(
        listener: (context, state) {
          if (state is ReceiptError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is ReceiptOperationSuccess) {
            final language = context.read<AppLanguageBloc>().state.language;
            final message = AppStrings.labels[state.message]?[language] ??
                AppStrings.labels[state.message]?[AppLanguage.korean] ??
                state.message;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        },
        builder: (context, state) {
          // 초기 상태나 데이터가 없을 때는 EmptyReceiptView 표시
          if (state is ReceiptInitial ||
              (state is ReceiptLoaded && state.receipts.isEmpty)) {
            return const EmptyReceiptView();
          }

          // 실제 로딩 중일 때만 로딩 인디케이터 표시
          if (state is ReceiptLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReceiptLoaded) {
            final sortedReceipts = _sortReceipts(state.receipts);
            final groupedReceipts = _groupReceiptsByYearMonth(sortedReceipts);

            return CustomScrollView(
              slivers: [
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
                                return _buildReceiptItem(receipt);
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

          // 에러 상태 처리
          if (state is ReceiptError) {
            return Center(
              child: Text(state.message),
            );
          }

          return const EmptyReceiptView();
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  _sortOption == option ? const Color(0xFF2C3E50) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              _getLocalizedLabel(context, 'sort_by_${option.name}'),
              style: TextStyle(
                color: _sortOption == option
                    ? const Color(0xFF2C3E50)
                    : Colors.grey[600],
                fontWeight:
                    _sortOption == option ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            if (_sortOption == option)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: const Color(0xFF2C3E50),
                  size: 16,
                ),
              ),
          ],
        ),
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
      context.go('/receipts/${receipt.id}');
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
      AppLanguage.japanese: '保存さたレシートがあません',
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
      'delete_selected_receipts': {
        AppLanguage.english: 'Delete Selected Receipts',
        AppLanguage.korean: '선택한 영수증 삭제',
        AppLanguage.japanese: '選択したレシートを削除',
      },
      'delete_selected_confirm': {
        AppLanguage.english:
            'Are you sure you want to delete the selected receipts?\nThis action cannot be undone.',
        AppLanguage.korean: '선택한 영수증을 삭제하시겠습니까?\n삭제된 영수증은 복구할 수 없습니다.',
        AppLanguage.japanese: '選択したレシートを削除してもよろしいですか？\n削除されたレシートは復元できません。',
      },
      'cancel': {
        AppLanguage.english: 'Cancel',
        AppLanguage.korean: '취소',
        AppLanguage.japanese: 'キャンセル',
      },
      'delete': {
        AppLanguage.english: 'Delete',
        AppLanguage.korean: '삭제',
        AppLanguage.japanese: '削除',
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
    if (_isSelectionMode) {
      return AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isSelectionMode = false;
              _selectedReceipts.clear();
            });
          },
        ),
        title: Text(
          _getLocalizedSelectedCount(context, _selectedReceipts.length),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _selectedReceipts.isEmpty
                ? null
                : () => _deleteSelected(context),
          ),
        ],
      );
    }

    return AppBar(
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
      actions: [
        // 정렬 버튼
        PopupMenuButton<SortOption>(
          icon: Stack(
            children: [
              const Icon(
                Icons.sort,
                color: Colors.white,
                size: 24,
              ),
              if (_sortOption != SortOption.date) // 기본값이 아닐 때만 표시
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          elevation: 4,
          offset: const Offset(0, 40),
        ),
      ],
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
    );
  }

  // 영수증 그리드 아이템 수정
  Widget _buildReceiptItem(Receipt receipt) {
    return InkWell(
      onLongPress: () {
        setState(() {
          _isSelectionMode = true;
          _selectedReceipts.add(receipt.id);
        });
      },
      onTap: () {
        if (_isSelectionMode) {
          setState(() {
            if (_selectedReceipts.contains(receipt.id)) {
              _selectedReceipts.remove(receipt.id);
              if (_selectedReceipts.isEmpty) {
                _isSelectionMode = false;
              }
            } else {
              _selectedReceipts.add(receipt.id);
            }
          });
        } else {
          _navigateToReceiptDetails(context, receipt);
        }
      },
      child: Stack(
        children: [
          ReceiptGridItem(receipt: receipt),
          if (_isSelectionMode)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedReceipts.contains(receipt.id)
                      ? Colors.blue
                      : Colors.grey.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    _selectedReceipts.contains(receipt.id)
                        ? Icons.check
                        : Icons.circle_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 선택된 영수증 삭제
  void _deleteSelected(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedLabel(context, 'delete_selected_receipts')),
        content: Text(_getLocalizedLabel(context, 'delete_selected_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getLocalizedLabel(context, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              for (var id in _selectedReceipts) {
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  context
                      .read<ReceiptBloc>()
                      .add(DeleteReceipt(id, authState.user.id));
                }
              }
              setState(() {
                _isSelectionMode = false;
                _selectedReceipts.clear();
              });
            },
            child: Text(
              _getLocalizedLabel(context, 'delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // 라벨 추가
  String _getLocalizedSelectedCount(BuildContext context, int count) {
    final language = context.read<AppLanguageBloc>().state.language;
    switch (language) {
      case AppLanguage.english:
        return '$count selected';
      case AppLanguage.japanese:
        return '$count件選択中';
      case AppLanguage.korean:
      default:
        return '$count개 선택됨';
    }
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
