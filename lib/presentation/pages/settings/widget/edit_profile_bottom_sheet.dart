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
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _selectedImagePath != null
                          ? FileImage(File(_selectedImagePath!))
                          : widget.user.photoUrl != null
                              ? NetworkImage(widget.user.photoUrl!)
                              : null,
                      child: (_selectedImagePath == null &&
                              widget.user.photoUrl == null)
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
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: _getLocalizedLabel(context, 'display_name'),
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
              ElevatedButton(
                onPressed: _isSaving ? null : _updateProfile,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_getLocalizedLabel(context, 'save')),
              ),
            ],
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
