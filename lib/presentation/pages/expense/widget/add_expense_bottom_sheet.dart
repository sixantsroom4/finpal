import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/core/utils/expense_category_constants.dart';
import 'package:finpal/data/models/expense_model.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/expense/expense_bloc.dart';
import 'package:finpal/presentation/bloc/expense/expense_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
    final appLanguage = context.read<AppLanguageBloc>().state.language;
    final currency = context.read<AppSettingsBloc>().state.currency;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                _getLocalizedTitle(appLanguage),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 금액과 설명을 가로로 배치
                    Row(
                      children: [
                        // 금액 입력
                        Expanded(
                          flex: 2,
                          child: _buildDetailField(
                            context: context,
                            icon: Icons.attach_money,
                            label: _getLocalizedLabel(appLanguage, 'amount'),
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                suffix: Text(currency),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              validator: (value) => value?.isEmpty ?? true
                                  ? _getLocalizedError(
                                      appLanguage, 'amount_required')
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 설명 입력
                        Expanded(
                          flex: 3,
                          child: _buildDetailField(
                            context: context,
                            icon: Icons.description_outlined,
                            label:
                                _getLocalizedLabel(appLanguage, 'description'),
                            child: TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 12),
                              ),
                              validator: (value) => value?.isEmpty ?? true
                                  ? _getLocalizedError(
                                      appLanguage, 'description_required')
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 카테고리와 날짜를 가로로 배치
                    Row(
                      children: [
                        // 카테고리 선택
                        Expanded(
                          flex: 3,
                          child: _buildDetailField(
                            context: context,
                            icon: Icons.category_outlined,
                            label: _getLocalizedLabel(appLanguage, 'category'),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                inputDecorationTheme:
                                    const InputDecorationTheme(
                                  border: InputBorder.none,
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF2C3E50),
                                  size: 20,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 12),
                                ),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF2C3E50),
                                  fontWeight: FontWeight.w500,
                                ),
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                menuMaxHeight: 300,
                                items: _getLocalizedCategories(appLanguage),
                                onChanged: (value) =>
                                    setState(() => _selectedCategory = value!),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 날짜 선택
                        Expanded(
                          flex: 2,
                          child: _buildDetailField(
                            context: context,
                            icon: Icons.calendar_today_outlined,
                            label: _getLocalizedLabel(appLanguage, 'date'),
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  _getLocalizedDate(appLanguage, _selectedDate),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => _addExpense(context),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2C3E50),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(
                            color: Color(0xFF2C3E50),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Text(
                          _getLocalizedLabel(appLanguage, 'save'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
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

  Widget _buildDetailField({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: const Color(0xFF2C3E50),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }

  String _getLocalizedTitle(AppLanguage language) {
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Add Expense',
      AppLanguage.korean: '지출 추가',
      AppLanguage.japanese: '支出追加',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedLabel(AppLanguage language, String key) {
    final Map<String, Map<AppLanguage, String>> labels = {
      'amount': {
        AppLanguage.english: 'Amount',
        AppLanguage.korean: '금액',
        AppLanguage.japanese: '金額',
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

  List<DropdownMenuItem<String>> _getLocalizedCategories(AppLanguage language) {
    return ExpenseCategoryConstants.categories.entries.map((entry) {
      final icon = ExpenseCategoryConstants.categoryIcons[entry.key]!;
      return DropdownMenuItem<String>(
        value: entry.key,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2C3E50)),
            const SizedBox(width: 8),
            Text(
              ExpenseCategoryConstants.getLocalizedCategory(
                  entry.key, language),
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getLocalizedDate(AppLanguage language, DateTime date) {
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
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final expenseModel = ExpenseModel(
        id: const Uuid().v4(),
        userId: authState.user.id,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        description: _descriptionController.text,
        category: _selectedCategory,
        date: _selectedDate,
        currency: context.read<AppSettingsBloc>().state.currency,
        createdAt: DateTime.now(),
      );
      context.read<ExpenseBloc>().add(AddExpense(expenseModel: expenseModel));
      Navigator.pop(context);
    }
  }

  String _getLocalizedError(AppLanguage language, String key) {
    final Map<String, Map<AppLanguage, String>> errors = {
      'amount_required': {
        AppLanguage.english: 'Please enter an amount',
        AppLanguage.korean: '금액을 입력해주세요',
        AppLanguage.japanese: '金額を入力してください',
      },
      'description_required': {
        AppLanguage.english: 'Please enter a description',
        AppLanguage.korean: '내용을 입력해주세요',
        AppLanguage.japanese: '内容を入力してください',
      },
    };
    return errors[key]?[language] ?? errors[key]?[AppLanguage.korean] ?? key;
  }
}
