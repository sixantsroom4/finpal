// lib/presentation/pages/profile/widgets/profile_menu_list.dart
import 'package:finpal/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:finpal/domain/entities/user.dart';
import 'package:finpal/presentation/bloc/auth/auth_event.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileMenuList extends StatelessWidget {
  final User user;

  const ProfileMenuList({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 앱 설정
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('앱 설정'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/settings'),
        ),

        // 알림 설정
        ListTile(
          leading: const Icon(Icons.notifications_outlined),
          title: const Text('알림 설정'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 알림 설정 페이지로 이동
          },
        ),

        // 계정 설정
        ListTile(
          leading: const Icon(Icons.account_circle_outlined),
          title: const Text('계정 설정'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 계정 설정 페이지로 이동
          },
        ),

        const Divider(),

        // 고객 센터
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('고객 센터'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 고객 센터 페이지로 이동
          },
        ),

        // 약관 및 정책
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('약관 및 정책'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 약관 페이지로 이동
          },
        ),

        const Divider(),

        // 로그아웃
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            '로그아웃',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('로그아웃'),
                content: const Text('정말 로그아웃 하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthSignedOut());
                      Navigator.pop(context);
                    },
                    child: const Text('로그아웃'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
