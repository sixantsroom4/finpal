// lib/presentation/pages/settings/settings_page.dart
import 'package:finpal/presentation/bloc/auth/auth_event.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/pages/settings/widget/preferences_section.dart';
import 'package:finpal/presentation/pages/settings/widget/profile_section.dart';
import 'package:finpal/presentation/pages/settings/widget/setting_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) {
            return const Center(
              child: Text('로그인이 필요합니다'),
            );
          }

          return ListView(
            children: [
              // 프로필 섹션
              ProfileSection(user: state.user),

              const Divider(),

              // 일반 설정
              const PreferencesSection(),

              const Divider(),

              // 알림 설정
              _buildSettingSection(
                title: '알림 설정',
                items: [
                  SettingItem(
                    icon: Icons.notifications,
                    title: '예산 초과 알림',
                    subtitle: '예산의 80% 이상 사용 시 알림',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // TODO: 알림 설정 변경 구현
                      },
                    ),
                  ),
                  SettingItem(
                    icon: Icons.subscriptions,
                    title: '구독 결제 알림',
                    subtitle: '결제 3일 전 알림',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // TODO: 알림 설정 변경 구현
                      },
                    ),
                  ),
                ],
              ),

              const Divider(),

              // 데이터 관리
              _buildSettingSection(
                title: '데이터 관리',
                items: [
                  SettingItem(
                    icon: Icons.file_download,
                    title: '데이터 내보내기',
                    subtitle: 'CSV 파일로 저장',
                    onTap: () => _exportData(context),
                  ),
                  SettingItem(
                    icon: Icons.cloud_upload,
                    title: '데이터 백업',
                    subtitle: '클라우드에 자동 백업',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // TODO: 백업 설정 변경 구현
                      },
                    ),
                  ),
                  SettingItem(
                    icon: Icons.delete_outline,
                    title: '데이터 초기화',
                    subtitle: '모든 데이터 삭제',
                    textColor: Colors.red,
                    onTap: () => _showResetDataDialog(context),
                  ),
                ],
              ),

              const Divider(),

              // 앱 정보
              _buildSettingSection(
                title: '앱 정보',
                items: [
                  SettingItem(
                    icon: Icons.info_outline,
                    title: '버전',
                    subtitle: '1.0.0',
                  ),
                  SettingItem(
                    icon: Icons.policy_outlined,
                    title: '개인정보 처리방침',
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  SettingItem(
                    icon: Icons.description_outlined,
                    title: '이용약관',
                    onTap: () => _showTermsOfService(context),
                  ),
                ],
              ),

              const Divider(),

              // 로그아웃
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  '로그아웃',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _showLogoutDialog(context),
              ),

              // 계정 삭제
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  '계정 삭제',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _showDeleteAccountDialog(context),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingSection({
    required String title,
    required List<SettingItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Future<void> _exportData(BuildContext context) async {
    // TODO: 데이터 내보내기 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('데이터 내보내기 기능 준비 중입니다.')),
    );
  }

  void _showResetDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 초기화'),
        content: const Text('모든 데이터가 영구적으로 삭제됩니다. 계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 데이터 초기화 구현
              Navigator.pop(context);
            },
            child: const Text(
              '초기화',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    // TODO: 개인정보 처리방침 페이지 구현
  }

  void _showTermsOfService(BuildContext context) {
    // TODO: 이용약관 페이지 구현
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
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
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제'),
        content: const Text(
          '계정과 모든 데이터가 영구적으로 삭제됩니다. 이 작업은 되돌릴 수 없습니다. 계속하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 계정 삭제 구현
              Navigator.pop(context);
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
