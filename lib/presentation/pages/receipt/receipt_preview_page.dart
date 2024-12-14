import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/receipt/receipt_bloc.dart';
import '../../bloc/receipt/receipt_event.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class ReceiptPreviewPage extends StatefulWidget {
  final String imagePath;

  const ReceiptPreviewPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<ReceiptPreviewPage> createState() => _ReceiptPreviewPageState();
}

class _ReceiptPreviewPageState extends State<ReceiptPreviewPage> {
  String? _croppedImagePath;

  @override
  void initState() {
    super.initState();
    _cropImage();
  }

  Future<void> _cropImage() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: widget.imagePath,
      aspectRatio: CropAspectRatio(ratioX: 3, ratioY: 4),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: _getLocalizedLabel(context, 'crop_receipt'),
          toolbarColor: const Color(0xFF2C3E50),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          hideBottomControls: false,
          showCropGrid: true,
          cropGridStrokeWidth: 1,
          cropGridColor: Colors.white,
          cropFrameColor: const Color(0xFF2C3E50),
          activeControlsWidgetColor: const Color(0xFF2C3E50),
          dimmedLayerColor: Colors.black.withOpacity(0.7),
          statusBarColor: const Color(0xFF2C3E50),
          cropFrameStrokeWidth: 2,
        ),
        IOSUiSettings(
          title: _getLocalizedLabel(context, 'crop_receipt'),
          doneButtonTitle: _getLocalizedLabel(context, 'done'),
          cancelButtonTitle: _getLocalizedLabel(context, 'cancel'),
          rotateButtonsHidden: false,
          hidesNavigationBar: false,
          aspectRatioPickerButtonHidden: false,
          resetAspectRatioEnabled: true,
          aspectRatioLockDimensionSwapEnabled: true,
          rectX: 1.0,
          rectY: 1.0,
          minimumAspectRatio: 0.5,
        ),
      ],
      compressQuality: 90,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    if (croppedFile != null) {
      setState(() {
        _croppedImagePath = croppedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedTitle(context)),
        actions: [
          TextButton.icon(
            onPressed: _cropImage,
            icon: const Icon(Icons.crop, color: Colors.white),
            label: Text(
              _getLocalizedLabel(context, 'recrop'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(
              File(_croppedImagePath ?? widget.imagePath),
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: Text(_getLocalizedLabel(context, 'retake')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _analyzeReceipt(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_getLocalizedLabel(context, 'analyze')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Receipt Preview',
      AppLanguage.korean: '영수증 미리보기',
      AppLanguage.japanese: 'レシートプレビュー',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'retake': {
        AppLanguage.english: 'Retake',
        AppLanguage.korean: '다시 찍기',
        AppLanguage.japanese: '撮り直す',
      },
      'analyze': {
        AppLanguage.english: 'Analyze Receipt',
        AppLanguage.korean: '영수증 분석하기',
        AppLanguage.japanese: 'レシートを分析する',
      },
      'recrop': {
        AppLanguage.english: 'Recrop',
        AppLanguage.korean: '다시 자르기',
        AppLanguage.japanese: '切り直す',
      },
      'crop_receipt': {
        AppLanguage.english: 'Crop Receipt',
        AppLanguage.korean: '영수증 자르기',
        AppLanguage.japanese: 'レシートの切り取り',
      },
      'done': {
        AppLanguage.english: 'Done',
        AppLanguage.korean: '완료',
        AppLanguage.japanese: '完了',
      },
      'cancel': {
        AppLanguage.english: 'Cancel',
        AppLanguage.korean: '취소',
        AppLanguage.japanese: 'キャンセル',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  void _analyzeReceipt(BuildContext context) {
    Navigator.pop(context, true);
  }
}
