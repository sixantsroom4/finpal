import 'package:finpal/domain/repositories/customer_service_repository.dart';
import 'package:finpal/presentation/bloc/customer_service/customer_service_event.dart';
import 'package:finpal/presentation/bloc/customer_service/customer_service_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerServiceBloc
    extends Bloc<CustomerServiceEvent, CustomerServiceState> {
  final CustomerServiceRepository repository;

  CustomerServiceBloc({required this.repository})
      : super(CustomerServiceInitial()) {
    on<SubmitInquiry>(_onSubmitInquiry);
  }

  Future<void> _onSubmitInquiry(
    SubmitInquiry event,
    Emitter<CustomerServiceState> emit,
  ) async {
    emit(CustomerServiceLoading());
    try {
      await repository.submitInquiry(
        userId: event.userId,
        title: event.title,
        category: event.category,
        content: event.content,
        contactEmail: event.contactEmail,
        imagePaths: event.imagePaths,
      );
      emit(CustomerServiceSuccess());
    } catch (e) {
      emit(CustomerServiceError(e.toString()));
    }
  }
}
