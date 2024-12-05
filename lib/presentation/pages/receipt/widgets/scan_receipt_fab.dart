// lib/presentation/pages/receipt/widgets/scan_receipt_fab.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class ScanReceiptFab extends StatelessWidget {
  final Function(String) onImageSelected;

  const ScanReceiptFab({
    super.key,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      icon: const Icon(
        Icons.document_scanner,
        color: Colors.white,
      ),
      label: Text(
        _getLocalizedLabel(context, 'scan_receipt'),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: const Color(0xFF2C3E50),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onPressed: () => _showScanOptions(context),
    );
  }

  void _showScanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(_getLocalizedLabel(context, 'scan_with_camera')),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(_getLocalizedLabel(context, 'select_from_gallery')),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'scan_receipt': {
        AppLanguage.english: 'Scan Receipt',
        AppLanguage.korean: '영수증 스캔',
        AppLanguage.japanese: 'レシートをスキャン',
      },
      'scan_with_camera': {
        AppLanguage.english: 'Scan with Camera',
        AppLanguage.korean: '카메라로 스캔',
        AppLanguage.japanese: 'カメラでスキャン',
      },
      'select_from_gallery': {
        AppLanguage.english: 'Select from Gallery',
        AppLanguage.korean: '갤러리에서 선택',
        AppLanguage.japanese: 'ギラリーから選択',
      },
      'error_processing_image': {
        AppLanguage.english: 'An error occurred while processing the image: ',
        AppLanguage.korean: '이미지 처리 중 오류가 발생했습니다: ',
        AppLanguage.japanese: '画像の処理中にエラーが発生しました: ',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      debugPrint('===== 이미지 선택 시작 =====');
      final picker = ImagePicker();
      debugPrint('ImagePicker 인스턴스 생성됨');

      final image = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      debugPrint('pickImage 시도 완료');

      if (image == null) {
        debugPrint('이미지 선택 취소됨');
        return;
      }

      debugPrint('선택된 이미지 경로: ${image.path}');
      debugPrint('onImageSelected 호출 시작');
      await onImageSelected(image.path);
      debugPrint('onImageSelected 호출 완료');
    } catch (e) {
      debugPrint('이미지 처리 오류 발생: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 처리 중 오류가 발생했습니다: ${e.toString()}')),
        );
      }
    }
  }
}
