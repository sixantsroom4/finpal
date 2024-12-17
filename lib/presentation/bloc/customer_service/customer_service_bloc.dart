import 'package:finpal/domain/repositories/customer_service_repository.dart';
import 'package:finpal/presentation/bloc/customer_service/customer_service_event.dart';
import 'package:finpal/presentation/bloc/customer_service/customer_service_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/core/services/notion_service.dart';

class CustomerServiceBloc
    extends Bloc<CustomerServiceEvent, CustomerServiceState> {
  final NotionService _notionService;

  CustomerServiceBloc({required NotionService notionService})
      : _notionService = notionService,
        super(CustomerServiceInitial()) {
    on<SubmitInquiry>(_onSubmitInquiry);
  }

  Future<void> _onSubmitInquiry(
    SubmitInquiry event,
    Emitter<CustomerServiceState> emit,
  ) async {
    try {
      emit(CustomerServiceLoading());
      await _notionService.createInquiry(
        title: event.title,
        category: event.category,
        content: event.content,
        email: event.contactEmail,
        imagePaths: event.imagePaths,
      );
      emit(CustomerServiceSuccess());
    } catch (e) {
      emit(CustomerServiceError(message: e.toString()));
    }
  }
}
