// lib/presentation/pages/expense/widgets/add_expense_fab.dart
import 'package:finpal/data/models/expense_model.dart';
import 'package:finpal/data/models/user_model.dart';
import 'package:finpal/domain/entities/expense.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/expense/expense_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../bloc/expense/expense_bloc.dart';
import '../../../bloc/auth/auth_bloc.dart';
import 'package:intl/intl.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class AddExpenseFab extends StatelessWidget {
  const AddExpenseFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddExpenseDialog(context),
      tooltip: _getLocalizedTooltip(context),
      child: const Icon(Icons.add),
    );
  }

  String _getLocalizedTooltip(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> tooltips = {
      AppLanguage.english: 'Add Expense',
      AppLanguage.korean: '지출 추가',
      AppLanguage.japanese: '支出追加',
    };
    return tooltips[language] ?? tooltips[AppLanguage.korean]!;
  }

  void _showAddExpenseDialog(BuildContext context) {
    // 지출 추가 다이얼로그 표시
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddExpenseBottomSheet(),
    );
  }
}

// lib/presentation/pages/expense/widgets/add_expense_bottom_sheet.dart
class AddExpenseBottomSheet extends StatefulWidget {
  const AddExpenseBottomSheet({super.key});

  @override
  State<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'food';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedCategory = _getLocalizedDefaultCategory(context);
        });
      }
    });
  }

  String _getLocalizedDefaultCategory(BuildContext context) {
    return 'food';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            Text(
              _getLocalizedTitle(context),
              style: Theme.of(context).textTheme.titleLarge,
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
              items: _getLocalizedCategories(context),
              onChanged: (value) {
                setState(() {
                  _selectedCategory =
                      value ?? _getLocalizedDefaultCategory(context);
                });
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: _getLocalizedLabel(context, 'date'),
                  border: const OutlineInputBorder(),
                ),
                child: Text(_getLocalizedDate(context, _selectedDate)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addExpense,
              child: Text(_getLocalizedLabel(context, 'save')),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _addExpense() {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        final expense = ExpenseModel(
          id: const Uuid().v4(),
          amount: double.parse(_amountController.text.replaceAll(',', '')),
          currency: authState.user.settings?['currency'] ?? 'KRW',
          description: _descriptionController.text,
          category: _selectedCategory,
          userId: authState.user.id,
          date: _selectedDate,
          createdAt: DateTime.now(),
        );

        context.read<ExpenseBloc>().add(AddExpense(expenseModel: expense));

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getLocalizedSuccessMessage(context))),
        );
      }
    }
  }

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Add Expense',
      AppLanguage.korean: '지출 추가',
      AppLanguage.japanese: '支出追加',
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

  List<DropdownMenuItem<String>> _getLocalizedCategories(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> categories = {
      'food': {
        AppLanguage.english: 'Food',
        AppLanguage.korean: '식비',
        AppLanguage.japanese: '食費',
      },
      'transport': {
        AppLanguage.english: 'Transport',
        AppLanguage.korean: '교통',
        AppLanguage.japanese: '交通',
      },
      'shopping': {
        AppLanguage.english: 'Shopping',
        AppLanguage.korean: '쇼핑',
        AppLanguage.japanese: '買物',
      },
      'entertainment': {
        AppLanguage.english: 'Entertainment',
        AppLanguage.korean: '여가',
        AppLanguage.japanese: '娯楽',
      },
      'medical': {
        AppLanguage.english: 'Medical',
        AppLanguage.korean: '의료',
        AppLanguage.japanese: '医療',
      },
      'others': {
        AppLanguage.english: 'Others',
        AppLanguage.korean: '기타',
        AppLanguage.japanese: 'その他',
      },
    };

    return categories.entries
        .map((entry) => DropdownMenuItem(
              value: entry.key,
              child: Text(
                  entry.value[language] ?? entry.value[AppLanguage.korean]!),
            ))
        .toList();
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

  String _getLocalizedCurrency(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> currencies = {
      AppLanguage.english: '\$',
      AppLanguage.korean: '원',
      AppLanguage.japanese: '¥',
    };
    return currencies[language] ?? currencies[AppLanguage.korean]!;
  }

  String _getLocalizedSuccessMessage(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> messages = {
      AppLanguage.english: 'Expense has been added',
      AppLanguage.korean: '지출이 추가되었습니다',
      AppLanguage.japanese: '支出が追加されました',
    };
    return messages[language] ?? messages[AppLanguage.korean]!;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
