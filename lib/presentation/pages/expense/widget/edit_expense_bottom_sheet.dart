import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/expense.dart';
import '../../../bloc/expense/expense_bloc.dart';
import '../../../bloc/expense/expense_event.dart';

class EditExpenseBottomSheet extends StatefulWidget {
  final Expense expense;

  const EditExpenseBottomSheet({
    super.key,
    required this.expense,
  });

  @override
  State<EditExpenseBottomSheet> createState() => _EditExpenseBottomSheetState();
}

class _EditExpenseBottomSheetState extends State<EditExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late String _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.expense.description);
    _amountController = TextEditingController(
      text: NumberFormat('#,###').format(widget.expense.amount),
    );
    _selectedCategory = widget.expense.category;
    _selectedDate = widget.expense.date;
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
                  _getLocalizedTitle(context),
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
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: _getLocalizedLabel(context, 'description'),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return _getLocalizedError(context, 'description_required');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: _getLocalizedLabel(context, 'amount'),
                border: const OutlineInputBorder(),
                suffix: Text(_getLocalizedCurrency(context)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return _getLocalizedError(context, 'amount_required');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: _getLocalizedLabel(context, 'category'),
                border: const OutlineInputBorder(),
              ),
              items: _getLocalizedCategories(context)
                  .map((category) => DropdownMenuItem(
                        value: category['value'],
                        child: Text(category['label']!),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_getLocalizedLabel(context, 'date')),
              subtitle: Text(_getLocalizedDate(context, _selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
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

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Edit Expense',
      AppLanguage.korean: '지출 수정',
      AppLanguage.japanese: '支出編集',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'description': {
        AppLanguage.english: 'Description',
        AppLanguage.korean: '내용',
        AppLanguage.japanese: '内容',
      },
      'amount': {
        AppLanguage.english: 'Amount',
        AppLanguage.korean: '금액',
        AppLanguage.japanese: '金額',
      },
      'category': {
        AppLanguage.english: 'Category',
        AppLanguage.korean: '카테고리',
        AppLanguage.japanese: 'カテゴリー',
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

  String _getLocalizedError(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> errors = {
      'description_required': {
        AppLanguage.english: 'Please enter a description',
        AppLanguage.korean: '내용을 입력해주세요',
        AppLanguage.japanese: '内容を入力してください',
      },
      'amount_required': {
        AppLanguage.english: 'Please enter an amount',
        AppLanguage.korean: '금액을 입력해주세요',
        AppLanguage.japanese: '金額を入力してください',
      },
    };
    return errors[key]?[language] ?? errors[key]?[AppLanguage.korean] ?? key;
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

  List<Map<String, String>> _getLocalizedCategories(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    return CategoryConstants.categories.entries.map((entry) {
      return {
        'value': entry.key,
        'label': CategoryConstants.getLocalizedCategory(entry.key, language),
      };
    }).toList();
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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedExpense = Expense(
        id: widget.expense.id,
        amount: double.parse(_amountController.text.replaceAll(',', '')),
        currency: widget.expense.currency,
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        date: _selectedDate,
        userId: widget.expense.userId,
        receiptUrl: widget.expense.receiptUrl,
        receiptId: widget.expense.receiptId,
        isShared: widget.expense.isShared,
        sharedWith: widget.expense.sharedWith,
        splitAmounts: widget.expense.splitAmounts,
      );

      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);

      context.read<ExpenseBloc>()
        ..add(UpdateExpense(updatedExpense))
        ..add(LoadExpensesByDateRange(
          userId: updatedExpense.userId,
          startDate: startDate,
          endDate: endDate,
        ));

      Navigator.pop(context);
    }
  }
}
