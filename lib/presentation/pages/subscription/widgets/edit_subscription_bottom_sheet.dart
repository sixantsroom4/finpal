// lib/presentation/pages/subscription/widgets/edit_subscription_bottom_sheet.dart
import 'package:finpal/core/utils/expense_category_constants.dart';
import 'package:finpal/presentation/bloc/subscription/subscription_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/subscription.dart';
import '../../../bloc/subscription/subscription_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/core/utils/subscription_category_constants.dart';
import 'package:finpal/core/utils/subscription_category_constants.dart';

class EditSubscriptionBottomSheet extends StatefulWidget {
  final Subscription subscription;

  const EditSubscriptionBottomSheet({
    super.key,
    required this.subscription,
  });

  @override
  State<EditSubscriptionBottomSheet> createState() =>
      _EditSubscriptionBottomSheetState();
}

class _EditSubscriptionBottomSheetState
    extends State<EditSubscriptionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late String _selectedCategory;
  late String _selectedBillingCycle;
  late int _selectedBillingDay;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subscription.name);
    _amountController = TextEditingController(
      text: widget.subscription.amount.toString(),
    );
    _selectedCategory = widget.subscription.category.toLowerCase();
    _selectedBillingCycle = widget.subscription.billingCycle;
    _selectedBillingDay = widget.subscription.billingDay;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'edit_subscription': {
        AppLanguage.english: 'Edit Subscription',
        AppLanguage.korean: '구독 수정',
        AppLanguage.japanese: 'サブスク編集',
      },
      'service_name': {
        AppLanguage.english: 'Service Name',
        AppLanguage.korean: '서비스명',
        AppLanguage.japanese: 'サービス名',
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
      'billing_cycle': {
        AppLanguage.english: 'Billing Cycle',
        AppLanguage.korean: '결제 주기',
        AppLanguage.japanese: '決済周期',
      },
      'billing_day': {
        AppLanguage.english: 'Billing Day',
        AppLanguage.korean: '결제일',
        AppLanguage.japanese: '決済日',
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
      'service_name_required': {
        AppLanguage.english: 'Please enter service name',
        AppLanguage.korean: '서비스명을 입력해주세요',
        AppLanguage.japanese: 'サービス名を入力してください',
      },
      'amount_required': {
        AppLanguage.english: 'Please enter amount',
        AppLanguage.korean: '금액을 입력해주세요',
        AppLanguage.japanese: '金額を入力してください',
      },
    };
    return errors[key]?[language] ?? errors[key]?[AppLanguage.korean] ?? key;
  }

  String _getCurrencySymbol(BuildContext context) {
    final currency = context.read<AppSettingsBloc>().state.currency;
    final currencySymbols = {
      'KRW': '원',
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
    };
    return currencySymbols[currency] ?? currencySymbols['KRW']!;
  }

  String _getLocalizedCategory(BuildContext context, String category) {
    return SubscriptionCategoryConstants.getLocalizedCategory(
        context, category);
  }

  Map<String, String> _getLocalizedBillingCycles(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> cycles = {
      'monthly': {
        AppLanguage.english: 'Monthly',
        AppLanguage.korean: '월간',
        AppLanguage.japanese: '月間',
      },
      'yearly': {
        AppLanguage.english: 'Yearly',
        AppLanguage.korean: '연간',
        AppLanguage.japanese: '年間',
      },
      'weekly': {
        AppLanguage.english: 'Weekly',
        AppLanguage.korean: '주간',
        AppLanguage.japanese: '週間',
      },
    };

    return Map.fromEntries(
      cycles.entries.map(
        (e) =>
            MapEntry(e.key, e.value[language] ?? e.value[AppLanguage.korean]!),
      ),
    );
  }

  Future<void> _selectBillingDay(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
      lastDate: DateTime(DateTime.now().year, DateTime.now().month, 28),
    );

    if (picked != null) {
      setState(() {
        _selectedBillingDay = picked.day;
      });
    }
  }

  String _getLocalizedDay(BuildContext context, int day) {
    final language = context.read<AppLanguageBloc>().state.language;
    switch (language) {
      case AppLanguage.english:
        return 'Day $day';
      case AppLanguage.japanese:
        return '$day日';
      case AppLanguage.korean:
      default:
        return '${day}일';
    }
  }

  List<Map<String, String>> _getLocalizedCategories(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    return SubscriptionCategoryConstants.categories.entries.map((entry) {
      print('Category Key from Constants: ${entry.key}');
      return {
        'value': entry.key.toLowerCase(),
        'label': SubscriptionCategoryConstants.getLocalizedCategory(
            context, entry.key),
      };
    }).toList();
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
                  _getLocalizedLabel(context, 'edit_subscription'),
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
              controller: _nameController,
              decoration: InputDecoration(
                labelText: _getLocalizedLabel(context, 'service_name'),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return _getLocalizedError(context, 'service_name_required');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: _getLocalizedLabel(context, 'amount'),
                border: OutlineInputBorder(),
                suffix: Text(_getCurrencySymbol(context)),
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
                prefixIcon:
                    const Icon(Icons.category, color: Color(0xFF2C3E50)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _getLocalizedCategories(context).map((category) {
                print('DropdownMenuItem Value: ${category['value']}');
                return DropdownMenuItem<String>(
                  value: category['value'],
                  child: Text(category['label']!),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBillingCycle,
              decoration: InputDecoration(
                labelText: _getLocalizedLabel(context, 'billing_cycle'),
                border: OutlineInputBorder(),
              ),
              items: _getLocalizedBillingCycles(context).entries.map((e) {
                return DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBillingCycle = value ?? 'monthly';
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: _getLocalizedLabel(context, 'billing_day'),
                border: OutlineInputBorder(),
              ),
              onTap: () => _selectBillingDay(context),
              controller: TextEditingController(
                text: _getLocalizedDay(context, _selectedBillingDay),
              ),
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
      final updatedSubscription = widget.subscription.copyWith(
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        billingCycle: _selectedBillingCycle,
        billingDay: _selectedBillingDay,
        category: _selectedCategory.toLowerCase(),
      );

      context
          .read<SubscriptionBloc>()
          .add(UpdateSubscription(updatedSubscription));
      Navigator.pop(context);
    }
  }
}
