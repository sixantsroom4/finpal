import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/expense/expense_bloc.dart';
import '../../../bloc/expense/expense_event.dart';
import '../../../bloc/expense/expense_state.dart';
import 'package:intl/intl.dart';

class BudgetSettingsPage extends StatefulWidget {
  const BudgetSettingsPage({super.key});

  @override
  State<BudgetSettingsPage> createState() => _BudgetSettingsPageState();
}

class _BudgetSettingsPageState extends State<BudgetSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  final _numberFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _initializeBudget();
  }

  void _initializeBudget() {
    final state = context.read<ExpenseBloc>().state;
    if (state is ExpenseLoaded) {
      _budgetController.text = _numberFormat.format(state.monthlyBudget);
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getLocalizedTitle(context),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLocalizedLabel(context, 'monthly_budget'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _getLocalizedLabel(context, 'enter_budget'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.attach_money,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      suffix: Text(_getLocalizedCurrency(context)),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return _getLocalizedError(context, 'budget_required');
                      }
                      if (double.tryParse(value!.replaceAll(',', '')) == null) {
                        return _getLocalizedError(context, 'invalid_amount');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _updateBudget,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3E50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
          ),
        ),
      ),
    );
  }

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Monthly Budget Settings',
      AppLanguage.korean: '월 예산 설정',
      AppLanguage.japanese: '月予算設定',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'monthly_budget': {
        AppLanguage.english: 'Monthly Budget',
        AppLanguage.korean: '월 예산',
        AppLanguage.japanese: '月予算',
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
      'budget_required': {
        AppLanguage.english: 'Please enter your budget',
        AppLanguage.korean: '예산을 입력해주세요',
        AppLanguage.japanese: '予算を入力してください',
      },
      'invalid_amount': {
        AppLanguage.english: 'Please enter a valid amount',
        AppLanguage.korean: '올바른 금액을 입력해주세요',
        AppLanguage.japanese: '正しい金額を入力してください',
      },
    };
    return errors[key]?[language] ?? errors[key]?[AppLanguage.korean] ?? key;
  }

  String _getLocalizedCurrency(BuildContext context) {
    final currency = context.read<AppSettingsBloc>().state.currency;
    const Map<String, String> currencySymbols = {
      'KRW': '원',
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
    };
    return currencySymbols[currency] ?? currencySymbols['KRW']!;
  }

  void _updateBudget() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_budgetController.text.replaceAll(',', ''));
      final state = context.read<ExpenseBloc>().state;
      if (state is ExpenseLoaded) {
        context.read<ExpenseBloc>().add(UpdateMonthlyBudget(
              amount: amount,
              userId: state.userId,
            ));

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getLocalizedSuccessMessage(context))),
        );
      }
    }
  }

  String _getLocalizedSuccessMessage(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> messages = {
      AppLanguage.english: 'Monthly budget has been set',
      AppLanguage.korean: '월 예산이 설정되었습니다',
      AppLanguage.japanese: '月予算が設定されました',
    };
    return messages[language] ?? messages[AppLanguage.korean]!;
  }
}
