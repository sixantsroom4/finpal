import 'package:finpal/data/models/subscription_model.dart';
import 'package:finpal/domain/entities/subscription.dart';
import 'package:finpal/presentation/bloc/subscription/subscription_event.dart';
import 'package:finpal/presentation/bloc/subscription/subscription_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/subscription_repository.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _subscriptionRepository;

  SubscriptionBloc({
    required SubscriptionRepository subscriptionRepository,
  })  : _subscriptionRepository = subscriptionRepository,
        super(SubscriptionInitial()) {
    on<LoadSubscriptions>(_onLoadSubscriptions);
    on<LoadActiveSubscriptions>(_onLoadActiveSubscriptions);
    on<AddSubscription>(_onAddSubscription);
    on<UpdateSubscription>(_onUpdateSubscription);
    on<DeleteSubscription>(_onDeleteSubscription);
    on<LoadSubscriptionsByCategory>(_onLoadSubscriptionsByCategory);
    on<LoadSubscriptionsByBillingDate>(_onLoadSubscriptionsByBillingDate);
    on<CancelSubscription>(_onCancelSubscription);
    on<LoadSubscriptionById>(_onLoadSubscriptionById);
  }

  Future<void> _onLoadSubscriptions(
    LoadSubscriptions event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    final result = await _subscriptionRepository.getSubscriptions(event.userId);

    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscriptions) => emit(_createLoadedState(subscriptions)),
    );
  }

  Future<void> _onLoadActiveSubscriptions(
    LoadActiveSubscriptions event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());

    final result = await _subscriptionRepository.getSubscriptions(event.userId);

    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscriptions) {
        // 결제일별 구독 그룹화 (활성 구독만)
        final billingDaySubscriptions = <int, List<Subscription>>{};
        for (var subscription in subscriptions.where((s) => s.isActive)) {
          if (!billingDaySubscriptions.containsKey(subscription.billingDay)) {
            billingDaySubscriptions[subscription.billingDay] = [];
          }
          billingDaySubscriptions[subscription.billingDay]!.add(subscription);
        }

        // 카테고리별 총액 계산 (활성 구독만)
        final categoryTotals = <String, double>{};
        double monthlyTotal = 0;
        double yearlyTotal = 0;

        for (var subscription in subscriptions.where((s) => s.isActive)) {
          monthlyTotal += subscription.amount;
          yearlyTotal += subscription.billingCycle.toLowerCase() == 'monthly'
              ? subscription.amount * 12
              : subscription.amount;

          categoryTotals.update(
            subscription.category,
            (value) => value + subscription.amount,
            ifAbsent: () => subscription.amount,
          );
        }

        emit(SubscriptionLoaded(
          subscriptions: subscriptions,
          monthlyTotal: monthlyTotal,
          yearlyTotal: yearlyTotal,
          categoryTotals: categoryTotals,
          billingDaySubscriptions: billingDaySubscriptions,
        ));
      },
    );
  }

  Future<void> _onAddSubscription(
    AddSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    final result =
        await _subscriptionRepository.addSubscription(event.subscription);

    await result.fold(
      (failure) async => emit(SubscriptionError(failure.message)),
      (subscription) async {
        try {
          await _subscriptionRepository.createExpenseFromSubscription(
            subscription as SubscriptionModel,
          );
          emit(const SubscriptionOperationSuccess('구독이 추가되었습니다.'));
          add(LoadActiveSubscriptions(event.subscription.userId));
        } catch (e) {
          emit(SubscriptionError('구독 지출 생성 실패: ${e.toString()}'));
        }
      },
    );
  }

  Future<void> _onUpdateSubscription(
    UpdateSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    final subscription = event.subscription;

    final updateResult =
        await _subscriptionRepository.updateSubscription(subscription);

    updateResult.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (updatedSubscription) async {
        try {
          // 기존 지출 내역 확인 (subscriptionId를 사용하여 조회)
          final existingExpense = await _subscriptionRepository
              .findExpenseBySubscriptionId(subscription.id);

          if (existingExpense != null) {
            // 기존 지출 내역 업데이트
            await _subscriptionRepository.updateExpenseForSubscription(
              updatedSubscription as SubscriptionModel,
            );
          } else {
            // 기존 지출 내역이 없으면 새로 생성 (드문 경우)
            await _subscriptionRepository.createExpenseFromSubscription(
              updatedSubscription as SubscriptionModel,
            );
          }

          emit(const SubscriptionOperationSuccess('구독이 수정되었습니다.'));
          add(LoadActiveSubscriptions(subscription.userId));
        } catch (e) {
          emit(SubscriptionError('구독 지출 업데이트 실패: ${e.toString()}'));
        }
      },
    );
  }

  Future<void> _onDeleteSubscription(
    DeleteSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    final result =
        await _subscriptionRepository.deleteSubscription(event.subscriptionId);

    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (_) {
        emit(const SubscriptionOperationSuccess('구독이 삭제되었습니다.'));
        if (state is SubscriptionLoaded) {
          final userId =
              (state as SubscriptionLoaded).subscriptions.firstOrNull?.userId;
          if (userId != null) {
            add(LoadActiveSubscriptions(userId));
          }
        }
      },
    );
  }

  Future<void> _onCancelSubscription(
    CancelSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    final result =
        await _subscriptionRepository.deleteSubscription(event.subscriptionId);
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (_) {
        emit(const SubscriptionOperationSuccess('구독이 취소되었습니다.'));
        add(LoadActiveSubscriptions(event.userId));
      },
    );
  }

  Future<void> _onLoadSubscriptionsByCategory(
    LoadSubscriptionsByCategory event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    final result = await _subscriptionRepository.getSubscriptionsByCategory(
      event.userId,
      event.category,
    );

    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscriptions) => emit(_createLoadedState(subscriptions)),
    );
  }

  Future<void> _onLoadSubscriptionsByBillingDate(
    LoadSubscriptionsByBillingDate event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    final result = await _subscriptionRepository.getSubscriptionsByBillingDate(
      event.userId,
      event.billingDay,
    );

    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscriptions) => emit(_createLoadedState(subscriptions)),
    );
  }

  Future<void> _onLoadSubscriptionById(
    LoadSubscriptionById event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    final result =
        await _subscriptionRepository.getSubscriptionById(event.subscriptionId);

    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscription) => emit(SubscriptionLoaded(
        subscriptions: [subscription],
        monthlyTotal: 0,
        yearlyTotal: 0,
        categoryTotals: {},
        billingDaySubscriptions: {},
      )),
    );
  }

  SubscriptionLoaded _createLoadedState(List<Subscription> subscriptions) {
    double monthlyTotal = 0;
    double yearlyTotal = 0;
    final categoryTotals = <String, double>{};
    final billingDaySubscriptions = <int, List<Subscription>>{};
    final now = DateTime.now();

    for (var subscription
        in subscriptions.where((sub) => sub.isCurrentlyActive)) {
      // 월간/연간 총액 계산
      if (subscription.billingCycle.toLowerCase() == 'monthly') {
        monthlyTotal += subscription.amount;
        yearlyTotal += subscription.amount * 12;
      } else if (subscription.billingCycle.toLowerCase() == 'yearly') {
        yearlyTotal += subscription.amount;
        monthlyTotal += subscription.amount / 12;
      }

      // 카테고리별 총액 계산
      categoryTotals[subscription.category] =
          (categoryTotals[subscription.category] ?? 0) + subscription.amount;

      // 다음 결제일 계산
      final nextBillingDate = subscription.calculateNextBillingDate();

      // 결제일별 구독 그룹화 (미래 결제 포함)
      if (nextBillingDate.month == now.month ||
          nextBillingDate.month == now.month + 1 ||
          (now.month == 12 && nextBillingDate.month == 1)) {
        if (!billingDaySubscriptions.containsKey(subscription.billingDay)) {
          billingDaySubscriptions[subscription.billingDay] = [];
        }
        billingDaySubscriptions[subscription.billingDay]!.add(subscription);
      }
    }

    return SubscriptionLoaded(
      subscriptions: subscriptions,
      monthlyTotal: monthlyTotal,
      yearlyTotal: yearlyTotal,
      categoryTotals: categoryTotals,
      billingDaySubscriptions: billingDaySubscriptions,
    );
  }
}
