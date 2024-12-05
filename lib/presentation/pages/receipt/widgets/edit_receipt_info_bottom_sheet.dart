import 'package:finpal/domain/entities/receipt.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_bloc.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';

class EditReceiptInfoBottomSheet extends StatefulWidget {
  final Receipt receipt;

  const EditReceiptInfoBottomSheet({
    super.key,
    required this.receipt,
  });

  @override
  State<EditReceiptInfoBottomSheet> createState() =>
      _EditReceiptInfoBottomSheetState();
}

class _EditReceiptInfoBottomSheetState
    extends State<EditReceiptInfoBottomSheet> {
  late TextEditingController _merchantNameController;
  late TextEditingController _totalAmountController;
  late DateTime _selectedDate;
  late DateTime _originalDate;
  late List<ReceiptItem> _items;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _merchantNameController =
        TextEditingController(text: widget.receipt.merchantName);
    _totalAmountController = TextEditingController(
      text: NumberFormat('#,###').format(widget.receipt.totalAmount),
    );
    _selectedDate = widget.receipt.date;
    _originalDate = widget.receipt.date;
    _items = List.from(widget.receipt.items);
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'edit_receipt': {
        AppLanguage.english: 'Edit Receipt',
        AppLanguage.korean: '영수증 정보 수정',
        AppLanguage.japanese: 'シート情報を編集',
      },
      'store_name': {
        AppLanguage.english: 'Store Name',
        AppLanguage.korean: '가게명',
        AppLanguage.japanese: '店舗名',
      },
      'store_name_required': {
        AppLanguage.english: 'Please enter store name',
        AppLanguage.korean: '가게명을 입력해주세요',
        AppLanguage.japanese: '店舗名を入力してください',
      },
      'items': {
        AppLanguage.english: 'Items',
        AppLanguage.korean: '구매 항목',
        AppLanguage.japanese: '購入項目',
      },
      'item_name': {
        AppLanguage.english: 'Item Name',
        AppLanguage.korean: '품목명',
        AppLanguage.japanese: '品目名',
      },
      'unit_price': {
        AppLanguage.english: 'Unit Price',
        AppLanguage.korean: '단가',
        AppLanguage.japanese: '単価',
      },
      'quantity': {
        AppLanguage.english: 'Quantity',
        AppLanguage.korean: '수량',
        AppLanguage.japanese: '数量',
      },
      'add_item': {
        AppLanguage.english: 'Add Item',
        AppLanguage.korean: '품목 추가',
        AppLanguage.japanese: '品目を追加',
      },
      'total': {
        AppLanguage.english: 'Total',
        AppLanguage.korean: '총액',
        AppLanguage.japanese: '合計',
      },
      'total_required': {
        AppLanguage.english: 'Please enter total amount',
        AppLanguage.korean: '총액을 입력해주세요',
        AppLanguage.japanese: '合計金額を入力してください',
      },
      'cancel': {
        AppLanguage.english: 'Cancel',
        AppLanguage.korean: '취소',
        AppLanguage.japanese: 'キャンセル',
      },
      'save': {
        AppLanguage.english: 'Save',
        AppLanguage.korean: '저장',
        AppLanguage.japanese: '保存',
      },
      'receipt_date': {
        AppLanguage.english: 'Receipt Date',
        AppLanguage.korean: '영수증 날짜',
        AppLanguage.japanese: 'レシート日付',
      },
      'original_date': {
        AppLanguage.english: 'Original date',
        AppLanguage.korean: '원본 날짜',
        AppLanguage.japanese: '元の日付',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  String _getCurrencySymbol(BuildContext context) {
    final currency = context.read<AppSettingsBloc>().state.currency;
    final currencySymbols = {
      'KRW': '원 ',
      'JPY': '¥ ',
      'USD': '\$ ',
      'EUR': '€ ',
    };
    return currencySymbols[currency] ?? currencySymbols['KRW']!;
  }

  Widget _buildDateSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getLocalizedLabel(context, 'receipt_date'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showDateTimePicker(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (_selectedDate != _originalDate)
                  Tooltip(
                    message: _getLocalizedLabel(context, 'original_date'),
                    child: Text(
                      '(${DateFormat('yyyy-MM-dd HH:mm').format(_originalDate)})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showDateTimePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        child: SingleChildScrollView(
          controller: controller,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 드래그 핸들
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // 제목
                Text(
                  _getLocalizedLabel(context, 'edit_receipt'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 24),

                // 가게명 입력
                TextFormField(
                  controller: _merchantNameController,
                  decoration: InputDecoration(
                    labelText: _getLocalizedLabel(context, 'store_name'),
                    prefixIcon:
                        const Icon(Icons.store, color: Color(0xFF2C3E50)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF2C3E50), width: 2),
                    ),
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? _getLocalizedLabel(context, 'store_name_required')
                      : null,
                ),
                const SizedBox(height: 16),

                // 날짜 선택
                InkWell(
                  onTap: () => _showDateTimePicker(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: _getLocalizedLabel(context, 'date'),
                      prefixIcon: const Icon(Icons.calendar_today,
                          color: Color(0xFF2C3E50)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('yyyy-MM-dd HH:mm')
                            .format(_selectedDate)),
                        const Icon(Icons.arrow_drop_down,
                            color: Color(0xFF2C3E50)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 총액 입력
                TextFormField(
                  controller: _totalAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _getLocalizedLabel(context, 'total'),
                    prefixIcon: const Icon(Icons.attach_money,
                        color: Color(0xFF2C3E50)),
                    suffixText: _getCurrencySymbol(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF2C3E50), width: 2),
                    ),
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? _getLocalizedLabel(context, 'total_required')
                      : null,
                ),
                const SizedBox(height: 24),

                // 항목 섹션
                Text(
                  _getLocalizedLabel(context, 'items'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.name,
                                    decoration: InputDecoration(
                                      labelText: _getLocalizedLabel(
                                          context, 'item_name'),
                                      prefixIcon: const Icon(
                                          Icons.shopping_bag_outlined,
                                          color: Color(0xFF2C3E50)),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _items[index] =
                                            item.copyWith(name: value);
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _items.removeAt(index);
                                    });
                                    _updateTotalAmount();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.price.toString(),
                                    decoration: InputDecoration(
                                      labelText: _getLocalizedLabel(
                                          context, 'unit_price'),
                                      prefixIcon: const Icon(Icons.attach_money,
                                          color: Color(0xFF2C3E50)),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        _items[index] = item.copyWith(
                                          price: double.tryParse(value) ?? 0,
                                        );
                                      });
                                      _updateTotalAmount();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 100,
                                  child: TextFormField(
                                    initialValue: item.quantity.toString(),
                                    decoration: InputDecoration(
                                      labelText: _getLocalizedLabel(
                                          context, 'quantity'),
                                      prefixIcon: const Icon(Icons.numbers,
                                          color: Color(0xFF2C3E50)),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        _items[index] = item.copyWith(
                                          quantity: int.tryParse(value) ?? 1,
                                        );
                                      });
                                      _updateTotalAmount();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // 항목 추가 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _addNewItem,
                      icon: const Icon(Icons.add, color: Color(0xFF2C3E50)),
                      label: Text(
                        _getLocalizedLabel(context, 'add_item'),
                        style: const TextStyle(color: Color(0xFF2C3E50)),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF2C3E50)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

                // 저장 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveReceipt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _getLocalizedLabel(context, 'save'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addNewItem() {
    setState(() {
      _items.add(ReceiptItem(
        name: '',
        price: 0,
        quantity: 1,
        totalPrice: 0,
        currency: widget.receipt.currency,
      ));
    });
  }

  void _updateTotalAmount() {
    final total = _items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    _totalAmountController.text = NumberFormat('#,###').format(total);
  }

  void _saveReceipt() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedReceipt = widget.receipt.copyWith(
        merchantName: _merchantNameController.text,
        date: _selectedDate,
        totalAmount: double.parse(
          _totalAmountController.text.replaceAll(',', ''),
        ),
        items: _items,
      );

      context.read<ReceiptBloc>().add(UpdateReceipt(updatedReceipt));
      Navigator.pop(context);
    }
  }
}
