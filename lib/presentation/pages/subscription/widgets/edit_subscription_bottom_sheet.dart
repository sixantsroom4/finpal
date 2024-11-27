// lib/presentation/pages/subscription/widgets/edit_subscription_bottom_sheet.dart
import 'package:finpal/presentation/bloc/subscription/subscription_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/subscription.dart';
import '../../../bloc/subscription/subscription_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';

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
    _selectedCategory = widget.subscription.category;
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

  Map<String, String> _getLocalizedCategories(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> categories = {
      'OTT': {
        AppLanguage.english: 'OTT',
        AppLanguage.korean: 'OTT',
        AppLanguage.japanese: 'OTT',
      },
      'MUSIC': {
        AppLanguage.english: 'Music',
        AppLanguage.korean: '음악',
        AppLanguage.japanese: '音楽',
      },
      'GAME': {
        AppLanguage.english: 'Game',
        AppLanguage.korean: '게임',
        AppLanguage.japanese: 'ゲーム',
      },
      'FITNESS': {
        AppLanguage.english: 'Fitness',
        AppLanguage.korean: '피트니스',
        AppLanguage.japanese: 'フィットネス',
      },
      'PRODUCTIVITY': {
        AppLanguage.english: 'Productivity',
        AppLanguage.korean: '생산성',
        AppLanguage.japanese: '生産性',
      },
      'SOFTWARE': {
        AppLanguage.english: 'Software',
        AppLanguage.korean: '소프트웨어',
        AppLanguage.japanese: 'ソフトウェア',
      },
      'PET_CARE': {
        AppLanguage.english: 'Pet Care',
        AppLanguage.korean: '반려동물 관리',
        AppLanguage.japanese: 'ペットケア',
      },
      'BEAUTY': {
        AppLanguage.english: 'Beauty',
        AppLanguage.korean: '뷰티',
        AppLanguage.japanese: '美容',
      },
      'CAR_SERVICES': {
        AppLanguage.english: 'Car Services',
        AppLanguage.korean: '자동차 서비스',
        AppLanguage.japanese: '車サービス',
      },
      'STREAMING': {
        AppLanguage.english: 'Streaming Services',
        AppLanguage.korean: '스트리밍 서비스',
        AppLanguage.japanese: 'ストリーミングサービス',
      },
      'RENT': {
        AppLanguage.english: 'Rent',
        AppLanguage.korean: '월세',
        AppLanguage.japanese: '家賃',
      },
      'DELIVERY': {
        AppLanguage.english: 'Delivery Services',
        AppLanguage.korean: '배송 서비스',
        AppLanguage.japanese: '配送サービス',
      },
      'PREMIUM': {
        AppLanguage.english: 'Premium Memberships',
        AppLanguage.korean: '프리미엄 멤버십',
        AppLanguage.japanese: 'プレミアム会員',
      },
      'OTHER': {
        AppLanguage.english: 'Other',
        AppLanguage.korean: '기타',
        AppLanguage.japanese: 'その他',
      },
    };

    return Map.fromEntries(
      categories.entries.map(
        (e) =>
            MapEntry(e.key, e.value[language] ?? e.value[AppLanguage.korean]!),
      ),
    );
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
                border: OutlineInputBorder(),
              ),
              items: _getLocalizedCategories(context).entries.map((e) {
                return DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? 'OTT';
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
            DropdownButtonFormField<int>(
              value: _selectedBillingDay,
              decoration: InputDecoration(
                labelText: _getLocalizedLabel(context, 'billing_day'),
                border: OutlineInputBorder(),
              ),
              items: List.generate(
                28,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('${index + 1}일'),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedBillingDay = value ?? 1;
                });
              },
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
      final currency = context.read<AppSettingsBloc>().state.currency;
      final updatedSubscription = Subscription(
        id: widget.subscription.id,
        name: _nameController.text,
        amount: double.parse(_amountController.text.replaceAll(',', '')),
        startDate: widget.subscription.startDate,
        billingCycle: _selectedBillingCycle,
        billingDay: _selectedBillingDay,
        category: _selectedCategory,
        userId: widget.subscription.userId,
        endDate: widget.subscription.endDate,
        isActive: widget.subscription.isActive,
        currency: currency,
      );

      context.read<SubscriptionBloc>().add(
            UpdateSubscription(updatedSubscription),
          );

      Navigator.pop(context);
    }
  }
}
