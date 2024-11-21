import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedWelcomeText extends StatefulWidget {
  const AnimatedWelcomeText({super.key});

  @override
  State<AnimatedWelcomeText> createState() => _AnimatedWelcomeTextState();
}

class _AnimatedWelcomeTextState extends State<AnimatedWelcomeText> {
  final List<WelcomeMessage> messages = [
    WelcomeMessage(text: 'Smart Financial Management', language: 'en'),
    WelcomeMessage(text: '똑똑한 AI 가계부', language: 'ko'),
    WelcomeMessage(text: 'スマートな家計簿の始まり', language: 'ja'),
  ];

  int currentIndex = 0;
  String currentText = '';
  Timer? _timer;
  Timer? _languageTimer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    String targetText = messages[currentIndex].text;
    int charIndex = 0;

    // 타이핑 애니메이션
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (charIndex <= targetText.length) {
        setState(() {
          currentText = targetText.substring(0, charIndex);
        });
        charIndex++;
      } else {
        timer.cancel();
        // 3초 후에 다음 언어로 전환
        _languageTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              currentIndex = (currentIndex + 1) % messages.length;
              currentText = '';
            });
            _startAnimation();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _languageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      currentText,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
      textAlign: TextAlign.center,
    );
  }
}

class WelcomeMessage {
  final String text;
  final String language;

  WelcomeMessage({required this.text, required this.language});
}
