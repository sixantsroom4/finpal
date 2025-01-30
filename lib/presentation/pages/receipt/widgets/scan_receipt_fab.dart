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
        size: 20,
      ),
      label: Text(
        _getLocalizedLabel(context, 'scan_receipt'),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFF2C3E50),
                  size: 24,
                ),
                title: Text(
                  _getLocalizedLabel(context, 'scan_with_camera'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                onTap: () => _pickImage(ImageSource.camera, context),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF2C3E50),
                  size: 24,
                ),
                title: Text(
                  _getLocalizedLabel(context, 'select_from_gallery'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                onTap: () => _pickImage(ImageSource.gallery, context),
              ),
              const SizedBox(height: 16),
            ],
          ),
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
        AppLanguage.japanese: 'ギャラリーから探す',
      },
      'error_processing_image': {
        AppLanguage.english: 'An error occurred while processing the image: ',
        AppLanguage.korean: '이미지 처리 중 오류가 발생했습니다: ',
        AppLanguage.japanese: 'An error occurred while processing the image: ',
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
