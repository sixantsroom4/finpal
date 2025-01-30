// lib/presentation/pages/subscription/widgets/add_subscription_bottom_sheet.dart
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/subscription/subscription_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../bloc/subscription/subscription_bloc.dart';
import '../../../bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/data/models/subscription_model.dart';
import 'package:finpal/core/utils/subscription_category_constants.dart';

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
  String _selectedCategory =
      SubscriptionCategoryConstants.categories.keys.first;
  String _selectedBillingCycle = 'monthly';
  int _selectedBillingDay = 1;
  String _selectedCurrency = 'KRW';
  DateTime _startDate = DateTime.now();

  List<Map<String, String>> _getLocalizedCategories(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    final categories = SubscriptionCategoryConstants.categories.keys.map((key) {
      return {
        'value': key,
        'label':
            SubscriptionCategoryConstants.getLocalizedCategory(context, key),
      };
    }).toList();
    print('Localized Categories: $categories');
    return categories;
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
                const SizedBox(height: 12),

                // 서비스명과 금액을 가로로 배치
                Row(
                  children: [
                    // 서비스명 입력
                    Expanded(
                      flex: 3,
                      child: _buildDetailField(
                        context: context,
                        icon: Icons.subscriptions,
                        label: _getLocalizedLabel(context, 'service_name'),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          validator: (value) => value?.isEmpty ?? true
                              ? _getLocalizedError(
                                  context, 'service_name_required')
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 금액 입력
                    Expanded(
                      flex: 2,
                      child: _buildDetailField(
                        context: context,
                        icon: Icons.attach_money,
                        label: _getLocalizedLabel(context, 'amount'),
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffix: Text(_getCurrencySymbol(context)),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return _getLocalizedError(
                                  context, 'amount_required');
                            }
                            if (double.tryParse(value!.replaceAll(',', '')) ==
                                null) {
                              return _getLocalizedError(
                                  context, 'invalid_amount');
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 카테고리와 결제 주기를 가로로 배치
                Row(
                  children: [
                    // 카테고리 선택
                    Expanded(
                      flex: 1,
                      child: _buildDetailField(
                        context: context,
                        icon: Icons.category,
                        label: _getLocalizedLabel(context, 'category'),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            inputDecorationTheme: const InputDecorationTheme(
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
                            isExpanded: true,
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
                            items: _getLocalizedCategories(context)
                                .map((category) {
                              return DropdownMenuItem<String>(
                                value: category['value'],
                                child: Row(
                                  children: [
                                    Icon(
                                      SubscriptionCategoryConstants
                                                  .categoryIcons[
                                              category['value']] ??
                                          Icons.category_outlined,
                                      size: 20,
                                      color: const Color(0xFF2C3E50),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        category['label']!,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _selectedCategory = value!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 결제 주기 선택
                    Expanded(
                      flex: 1,
                      child: _buildDetailField(
                        context: context,
                        icon: Icons.repeat,
                        label: _getLocalizedLabel(context, 'billing_cycle'),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            inputDecorationTheme: const InputDecorationTheme(
                              border: InputBorder.none,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedBillingCycle,
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
                            items: ['monthly', 'yearly', 'weekly'].map((cycle) {
                              return DropdownMenuItem(
                                value: cycle,
                                child: Text(
                                    _getLocalizedBillingCycle(context, cycle)),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() =>
                                _selectedBillingCycle = value ?? 'monthly'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 결제일 선택
                _buildDetailField(
                  context: context,
                  icon: Icons.calendar_today,
                  label: _getLocalizedLabel(context, 'billing_day'),
                  child: InkWell(
                    onTap: () => _selectBillingDay(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _getLocalizedDay(context, _selectedBillingDay),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 추가 버튼
                TextButton(
                  onPressed: _addSubscription,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF2C3E50),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(
                    _getLocalizedLabel(context, 'add'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
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
            category: _selectedCategory.toLowerCase(),
            userId: authState.user.id,
            isActive: true,
            isPaused: false,
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
