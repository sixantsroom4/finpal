// lib/presentation/pages/settings/widgets/edit_profile_bottom_sheet.dart
import 'package:finpal/presentation/bloc/auth/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/user.dart';
import '../../../bloc/auth/auth_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class EditProfileBottomSheet extends StatefulWidget {
  final User user;

  const EditProfileBottomSheet({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  final _imagePicker = ImagePicker();
  String? _newPhotoUrl;

  @override
  void initState() {
    super.initState();
    _displayNameController =
        TextEditingController(text: widget.user.displayName);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getLocalizedLabel(context, 'edit_profile'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 프로필 이미지
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _newPhotoUrl != null
                        ? NetworkImage(_newPhotoUrl!)
                        : widget.user.photoUrl != null
                            ? NetworkImage(widget.user.photoUrl!)
                            : null,
                    child: (_newPhotoUrl ?? widget.user.photoUrl) == null
                        ? Text(
                            widget.user.displayName[0].toUpperCase(),
                            style: const TextStyle(fontSize: 32),
                          )
                        : null,
                  ),
                  Positioned(
                    right: -12,
                    bottom: -12,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: _pickImage,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 이름 입력 필드
            TextFormField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: _getLocalizedLabel(context, 'name'),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return _getLocalizedLabel(context, 'name_required');
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 저장 버튼
            ElevatedButton(
              onPressed: _submit,
              child: Text(_getLocalizedLabel(context, 'save')),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      // TODO: 이미지 업로드 및 URL 받아오기
      setState(() {
        _newPhotoUrl = 'uploaded_image_url';
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final displayName = _displayNameController.text.trim();

      // 변경사항이 있는 경우에만 업데이트
      if (displayName != widget.user.displayName || _newPhotoUrl != null) {
        context.read<AuthBloc>().add(
              AuthProfileUpdateRequested(
                displayName: displayName,
                photoUrl: _newPhotoUrl,
              ),
            );
      }

      Navigator.pop(context);
    }
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'edit_profile': {
        AppLanguage.english: 'Edit Profile',
        AppLanguage.korean: '프로필 수정',
        AppLanguage.japanese: 'プロフィール編集',
      },
      'name': {
        AppLanguage.english: 'Name',
        AppLanguage.korean: '이름',
        AppLanguage.japanese: '名前',
      },
      'name_required': {
        AppLanguage.english: 'Please enter your name',
        AppLanguage.korean: '이름을 입력해주세요',
        AppLanguage.japanese: '名前を入力してください',
      },
      'save': {
        AppLanguage.english: 'Save',
        AppLanguage.korean: '저장',
        AppLanguage.japanese: '保存',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }
}
