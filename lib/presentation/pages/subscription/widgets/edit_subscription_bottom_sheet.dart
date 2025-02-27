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
                  _getLocalizedLabel(context, 'edit_subscription'),
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
                          validator: (value) => value?.isEmpty ?? true
                              ? _getLocalizedError(context, 'amount_required')
                              : null,
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
                            isExpanded: true,
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
                            isExpanded: true,
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
                            items: _getLocalizedBillingCycles(context)
                                .entries
                                .map((e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value),
                                    ))
                                .toList(),
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

                // 저장 버튼
                TextButton(
                  onPressed: _submit,
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
                    _getLocalizedLabel(context, 'save'),
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
