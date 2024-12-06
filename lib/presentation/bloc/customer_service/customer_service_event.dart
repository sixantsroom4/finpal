import 'package:equatable/equatable.dart';

abstract class CustomerServiceEvent extends Equatable {
  const CustomerServiceEvent();

  @override
  List<Object?> get props => [];
}

class SubmitInquiry extends CustomerServiceEvent {
  final String userId;
  final String title;
  final String category;
  final String content;
  final String contactEmail;
  final List<String> imagePaths;

  const SubmitInquiry({
    required this.userId,
    required this.title,
    required this.category,
    required this.content,
    required this.contactEmail,
    required this.imagePaths,
  });

  @override
  List<Object?> get props =>
      [userId, title, category, content, contactEmail, imagePaths];
}
