// lib/presentation/pages/settings/widgets/edit_profile_bottom_sheet.dart
import 'package:finpal/presentation/bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_event.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../domain/entities/user.dart';
import '../../../bloc/auth/auth_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'dart:async';

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
  String? _selectedImagePath;
  bool _isLoading = false;
  bool _isSaving = false;

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

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false && !_isSaving) {
      setState(() => _isSaving = true);

      try {
        context.read<AuthBloc>().add(
              UpdateUserProfile(
                displayName: _displayNameController.text.trim(),
                imagePath: _selectedImagePath,
              ),
            );
      } catch (e) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getLocalizedError(context, e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated && state.error == null) {
          Navigator.pop(context);
          Phoenix.rebirth(context);
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 드래그 핸들
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // 제목
                  Text(
                    _getLocalizedLabel(context, 'edit_profile'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 프로필 이미지
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2C3E50).withOpacity(0.05),
                            border: Border.all(
                              color: const Color(0xFF2C3E50).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: _selectedImagePath != null
                                ? Image.file(
                                    File(_selectedImagePath!),
                                    fit: BoxFit.cover,
                                  )
                                : widget.user.photoUrl != null
                                    ? Image.network(
                                        widget.user.photoUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : Center(
                                        child: Text(
                                          widget.user.displayName[0]
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2C3E50),
                                          ),
                                        ),
                                      ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C3E50),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: InkWell(
                              onTap: _pickImage,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 이름 입력 필드
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C3E50).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLocalizedLabel(context, 'display_name'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        TextFormField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          validator: (value) => value?.isEmpty ?? true
                              ? _getLocalizedLabel(context, 'name_required')
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 저장 버튼
                  TextButton(
                    onPressed: _isSaving ? null : _updateProfile,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF2C3E50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _getLocalizedLabel(context, 'save'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'edit_profile': {
        AppLanguage.english: 'Edit Profile',
        AppLanguage.korean: '프로필 수정',
        AppLanguage.japanese: 'プロフィール編集',
      },
      'display_name': {
        AppLanguage.english: 'Display Name',
        AppLanguage.korean: '표시 이름',
        AppLanguage.japanese: '表示名',
      },
      'name_required': {
        AppLanguage.english: 'Name is required',
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

  String _getLocalizedError(BuildContext context, String error) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<AppLanguage, String> errorMessages = {
      AppLanguage.english: 'Failed to update profile',
      AppLanguage.korean: '프로필 업데이트에 실패했습니다',
      AppLanguage.japanese: 'プロフィールの更新に失敗しました',
    };
    return errorMessages[language] ?? errorMessages[AppLanguage.korean]!;
  }
}
