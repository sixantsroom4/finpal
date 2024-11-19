// lib/presentation/pages/auth/welcome_page.dart
import 'package:finpal/presentation/bloc/auth/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'email_signup_page.dart';
import 'package:finpal/presentation/pages/auth/email_signin_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // 로고 및 앱 이름
                Center(
                  child: Column(
                    children: [
                      Text(
                        'FinPal',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '똑똑한 가계부의 시작',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // 소셜 로그인 버튼들
                _SocialSignInButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthGoogleSignInRequested());
                  },
                  icon: 'assets/icons/google.svg',
                  label: 'Google로 계속하기',
                ),
                if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                  const SizedBox(height: 16),
                  _SocialSignInButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthAppleSignInRequested());
                    },
                    icon: 'assets/icons/apple.svg',
                    label: 'Apple로 계속하기',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  ),
                ],
                const SizedBox(height: 24),

                // 구분선
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '또는',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // 이메일 회원가입 버튼
                OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmailSignupPage(),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('이메일로 계정 만들기'),
                ),
                const SizedBox(height: 16),

                // 기존 계정 로그인
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '이미 계정이 있으신가요?',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmailSignInPage(),
                        ),
                      ),
                      child: const Text('로그인'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String icon;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const _SocialSignInButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.white,
        foregroundColor: textColor ?? Colors.black87,
        minimumSize: const Size(double.infinity, 50),
        side: backgroundColor == null
            ? BorderSide(color: Colors.grey[300]!)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
