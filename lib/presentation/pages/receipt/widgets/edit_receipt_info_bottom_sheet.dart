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

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                _getLocalizedLabel(context, 'edit_receipt'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    TextFormField(
                      controller: _merchantNameController,
                      decoration: InputDecoration(
                        labelText: _getLocalizedLabel(context, 'store_name'),
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? _getLocalizedLabel(context, 'store_name_required')
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _getLocalizedLabel(context, 'items'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: item.name,
                                  decoration: InputDecoration(
                                    labelText: _getLocalizedLabel(
                                        context, 'item_name'),
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
                              Expanded(
                                child: TextFormField(
                                  initialValue: item.price.toString(),
                                  decoration: InputDecoration(
                                    labelText: _getLocalizedLabel(
                                        context, 'unit_price'),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
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
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 60,
                                child: TextFormField(
                                  initialValue: item.quantity.toString(),
                                  decoration: InputDecoration(
                                    labelText:
                                        _getLocalizedLabel(context, 'quantity'),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
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
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _items.removeAt(index);
                                  });
                                  _updateTotalAmount();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    OutlinedButton.icon(
                      onPressed: _addNewItem,
                      icon: const Icon(Icons.add),
                      label: Text(_getLocalizedLabel(context, 'add_item')),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _totalAmountController,
                      decoration: InputDecoration(
                        labelText: _getLocalizedLabel(context, 'total'),
                        prefixText: _getCurrencySymbol(context),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          if (newValue.text.isEmpty) return newValue;
                          final number = int.parse(newValue.text);
                          final newString =
                              NumberFormat('#,###').format(number);
                          return TextEditingValue(
                            text: newString,
                            selection: TextSelection.collapsed(
                                offset: newString.length),
                          );
                        }),
                      ],
                      validator: (value) => value?.isEmpty ?? true
                          ? _getLocalizedLabel(context, 'total_required')
                          : null,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(_getLocalizedLabel(context, 'cancel')),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _updateReceipt,
                      child: Text(_getLocalizedLabel(context, 'save')),
                    ),
                  ],
                ),
              ),
            ],
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

  void _updateReceipt() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedReceipt = widget.receipt.copyWith(
        merchantName: _merchantNameController.text,
        totalAmount:
            double.parse(_totalAmountController.text.replaceAll(',', '')),
        items: _items
            .map((item) => item.copyWith(
                  totalPrice: item.price * item.quantity,
                ))
            .toList(),
      );

      context.read<ReceiptBloc>().add(UpdateReceipt(updatedReceipt));
      Navigator.pop(context);
    }
  }
}
