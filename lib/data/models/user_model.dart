// data/models/user_model.dart
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String email,
    required String displayName,
    String? photoUrl,
    required DateTime createdAt,
    List<String>? sharedExpenseGroups,
    Map<String, dynamic>? settings,
  }) : super(
          id: id,
          email: email,
          displayName: displayName,
          photoUrl: photoUrl,
          createdAt: createdAt,
          sharedExpenseGroups: sharedExpenseGroups,
          settings: settings,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      sharedExpenseGroups: json['sharedExpenseGroups'] != null
          ? List<String>.from(json['sharedExpenseGroups'])
          : null,
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'sharedExpenseGroups': sharedExpenseGroups,
      'settings': settings,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      createdAt: user.createdAt,
      sharedExpenseGroups: user.sharedExpenseGroups,
      settings: user.settings,
    );
  }

  /// Firebase User에서 UserModel 생성
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName ?? 'User',
      photoUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(), // 신규 유저인 경우
      settings: {
        'theme': 'system',
        'notifications': {
          'expenses': true,
          'subscriptions': true,
          'shared': true,
        },
        'currency': 'KRW',
        'language': 'ko',
      },
    );
  }

  /// 사용자 설정 업데이트
  UserModel copyWithSettings(Map<String, dynamic> newSettings) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: createdAt,
      sharedExpenseGroups: sharedExpenseGroups,
      settings: {
        ...?settings,
        ...newSettings,
      },
    );
  }

  /// 공유 그룹 추가
  UserModel addSharedGroup(String groupId) {
    final updatedGroups = List<String>.from(sharedExpenseGroups ?? []);
    if (!updatedGroups.contains(groupId)) {
      updatedGroups.add(groupId);
    }

    return UserModel(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: createdAt,
      sharedExpenseGroups: updatedGroups,
      settings: settings,
    );
  }

  /// 공유 그룹 제거
  UserModel removeSharedGroup(String groupId) {
    if (sharedExpenseGroups == null) return this;

    final updatedGroups = List<String>.from(sharedExpenseGroups!)
      ..remove(groupId);

    return UserModel(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: createdAt,
      sharedExpenseGroups: updatedGroups,
      settings: settings,
    );
  }

  /// 사용자의 알림 설정 확인
  bool isNotificationEnabled(String type) {
    if (settings == null || settings!['notifications'] == null) {
      return true; // 기본값은 알림 활성화
    }

    return settings!['notifications'][type] ?? true;
  }

  /// 사용자의 선호 통화 단위
  String get preferredCurrency => settings?['currency'] ?? 'KRW';

  /// 사용자의 선호 언어
  String get preferredLanguage => settings?['language'] ?? 'ko';
}
