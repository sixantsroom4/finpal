// lib/presentation/pages/profile/profile_page.dart
import 'package:finpal/presentation/bloc/auth/auth_event.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/pages/profile/profile_header.dart';
import 'package:finpal/presentation/pages/profile/profile_menu_list.dart';
import 'package:finpal/presentation/pages/settings/widget/edit_profile_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C3E50)),
            ),
          );
        }

        final user = state.user;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF2C3E50),
            elevation: 0,
            title: Text(
              _getLocalizedTitle(context),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(20),
              child: Container(
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<AuthBloc>().add(AuthCheckRequested());
            },
            color: const Color(0xFF2C3E50),
            child: ListView(
              children: [
                ProfileHeader(user: user),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const ProfileMenuList(),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Profile',
      AppLanguage.korean: '프로필',
      AppLanguage.japanese: 'プロフィール',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }
}
