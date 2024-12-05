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
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 프로필 이미지
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2C3E50).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF2C3E50).withOpacity(0.1),
              backgroundImage:
                  user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? Text(
                      user.displayName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        color: Color(0xFF2C3E50),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          // 사용자 이름
          Text(
            user.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          // 이메일
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          // 프로필 편집 버튼
          OutlinedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => EditProfileBottomSheet(user: user),
              );
            },
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF2C3E50)),
            label: Text(
              _getLocalizedEditButtonText(context),
              style: const TextStyle(color: Color(0xFF2C3E50)),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: const BorderSide(color: Color(0xFF2C3E50)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
