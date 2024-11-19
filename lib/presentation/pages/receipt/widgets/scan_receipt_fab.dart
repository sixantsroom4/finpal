// lib/presentation/pages/receipt/widgets/scan_receipt_fab.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ScanReceiptFab extends StatelessWidget {
  final Function(String) onImageSelected;

  const ScanReceiptFab({
    super.key,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      icon: const Icon(Icons.document_scanner),
      label: const Text('영수증 스캔'),
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
              title: const Text('카메라로 스캔'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
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

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      debugPrint('===== 이미지 선택 시작 =====');
      final picker = ImagePicker();
      debugPrint('ImagePicker 인스턴스 생성됨');

      try {
        final image = await picker.pickImage(
          source: source,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85,
        );
        debugPrint('pickImage 시도 완료');

        if (!context.mounted) return;

        if (image == null) {
          debugPrint('이미지 선택 취소됨');
          return;
        }

        debugPrint('선택된 이미지 경로: ${image.path}');

        final croppedImage = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1.4),
          compressQuality: 85,
          compressFormat: ImageCompressFormat.jpg,
        );

        if (croppedImage != null && context.mounted) {
          debugPrint('크롭된 이미지 처리 시작: ${croppedImage.path}');
          await onImageSelected(croppedImage.path);
          debugPrint('이미지 처리 완료');
        } else {
          debugPrint('이미지 크롭 취소됨');
        }
      } catch (e, stackTrace) {
        debugPrint('이미지 선택 중 오류: $e');
        debugPrint('이미지 선택 스택 트레이스: $stackTrace');
        rethrow;
      }
    } catch (e, stackTrace) {
      debugPrint('이미지 처리 오류: $e');
      debugPrint('스택 트레이스: $stackTrace');
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('이미지 처리 중 오류가 발생했습니다: ${e.toString()}')),
        );
      }
    }
  }
}
