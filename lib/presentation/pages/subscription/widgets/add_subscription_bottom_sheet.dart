// lib/presentation/pages/subscription/widgets/add_subscription_bottom_sheet.dart
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/subscription/subscription_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/entities/subscription.dart';
import '../../../bloc/subscription/subscription_bloc.dart';
import '../../../bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/data/models/subscription_model.dart';
import 'package:finpal/core/models/category_item.dart';

class AddSubscriptionBottomSheet extends StatefulWidget {
  const AddSubscriptionBottomSheet({super.key});

  @override
  State<AddSubscriptionBottomSheet> createState() =>
      _AddSubscriptionBottomSheetState();
}

class _AddSubscriptionBottomSheetState
    extends State<AddSubscriptionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'OTT';
  String _selectedBillingCycle = 'monthly';
  int _selectedBillingDay = 1;
  String _selectedCurrency = 'KRW';
  DateTime _startDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'add_subscription': {
        AppLanguage.english: 'Add Subscription',
        AppLanguage.korean: '구독 추가',
        AppLanguage.japanese: 'サブスク追加',
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
      'add': {
        AppLanguage.english: 'Add',
        AppLanguage.korean: '추가',
        AppLanguage.japanese: '追加',
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
      'invalid_amount': {
        AppLanguage.english: 'Please enter a valid amount',
        AppLanguage.korean: '올바른 금액을 입력해주세요',
        AppLanguage.japanese: '正しい金額を入力してくだい',
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

  String _getLocalizedBillingCycle(BuildContext context, String cycle) {
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
    return cycles[cycle.toLowerCase()]?[language] ??
        cycles[cycle.toLowerCase()]?[AppLanguage.korean] ??
        cycle;
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
                _getLocalizedLabel(context, 'add_subscription'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 24),

              // 서비스명 입력
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _getLocalizedLabel(context, 'service_name'),
                  prefixIcon:
                      const Icon(Icons.subscriptions, color: Color(0xFF2C3E50)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF2C3E50), width: 2),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true
                    ? _getLocalizedError(context, 'service_name_required')
                    : null,
              ),
              const SizedBox(height: 16),

              // 금액 입력
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _getLocalizedLabel(context, 'amount'),
                  prefixIcon:
                      const Icon(Icons.attach_money, color: Color(0xFF2C3E50)),
                  suffixText: _getCurrencySymbol(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF2C3E50), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return _getLocalizedError(context, 'amount_required');
                  }
                  if (double.tryParse(value!.replaceAll(',', '')) == null) {
                    return _getLocalizedError(context, 'invalid_amount');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 카테고리 선택
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
                items: [
                  'OTT',
                  'MUSIC',
                  'GAME',
                  'FITNESS',
                  'PRODUCTIVITY',
                  'SOFTWARE',
                  'PET_CARE',
                  'BEAUTY',
                  'CAR_SERVICES',
                  'STREAMING',
                  'RENT',
                  'DELIVERY',
                  'PREMIUM',
                  'OTHER',
                ]
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(CategoryItem.getCategoryIcon(category),
                                  size: 20, color: const Color(0xFF2C3E50)),
                              const SizedBox(width: 12),
                              Text(CategoryItem.getLocalizedCategory(
                                  context, category)),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategory = value ?? 'OTT'),
              ),
              const SizedBox(height: 16),

              // 결제 주기 선택
              DropdownButtonFormField<String>(
                value: _selectedBillingCycle,
                decoration: InputDecoration(
                  labelText: _getLocalizedLabel(context, 'billing_cycle'),
                  prefixIcon:
                      const Icon(Icons.repeat, color: Color(0xFF2C3E50)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['monthly', 'yearly', 'weekly']
                    .map((cycle) => DropdownMenuItem(
                          value: cycle,
                          child:
                              Text(_getLocalizedBillingCycle(context, cycle)),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedBillingCycle = value ?? 'monthly'),
              ),
              const SizedBox(height: 16),

              // 결제일 선택
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: _getLocalizedLabel(context, 'billing_day'),
                  prefixIcon: const Icon(Icons.calendar_today,
                      color: Color(0xFF2C3E50)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onTap: () => _selectBillingDay(context),
                controller: TextEditingController(
                  text: _getLocalizedDay(context, _selectedBillingDay),
                ),
              ),
              const SizedBox(height: 24),

              // 추가 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _addSubscription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _getLocalizedLabel(context, 'add'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSubscription() {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        final currency = context.read<AppSettingsBloc>().state.currency;

        final amountStr = _amountController.text
            .replaceAll(',', '')
            .replaceAll(RegExp(r'[^0-9.]'), '');

        try {
          final amount = double.parse(amountStr);

          final subscription = SubscriptionModel(
            id: const Uuid().v4(),
            name: _nameController.text,
            amount: amount,
            currency: currency,
            startDate: DateTime.now(),
            billingCycle: _selectedBillingCycle,
            billingDay: _selectedBillingDay,
            category: _selectedCategory,
            userId: authState.user.id,
            isActive: true,
          );

          context.read<SubscriptionBloc>().add(AddSubscription(subscription));
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getLocalizedError(context, 'invalid_amount')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
