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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 4),
              // 로고 및 앱 이름
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'FinPal',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 74,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '똑똑한 가계부의 시작',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),

              // 소셜 로그인 버튼들
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _SocialSignInButton(
                      onPressed: () {
                        context
                            .read<AuthBloc>()
                            .add(AuthGoogleSignInRequested());
                      },
                      icon: 'assets/icons/google.svg',
                      label: 'Google로 계속하기',
                    ),
                    if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                      const SizedBox(height: 16),
                      _SocialSignInButton(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(AuthAppleSignInRequested());
                        },
                        icon: 'assets/icons/apple.svg',
                        label: 'Apple로 계속하기',
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(flex: 5),
            ],
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
