import 'package:finpal/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:finpal/presentation/pages/settings/account/widgets/change_email_bottom_sheet.dart';
import 'package:finpal/presentation/pages/settings/account/widgets/change_password_bottom_sheet.dart';

class AccountSettingsList extends StatelessWidget {
  final User user;

  const AccountSettingsList({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // 이메일 변경
        ListTile(
          leading: const Icon(Icons.email_outlined),
          title: const Text('이메일 변경'),
          subtitle: Text(user.email),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => ChangeEmailBottomSheet(
                currentEmail: user.email,
              ),
            );
          },
        ),

        // 비밀번호 변경
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('비밀번호 변경'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const ChangePasswordBottomSheet(),
            );
          },
        ),

        const Divider(),

        // 연결된 소셜 계정
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            '연결된 계정',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        ListTile(
          leading: SvgPicture.asset(
            'assets/icons/google.svg',
            width: 24,
            height: 24,
          ),
          title: const Text('Google'),
          trailing: Switch(
            value: false, // TODO: 실제 연결 상태 반영
            onChanged: (value) {
              // TODO: 소셜 계정 연결/해제 구현
            },
          ),
        ),
        ListTile(
          leading: SvgPicture.asset(
            'assets/icons/apple.svg',
            width: 24,
            height: 24,
          ),
          title: const Text('Apple'),
          trailing: Switch(
            value: false, // TODO: 실제 연결 상태 반영
            onChanged: (value) {
              // TODO: 소셜 계정 연결/해제 구현
            },
          ),
        ),
      ],
    );
  }
}
