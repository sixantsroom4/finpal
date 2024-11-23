// lib/presentation/pages/profile/widgets/profile_header.dart
import 'package:finpal/domain/entities/user.dart';
import 'package:finpal/presentation/pages/settings/widget/edit_profile_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileHeader extends StatelessWidget {
  final User user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 프로필 이미지
          CircleAvatar(
            radius: 50,
            backgroundImage:
                user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null
                ? Text(
                    user.displayName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 32),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          // 사용자 이름
          Text(
            user.displayName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          // 이메일
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 16),
          // 프로필 편집 버튼
          OutlinedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => EditProfileBottomSheet(user: user),
              );
            },
            child: Text(_getLocalizedEditButtonText(context)),
          ),
        ],
      ),
    );
  }

  String _getLocalizedEditButtonText(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> texts = {
      AppLanguage.english: 'Edit Profile',
      AppLanguage.korean: '프로필 편집',
      AppLanguage.japanese: 'プロフィール編集',
    };
    return texts[language] ?? texts[AppLanguage.korean]!;
  }
}
