import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/core/utils/constants.dart';
import 'package:finpal/data/models/expense_model.dart';
import 'package:finpal/domain/entities/expense.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/expense/expense_bloc.dart';
import 'package:finpal/presentation/bloc/expense/expense_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
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
              _getLocalizedTitle(context),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 24),

            // 금액 입력
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: _getLocalizedLabel(context, 'amount'),
                prefixIcon:
                    const Icon(Icons.attach_money, color: Color(0xFF2C3E50)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2C3E50)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF2C3E50), width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // 설명 입력
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF2C3E50), width: 2),
                ),
              ),
              items: _getLocalizedCategories(context),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),

            // 날짜 선택
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: _getLocalizedLabel(context, 'date'),
                  prefixIcon: const Icon(Icons.calendar_today_outlined,
                      color: Color(0xFF2C3E50)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_getLocalizedDate(context, _selectedDate)),
              ),
            ),
            const SizedBox(height: 24),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _addExpense(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _getLocalizedLabel(context, 'save'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    const Map<AppLanguage, String> labels = {
      AppLanguage.english: 'Amount',
      AppLanguage.korean: '금액',
      AppLanguage.japanese: '金額',
    };
    return labels[language] ?? labels[AppLanguage.korean]!;
  }

  List<DropdownMenuItem<String>> _getLocalizedCategories(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    return CategoryConstants.categories.entries.map((entry) {
      return DropdownMenuItem<String>(
        value: entry.key,
        child:
            Text(CategoryConstants.getLocalizedCategory(entry.key, language)),
      );
    }).toList();
  }

  String _getLocalizedDate(BuildContext context, DateTime date) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> formats = {
      AppLanguage.english: 'MM/dd/yyyy',
      AppLanguage.korean: 'yyyy년 MM월 dd일',
      AppLanguage.japanese: 'yyyy/MM/dd',
    };
    return DateFormat(formats[language]!).format(date);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() => _selectedDate = pickedDate!);
    }
  }

  void _addExpense(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final expenseModel = ExpenseModel(
        id: const Uuid().v4(),
        userId: authState.user.id,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        category: _selectedCategory,
        date: _selectedDate,
        currency: context.read<AppSettingsBloc>().state.currency,
        createdAt: DateTime.now(),
      );
      context.read<ExpenseBloc>().add(AddExpense(expenseModel: expenseModel));
      Navigator.of(context).pop();
    }
  }
}
