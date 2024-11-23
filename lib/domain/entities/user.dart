import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final List<String>? sharedExpenseGroups;
  final Map<String, dynamic>? settings;
  final bool hasAcceptedTerms;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.sharedExpenseGroups,
    this.settings,
    this.hasAcceptedTerms = false,
  });

  String get currency => settings?['currency'] ?? 'KRW';

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        createdAt,
        sharedExpenseGroups,
        settings,
        hasAcceptedTerms,
      ];

  User copyWith({
    String? displayName,
    String? photoUrl,
    List<String>? sharedExpenseGroups,
    Map<String, dynamic>? settings,
    bool? hasAcceptedTerms,
  }) {
    return User(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      sharedExpenseGroups: sharedExpenseGroups ?? this.sharedExpenseGroups,
      settings: settings ?? this.settings,
      hasAcceptedTerms: hasAcceptedTerms ?? this.hasAcceptedTerms,
    );
  }
}
