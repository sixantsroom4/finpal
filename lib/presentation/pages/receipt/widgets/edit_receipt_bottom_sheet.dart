import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/receipt.dart';
import '../../../bloc/receipt/receipt_bloc.dart';
import '../../../bloc/receipt/receipt_event.dart';
import '../../../bloc/receipt/receipt_state.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class EditReceiptBottomSheet extends StatefulWidget {
  final Receipt receipt;

  const EditReceiptBottomSheet({
    super.key,
    required this.receipt,
  });

  @override
  State<EditReceiptBottomSheet> createState() => _EditReceiptBottomSheetState();
}

class _EditReceiptBottomSheetState extends State<EditReceiptBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _merchantNameController;
  late final TextEditingController _totalAmountController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _merchantNameController =
        TextEditingController(text: widget.receipt.merchantName);
    _totalAmountController = TextEditingController(
      text: NumberFormat('#,###').format(widget.receipt.totalAmount),
    );
    _selectedDate = widget.receipt.date;
  }

  @override
  void dispose() {
    _merchantNameController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'edit_receipt': {
        AppLanguage.english: 'Edit Receipt',
        AppLanguage.korean: '영수증 수정',
        AppLanguage.japanese: 'レシートを編集',
      },
      'store_name': {
        AppLanguage.english: 'Store Name',
        AppLanguage.korean: '상점명',
        AppLanguage.japanese: '店舗名',
      },
      'store_name_required': {
        AppLanguage.english: 'Please enter store name',
        AppLanguage.korean: '상점명을 입력해주세요',
        AppLanguage.japanese: '店舗名を入力してください',
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
      'date': {
        AppLanguage.english: 'Date',
        AppLanguage.korean: '날짜',
        AppLanguage.japanese: '日付',
      },
      'save': {
        AppLanguage.english: 'Save',
        AppLanguage.korean: '저장',
        AppLanguage.japanese: '保存',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  String _getLocalizedCurrency(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> currencies = {
      AppLanguage.english: '\$',
      AppLanguage.korean: '원',
      AppLanguage.japanese: '¥',
    };
    return currencies[language] ?? currencies[AppLanguage.korean]!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getLocalizedLabel(context, 'edit_receipt'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _merchantNameController,
              decoration: InputDecoration(
                labelText: _getLocalizedLabel(context, 'store_name'),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return _getLocalizedLabel(context, 'store_name_required');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalAmountController,
              decoration: InputDecoration(
                labelText: _getLocalizedLabel(context, 'total'),
                border: OutlineInputBorder(),
                suffix: Text(_getLocalizedCurrency(context)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return _getLocalizedLabel(context, 'total_required');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_getLocalizedLabel(context, 'date')),
              subtitle: Text(_selectedDate.toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_getLocalizedLabel(context, 'save')),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedReceipt = Receipt(
        id: widget.receipt.id,
        imageUrl: widget.receipt.imageUrl,
        date: _selectedDate,
        merchantName: _merchantNameController.text.trim(),
        totalAmount:
            double.parse(_totalAmountController.text.replaceAll(',', '')),
        items: widget.receipt.items,
        userId: widget.receipt.userId,
        expenseId: widget.receipt.expenseId,
      );

      context.read<ReceiptBloc>()
        ..add(UpdateReceipt(updatedReceipt))
        ..add(LoadReceipts(updatedReceipt.userId));
      Navigator.pop(context);
    }
  }
}
