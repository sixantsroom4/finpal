// lib/presentation/pages/profile/widgets/profile_menu_list.dart
import 'package:finpal/presentation/bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/pages/onboarding/widgets/terms_content.dart';
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
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => DraggableScrollableSheet(
                initialChildSize: 0.9,
                minChildSize: 0.5,
                maxChildSize: 0.9,
                builder: (_, scrollController) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '약관 및 정책',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: const [
                            TermsContent(
                              expandedItems: {},
                              readOnly: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
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
