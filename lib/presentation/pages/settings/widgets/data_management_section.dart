import 'package:finpal/presentation/pages/settings/widget/setting_item.dart';
import 'package:flutter/material.dart';
import 'settings_section.dart';

class DataManagementSection extends StatelessWidget {
  const DataManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: '데이터 관리',
      children: [
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
            value: true, // TODO: 실제 값으로 변경
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
    );
  }

  Future<void> _exportData(BuildContext context) async {
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
}
