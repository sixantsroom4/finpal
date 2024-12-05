// lib/presentation/pages/subscription/subscription_page.dart
import 'package:finpal/domain/entities/subscription.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/subscription/subscription_event.dart';
import 'package:finpal/presentation/bloc/subscription/subscription_state.dart';
import 'package:finpal/presentation/pages/subscription/widgets/add_subscription_bottom_sheet.dart';
import 'package:finpal/presentation/pages/subscription/widgets/subscription_details_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/subscription/subscription_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'widgets/subscription_card.dart';
import 'widgets/subscription_statistics_card.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSubscriptions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSubscriptions() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<SubscriptionBloc>()
          .add(LoadActiveSubscriptions(authState.user.id));
    }
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'subscription_management': {
        AppLanguage.english: 'Subscription Management',
        AppLanguage.korean: '구독 관리',
        AppLanguage.japanese: 'サブスク管理',
      },
      'all_subscriptions': {
        AppLanguage.english: 'All Subscriptions',
        AppLanguage.korean: '전체 구독',
        AppLanguage.japanese: '全てのサブスク',
      },
      'upcoming_payments': {
        AppLanguage.english: 'Upcoming Payments',
        AppLanguage.korean: '결제 예정',
        AppLanguage.japanese: '支払い予定',
      },
      'no_subscriptions': {
        AppLanguage.english: 'No subscriptions registered',
        AppLanguage.korean: '등록된 구독이 없습니다',
        AppLanguage.japanese: '登録されたサブスクはありません',
      },
      'no_subscriptions_description': {
        AppLanguage.english: 'Register and manage your recurring subscriptions',
        AppLanguage.korean: '정기적으로 결제되는 구독을 등록하고 관리해보세요',
        AppLanguage.japanese: '定期的に支払うサブスクを登録して管理しましょう',
      },
      'payment_today': {
        AppLanguage.english: 'Payment due today',
        AppLanguage.korean: '오늘 결제 예정',
        AppLanguage.japanese: '今日支払い予定',
      },
      'days_until_payment': {
        AppLanguage.english: 'days until payment',
        AppLanguage.korean: '일 후 결제',
        AppLanguage.japanese: '日後に支払い',
      },
      'monthly_payment_day': {
        AppLanguage.english: 'Monthly payment on day',
        AppLanguage.korean: '매월',
        AppLanguage.japanese: '毎月',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        title: Text(
          _getLocalizedLabel(context, 'subscription_management'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: _getLocalizedLabel(context, 'all_subscriptions')),
              Tab(text: _getLocalizedLabel(context, 'upcoming_payments')),
            ],
          ),
        ),
      ),
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is SubscriptionOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C3E50)),
              ),
            );
          }

          if (state is! SubscriptionLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.subscriptions_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getLocalizedLabel(context, 'no_subscriptions'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF2C3E50),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _getLocalizedLabel(
                          context, 'no_subscriptions_description'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 통계 카드 개선
              Padding(
                padding: const EdgeInsets.all(16),
                child: SubscriptionStatisticsCard(
                  subscriptions: state.subscriptions,
                ),
              ),
              // 구독 목록
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllSubscriptionsList(state),
                    _buildUpcomingSubscriptionsList(state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubscriptionDialog(context),
        backgroundColor: const Color(0xFF2C3E50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAllSubscriptionsList(SubscriptionLoaded state) {
    // 모든 구독을 카테고리별로 그룹화
    final subscriptionsByCategory = <String, List<Subscription>>{};

    // 활성 및 일시정지된 모든 구독을 포함
    for (var subscription in state.subscriptions) {
      if (!subscriptionsByCategory.containsKey(subscription.category)) {
        subscriptionsByCategory[subscription.category] = [];
      }
      subscriptionsByCategory[subscription.category]!.add(subscription);
    }

    // 각 카테고리 내에서 활성 구독을 먼저 보여주도록 정렬
    subscriptionsByCategory.forEach((category, subscriptions) {
      subscriptions.sort((a, b) {
        if (a.isActive == b.isActive) return 0;
        return a.isActive ? -1 : 1; // 활성 구독을 먼저 표시
      });
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subscriptionsByCategory.length,
      itemBuilder: (context, index) {
        final category = subscriptionsByCategory.keys.elementAt(index);
        final subscriptions = subscriptionsByCategory[category]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                category,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...subscriptions.map(
              (subscription) => SubscriptionCard(
                subscription: subscription,
                onTap: () => _showSubscriptionDetails(context, subscription),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildUpcomingSubscriptionsList(SubscriptionLoaded state) {
    final now = DateTime.now();
    final upcomingSubscriptions = state.billingDaySubscriptions.entries
        .where((entry) => _isUpcoming(entry.key, now.day))
        .expand((entry) => entry.value)
        .toList()
      ..sort((a, b) => a.billingDay.compareTo(b.billingDay));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingSubscriptions.length,
      itemBuilder: (context, index) {
        final subscription = upcomingSubscriptions[index];
        final daysUntilBilling = _calculateDaysUntilBilling(
          subscription.billingDay,
          now.day,
        );

        return SubscriptionCard(
          subscription: subscription,
          daysUntilBilling: daysUntilBilling,
          onTap: () => _showSubscriptionDetails(context, subscription),
        );
      },
    );
  }

  bool _isUpcoming(int billingDay, int currentDay) {
    // 다음 7일 이내에 결제 예정인 구독 필터링
    final daysUntilBilling = _calculateDaysUntilBilling(billingDay, currentDay);
    return daysUntilBilling <= 7;
  }

  int _calculateDaysUntilBilling(int billingDay, int currentDay) {
    if (billingDay >= currentDay) {
      return billingDay - currentDay;
    } else {
      // 다음 달의 결제일까지 남은 일수 계산
      final now = DateTime.now();
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
      return lastDayOfMonth - currentDay + billingDay;
    }
  }

  void _showSubscriptionDetails(
      BuildContext context, Subscription subscription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SubscriptionDetailsBottomSheet(
        subscription: subscription,
      ),
    );
  }

  // 카테고리 섹션 헤더 개선
  Widget _buildCategoryHeader(BuildContext context, String category) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF2C3E50).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          category,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
      ),
    );
  }

  void _showAddSubscriptionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddSubscriptionBottomSheet(),
    );
  }
}
