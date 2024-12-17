import 'package:finpal/domain/repositories/customer_service_repository.dart';
import 'package:finpal/presentation/bloc/customer_service/customer_service_event.dart';
import 'package:finpal/presentation/bloc/customer_service/customer_service_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/core/services/notion_service.dart';

class CustomerServiceBloc
    extends Bloc<CustomerServiceEvent, CustomerServiceState> {
  final NotionService _notionService;
  final CustomerServiceRepository _repository;

  CustomerServiceBloc({
    required NotionService notionService,
    required CustomerServiceRepository repository,
  })  : _notionService = notionService,
        _repository = repository,
        super(CustomerServiceInitial()) {
    on<SubmitInquiry>(_onSubmitInquiry);
  }

  Future<void> _onSubmitInquiry(
    SubmitInquiry event,
    Emitter<CustomerServiceState> emit,
  ) async {
    try {
      emit(CustomerServiceLoading());

      debugPrint('Firebase 저장 시도...');
      await _repository.submitInquiry(
        userId: event.userId,
        title: event.title,
        category: event.category,
        content: event.content,
        contactEmail: event.contactEmail,
        imagePaths: event.imagePaths,
      );
      debugPrint('Firebase 저장 성공');

      debugPrint('Notion 저장 시도...');
      await _notionService.createInquiry(
        title: event.title,
        category: event.category,
        content: event.content,
        email: event.contactEmail,
        userId: event.userId,
        imagePaths: event.imagePaths,
      );
      debugPrint('Notion 저장 성공');

      emit(CustomerServiceSuccess());
    } catch (e) {
      debugPrint('에러 발생: $e');
      emit(CustomerServiceError(message: e.toString()));
    }
  }
}
