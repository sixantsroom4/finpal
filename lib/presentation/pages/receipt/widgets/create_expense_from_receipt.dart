import 'package:finpal/data/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/entities/receipt.dart';
import '../../../../domain/entities/expense.dart';
import '../../../bloc/expense/expense_bloc.dart';
import '../../../bloc/expense/expense_event.dart';
import '../../../bloc/receipt/receipt_bloc.dart';
import '../../../bloc/receipt/receipt_event.dart';
import '../../../../core/utils/constants.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class CreateExpenseFromReceipt extends StatefulWidget {
  final Receipt receipt;

  const CreateExpenseFromReceipt({
    super.key,
    required this.receipt,
  });

  @override
  State<CreateExpenseFromReceipt> createState() =>
      _CreateExpenseFromReceiptState();
}

class _CreateExpenseFromReceiptState extends State<CreateExpenseFromReceipt> {
  String _selectedCategory = CategoryConstants.food;
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.receipt.merchantName;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _getLocalizedLabel(context, 'create_expense'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'category',
              border: OutlineInputBorder(),
            ),
            items: CategoryConstants.getAll().map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value ?? CategoryConstants.food;
              });
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _createExpense,
                  child: const Text('create'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _createExpense() {
    final expenseId = const Uuid().v4();

    final expense = ExpenseModel(
      id: expenseId,
      amount: widget.receipt.totalAmount,
      currency: widget.receipt.currency,
      description: _descriptionController.text,
      category: _selectedCategory,
      userId: widget.receipt.userId,
      receiptUrl: widget.receipt.imageUrl,
      receiptId: widget.receipt.id,
      date: widget.receipt.date,
      createdAt: DateTime.now(),
    );

    context.read<ExpenseBloc>().add(AddExpense(expenseModel: expense));

    // 영수증 업데이트 이벤트 발생 (expenseId 연결)
    context.read<ReceiptBloc>().add(UpdateReceipt(
          widget.receipt.copyWith(expenseId: expenseId),
        ));

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('expense_created')),
    );
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'create_expense': {
        AppLanguage.english: 'Create Expense',
        AppLanguage.korean: '지출 내역 생성',
        AppLanguage.japanese: '支出を作成',
      },
      'description': {
        AppLanguage.english: 'Description',
        AppLanguage.korean: '내용',
        AppLanguage.japanese: '内容',
      },
      'category': {
        AppLanguage.english: 'Category',
        AppLanguage.korean: '카테고리',
        AppLanguage.japanese: 'カテゴリー',
      },
      'cancel': {
        AppLanguage.english: 'Cancel',
        AppLanguage.korean: '취소',
        AppLanguage.japanese: 'キャンセル',
      },
      'create': {
        AppLanguage.english: 'Create',
        AppLanguage.korean: '생성',
        AppLanguage.japanese: '作成',
      },
      'expense_created': {
        AppLanguage.english: 'Expense has been created.',
        AppLanguage.korean: '지출 내역이 생성되었습니다.',
        AppLanguage.japanese: '支出が作成されました。',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }
}
