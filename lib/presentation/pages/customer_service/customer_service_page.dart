import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/core/services/injection_container.dart';
import 'package:finpal/presentation/bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/customer_service/customer_service_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/customer_service/customer_service_bloc.dart';
import 'package:finpal/presentation/bloc/customer_service/customer_service_state.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CustomerServicePage extends StatelessWidget {
  const CustomerServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CustomerServiceBloc>(),
      child: const CustomerServiceView(),
    );
  }
}

class CustomerServiceView extends StatefulWidget {
  const CustomerServiceView({Key? key}) : super(key: key);

  @override
  State<CustomerServiceView> createState() => _CustomerServiceViewState();
}

class _CustomerServiceViewState extends State<CustomerServiceView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'general';
  final List<String> _imagePaths = [];
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();

  final List<String> _categories = [
    'general',
    'technical',
    'feature',
    'bug',
    'other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        title: Text(
          _getLocalizedLabel(context, 'customer_service'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<CustomerServiceBloc, CustomerServiceState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          if (state is CustomerServiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // 상단 안내 섹션
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFF2C3E50).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLocalizedLabel(context, 'inquiry_guide_title'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getLocalizedLabel(context, 'inquiry_guide'),
                        style: TextStyle(
                          color: const Color(0xFF2C3E50).withOpacity(0.6),
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                // 문의 폼
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategorySection(),
                        const SizedBox(height: 32),
                        _buildInquiryFormSection(),
                        const SizedBox(height: 32),
                        _buildImageAttachmentSection(),
                        const SizedBox(height: 32),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'customer_service': {
        AppLanguage.english: 'Customer Service',
        AppLanguage.korean: '고객 센터',
        AppLanguage.japanese: 'カスタマーサービス',
      },
      'inquiry_guide': {
        AppLanguage.english:
            'Please fill out the form below to submit your inquiry.',
        AppLanguage.korean: '아래 양식을 작성하여 문의해 주세요.',
        AppLanguage.japanese: '以下のフォームに記入しておい合わせください。',
      },
      'inquiry_category': {
        AppLanguage.english: 'Category',
        AppLanguage.korean: '문의 유형',
        AppLanguage.japanese: 'お問い合わせ種類',
      },
      'category_general': {
        AppLanguage.english: 'General Inquiry',
        AppLanguage.korean: '일반 문의',
        AppLanguage.japanese: '一般的なお問い合わせ',
      },
      'category_technical': {
        AppLanguage.english: 'Technical Issue',
        AppLanguage.korean: '기술적 문제',
        AppLanguage.japanese: '技術的な問題',
      },
      'category_feature': {
        AppLanguage.english: 'Feature Request',
        AppLanguage.korean: '기능 제안',
        AppLanguage.japanese: '機能リクエスト',
      },
      'category_bug': {
        AppLanguage.english: 'Bug Report',
        AppLanguage.korean: '버그 신고',
        AppLanguage.japanese: 'バグ報告',
      },
      'category_other': {
        AppLanguage.english: 'Other',
        AppLanguage.korean: '기타',
        AppLanguage.japanese: 'その他',
      },
      'inquiry_guide_title': {
        AppLanguage.english: 'How can we help you?',
        AppLanguage.korean: '무엇을 도와드릴까요?',
        AppLanguage.japanese: 'どのようにお手伝いできますか？',
      },
      'inquiry_title_hint': {
        AppLanguage.english: 'Enter the title of your inquiry',
        AppLanguage.korean: '문의 제목을 입력해주세요',
        AppLanguage.japanese: 'お問い合わせのタイトルを入力してください',
      },
      'inquiry_content_hint': {
        AppLanguage.english: 'Please describe your inquiry in detail',
        AppLanguage.korean: '문의 내용을 자세히 적어주세요',
        AppLanguage.japanese: 'お問い合わせ内容を詳しく記入してください',
      },
      'title_required': {
        AppLanguage.english: 'Please enter a title',
        AppLanguage.korean: '제목을 입력해주세요',
        AppLanguage.japanese: 'タイトルを入力してください',
      },
      'content_required': {
        AppLanguage.english: 'Please enter content',
        AppLanguage.korean: '내용을 입력해주세요',
        AppLanguage.japanese: '内容を入力してください',
      },
      'attach_images': {
        AppLanguage.english: 'Attach Images (Optional)',
        AppLanguage.korean: '이미지 첨부 (선택사항)',
        AppLanguage.japanese: '画像添付 (任意)',
      },
      'submit': {
        AppLanguage.english: 'Submit Inquiry',
        AppLanguage.korean: '문의하기',
        AppLanguage.japanese: '送信する',
      },
      'inquiry_sent': {
        AppLanguage.english: 'Your inquiry has been sent successfully',
        AppLanguage.korean: '문의가 성공적으로 전송되었습니다',
        AppLanguage.japanese: 'お問い合わせが正常に送信されました',
      },
      'contact_email': {
        AppLanguage.english: 'Contact Email',
        AppLanguage.korean: '연락처 이메일',
        AppLanguage.japanese: '連絡先のメールアドレス',
      },
      'contact_email_hint': {
        AppLanguage.english: 'Enter your contact email',
        AppLanguage.korean: '연락처 이메일을 입력해주세요',
        AppLanguage.japanese: '連絡先のメールアドレスを入力してください',
      },
      'confirm_email': {
        AppLanguage.english: 'Confirm Email',
        AppLanguage.korean: '이메일 확인',
        AppLanguage.japanese: 'メールアドレスを確認する',
      },
      'confirm_email_hint': {
        AppLanguage.english: 'Enter the same email as above',
        AppLanguage.korean: '위와 같은 이메일을 입력해주세요',
        AppLanguage.japanese: '上と同じメールアドレスを入力してください',
      },
      'email_required': {
        AppLanguage.english: 'Please enter an email',
        AppLanguage.korean: '이메일을 입력해주세요',
        AppLanguage.japanese: 'メールアドレスを入力してください',
      },
      'invalid_email': {
        AppLanguage.english: 'Please enter a valid email',
        AppLanguage.korean: '올바른 이메일을 입력해주세요',
        AppLanguage.japanese: '正しいメールアドレスを入力してください',
      },
      'email_mismatch': {
        AppLanguage.english: 'Emails do not match',
        AppLanguage.korean: '이메일이 일치하지 않습니다',
        AppLanguage.japanese: 'メールアドレスが一致しません',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getLocalizedLabel(context, 'inquiry_category'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories
              .map((category) => _buildCategoryChip(category))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(_getLocalizedLabel(context, 'category_$category')),
      selected: isSelected,
      onSelected: (selected) => setState(() => _selectedCategory = category),
      selectedColor: const Color(0xFF2C3E50),
      backgroundColor: const Color(0xFF2C3E50).withOpacity(0.05),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF2C3E50),
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildInquiryFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _titleController,
          label: _getLocalizedLabel(context, 'title'),
          hint: _getLocalizedLabel(context, 'inquiry_title_hint'),
          validator: (value) => value?.isEmpty ?? true
              ? _getLocalizedLabel(context, 'title_required')
              : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _contentController,
          label: _getLocalizedLabel(context, 'content'),
          hint: _getLocalizedLabel(context, 'inquiry_content_hint'),
          maxLines: 8,
          validator: (value) => value?.isEmpty ?? true
              ? _getLocalizedLabel(context, 'content_required')
              : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: _getLocalizedLabel(context, 'contact_email'),
          hint: _getLocalizedLabel(context, 'contact_email_hint'),
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmEmailController,
          label: _getLocalizedLabel(context, 'confirm_email'),
          hint: _getLocalizedLabel(context, 'confirm_email_hint'),
          keyboardType: TextInputType.emailAddress,
          validator: _validateConfirmEmail,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines ?? 1,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return _getLocalizedLabel(context, 'email_required');
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return _getLocalizedLabel(context, 'invalid_email');
    }
    return null;
  }

  String? _validateConfirmEmail(String? value) {
    if (value == null || value.isEmpty) {
      return _getLocalizedLabel(context, 'email_required');
    }
    if (value != _emailController.text) {
      return _getLocalizedLabel(context, 'email_mismatch');
    }
    return null;
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _submitInquiry,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C3E50),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          _getLocalizedLabel(context, 'submit'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, CustomerServiceState state) {
    if (state is CustomerServiceSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLocalizedLabel(context, 'inquiry_sent')),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
    } else if (state is CustomerServiceError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildImageAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getLocalizedLabel(context, 'attach_images'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._imagePaths
                .asMap()
                .entries
                .map((e) => _buildImagePreview(e.key)),
            if (_imagePaths.length < 4) _buildAddImageButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview(int index) {
    return Stack(
      children: [
        Image.file(
          File(_imagePaths[index]),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => setState(() => _imagePaths.removeAt(index)),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.add_photo_alternate, color: Colors.grey),
      ),
    );
  }

  void _submitInquiry() {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<CustomerServiceBloc>().add(
              SubmitInquiry(
                userId: authState.user.id,
                title: _titleController.text,
                category: _selectedCategory,
                content: _contentController.text,
                contactEmail: _emailController.text,
                imagePaths: _imagePaths,
              ),
            );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePaths.add(pickedFile.path);
      });
    }
  }
}
