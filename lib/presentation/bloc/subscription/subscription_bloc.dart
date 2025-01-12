import 'package:finpal/data/models/subscription_model.dart';
import 'package:finpal/domain/entities/subscription.dart';
import 'package:finpal/domain/repositories/subscription_repository.dart';
import 'package:finpal/presentation/bloc/subscription/subscription_event.dart';
import 'package:finpal/presentation/bloc/subscription/subscription_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  /// 수정된 AddSubscription 핸들러: 추가 후 최신 데이터를 await 방식으로 불러와 로딩 상태 후에 UI 갱신
  Future<void> _onAddSubscription(
    AddSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    final result =
        await _subscriptionRepository.addSubscription(event.subscription);
    await result.fold(
      (failure) async {
        emit(SubscriptionError(failure.message));
      },
      (subscription) async {
        try {
          // 구독 추가 후 관련 지출 생성 처리 (만약 실패하면 에러 처리)
          await _subscriptionRepository.createExpenseFromSubscription(
            subscription as SubscriptionModel,
          );
          // 최신 활성 구독 목록을 불러오기 위해 로딩 상태 후 데이터 재조회
          final loadResult = await _subscriptionRepository
              .getSubscriptions(event.subscription.userId);
          loadResult.fold(
            (failure) => emit(SubscriptionError(failure.message)),
            (subscriptions) => emit(_createLoadedState(subscriptions)),
          );
          // UI 쪽에서는 BlocListener로 OperationSuccess 메시지(SnackBar 등) 처리 권장
        } catch (e) {
          emit(SubscriptionError('구독 지출 생성 실패: ${e.toString()}'));
        }
      },
    );
  }

  /// 수정된 UpdateSubscription 핸들러: 업데이트 후 최신 데이터를 불러오도록 처리
  Future<void> _onUpdateSubscription(
    UpdateSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    final subscription = event.subscription;
    final updateResult =
        await _subscriptionRepository.updateSubscription(subscription);
    await updateResult.fold(
      (failure) async => emit(SubscriptionError(failure.message)),
      (updatedSubscription) async {
        try {
          await _subscriptionRepository.updateExpenseForSubscription(
            updatedSubscription as SubscriptionModel,
          );
          // 최신 활성 구독 불러오기
          final loadResult = await _subscriptionRepository
              .getSubscriptions(subscription.userId);
          loadResult.fold(
            (failure) => emit(SubscriptionError(failure.message)),
            (subscriptions) => emit(_createLoadedState(subscriptions)),
          );
        } catch (e) {
          emit(SubscriptionError('구독 지출 업데이트 실패: ${e.toString()}'));
        }
      },
    );
  }

  /// 수정된 DeleteSubscription 핸들러: 삭제 후 로딩 상태를 표시하고 최신 데이터를 불러오도록 처리
  Future<void> _onDeleteSubscription(
    DeleteSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    final result =
        await _subscriptionRepository.deleteSubscription(event.subscriptionId);
    await result.fold(
      (failure) async {
        emit(SubscriptionError(failure.message));
      },
      (_) async {
        // 삭제 후 최신 구독 목록을 불러오기
        final loadResult =
            await _subscriptionRepository.getSubscriptions(event.userId);
        loadResult.fold(
          (failure) => emit(SubscriptionError(failure.message)),
          (subscriptions) => emit(_createLoadedState(subscriptions)),
        );
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
    await result.fold(
      (failure) async => emit(SubscriptionError(failure.message)),
      (_) async {
        // 삭제(취소) 후 최신 활성 구독 목록 재조회
        final loadResult =
            await _subscriptionRepository.getSubscriptions(event.userId);
        loadResult.fold(
          (failure) => emit(SubscriptionError(failure.message)),
          (subscriptions) => emit(_createLoadedState(subscriptions)),
        );
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
      if (subscription.billingCycle.toLowerCase() == 'monthly') {
        monthlyTotal += subscription.amount;
        yearlyTotal += subscription.amount * 12;
      } else if (subscription.billingCycle.toLowerCase() == 'yearly') {
        yearlyTotal += subscription.amount;
        monthlyTotal += subscription.amount / 12;
      }

      categoryTotals[subscription.category] =
          (categoryTotals[subscription.category] ?? 0) + subscription.amount;

      final nextBillingDate = subscription.calculateNextBillingDate();
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
