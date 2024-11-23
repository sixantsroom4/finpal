import 'package:finpal/presentation/pages/settings/widget/setting_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'settings_section.dart';

class DataManagementSection extends StatelessWidget {
  const DataManagementSection({super.key});

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'data_management': {
        AppLanguage.english: 'Data Management',
        AppLanguage.korean: '데이터 관리',
        AppLanguage.japanese: 'データ管理',
      },
      'export_data': {
        AppLanguage.english: 'Export Data',
        AppLanguage.korean: '데이터 내보내기',
        AppLanguage.japanese: 'データのエクスポート',
      },
      'export_data_subtitle': {
        AppLanguage.english: 'Save as CSV file',
        AppLanguage.korean: 'CSV 파일로 저장',
        AppLanguage.japanese: 'CSVファイルとして保存',
      },
      'backup_data': {
        AppLanguage.english: 'Backup Data',
        AppLanguage.korean: '데이터 백업',
        AppLanguage.japanese: 'データのバックアップ',
      },
      'backup_data_subtitle': {
        AppLanguage.english: 'Auto backup to cloud',
        AppLanguage.korean: '클라우드에 자동 백업',
        AppLanguage.japanese: 'クラウドに自動バックアップ',
      },
      'reset_data': {
        AppLanguage.english: 'Reset Data',
        AppLanguage.korean: '데이터 초기화',
        AppLanguage.japanese: 'データの初期化',
      },
      'reset_data_subtitle': {
        AppLanguage.english: 'Delete all data',
        AppLanguage.korean: '모든 데이터 삭제',
        AppLanguage.japanese: '全てのデータを削除',
      },
      'reset_data_title': {
        AppLanguage.english: 'Reset Data',
        AppLanguage.korean: '데이터 초기화',
        AppLanguage.japanese: 'データの初期化',
      },
      'reset_data_message': {
        AppLanguage.english:
            'All data will be permanently deleted. Do you want to continue?',
        AppLanguage.korean: '모든 데이터가 영구적으로 삭제됩니다. 계속하시겠습니까?',
        AppLanguage.japanese: '全てのデータが永久に削除されます。続行しますか？',
      },
      'cancel': {
        AppLanguage.english: 'Cancel',
        AppLanguage.korean: '취소',
        AppLanguage.japanese: 'キャンセル',
      },
      'reset': {
        AppLanguage.english: 'Reset',
        AppLanguage.korean: '초기화',
        AppLanguage.japanese: '初期化',
      },
      'export_data_preparing': {
        AppLanguage.english: 'Export feature is being prepared.',
        AppLanguage.korean: '데이터 내보내기 기능 준비 중입니다.',
        AppLanguage.japanese: 'エクスポート機能は準備中です。',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: _getLocalizedLabel(context, 'data_management'),
      children: [
        SettingItem(
          icon: Icons.file_download,
          title: _getLocalizedLabel(context, 'export_data'),
          subtitle: _getLocalizedLabel(context, 'export_data_subtitle'),
          onTap: () => _exportData(context),
        ),
        SettingItem(
          icon: Icons.cloud_upload,
          title: _getLocalizedLabel(context, 'backup_data'),
          subtitle: _getLocalizedLabel(context, 'backup_data_subtitle'),
          trailing: Switch(
            value: true, // TODO: 실제 값으로 변경
            onChanged: (value) {
              // TODO: 백업 설정 변경 구현
            },
          ),
        ),
        SettingItem(
          icon: Icons.delete_outline,
          title: _getLocalizedLabel(context, 'reset_data'),
          subtitle: _getLocalizedLabel(context, 'reset_data_subtitle'),
          textColor: Colors.red,
          onTap: () => _showResetDataDialog(context),
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getLocalizedLabel(context, 'export_data_preparing')),
      ),
    );
  }

  void _showResetDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedLabel(context, 'reset_data_title')),
        content: Text(_getLocalizedLabel(context, 'reset_data_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getLocalizedLabel(context, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              // TODO: 데이터 초기화 구현
              Navigator.pop(context);
            },
            child: Text(
              _getLocalizedLabel(context, 'reset'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
