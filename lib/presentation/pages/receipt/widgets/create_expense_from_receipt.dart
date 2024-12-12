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
import 'package:go_router/go_router.dart';

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
  late String _selectedCategory;
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = 'food';
    _descriptionController.text = widget.receipt.merchantName;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      child: SingleChildScrollView(
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
              _getLocalizedLabel(context, 'create_expense'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 24),

            // 내용 입력
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: _getLocalizedLabel(context, 'description'),
                prefixIcon: const Icon(Icons.description_outlined,
                    color: Color(0xFF2C3E50)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF2C3E50), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 카테고리 선택
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: _getLocalizedLabel(context, 'category'),
                prefixIcon: const Icon(Icons.category_outlined,
                    color: Color(0xFF2C3E50)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _getLocalizedCategories(context),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // 버튼
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(_getLocalizedLabel(context, 'cancel')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createExpense,
                    child: Text(_getLocalizedLabel(context, 'create')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getLocalizedCategories(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    return CategoryConstants.categories.entries.map((entry) {
      return DropdownMenuItem<String>(
        value: entry.key,
        child: Text(entry.value[language] ?? entry.value[AppLanguage.korean]!),
      );
    }).toList();
  }

  void _createExpense() {
    final expenseId = const Uuid().v4();

    // 이미 expenseId가 있는 경우 중복 생성 방지
    if (widget.receipt.expenseId != null) {
      Navigator.pop(context);
      return;
    }

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

    // 한 번만 이벤트 발생
    context.read<ExpenseBloc>().add(AddExpense(expenseModel: expense));

    // 영수증 업데이트도 한 번만 발생
    context.read<ReceiptBloc>().add(UpdateReceipt(
          widget.receipt.copyWith(expenseId: expenseId),
        ));

    // 스낵바 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_getLocalizedLabel(context, 'expense_created'))),
    );

    // 현재 페이지들을 모두 닫고 영수증 페이지로 이동
    Navigator.of(context).popUntil((route) => route.isFirst);
    context.go('/receipts');
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
        AppLanguage.korean: '지출 내역이 생성되었습다.',
        AppLanguage.japanese: '支出が作成されました。',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }
}
