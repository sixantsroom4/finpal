import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class SubscriptionCategoryConstants {
  static final Map<String, Map<AppLanguage, String>> categories = {
    'OTT': {
      AppLanguage.english: 'OTT',
      AppLanguage.korean: 'OTT',
      AppLanguage.japanese: 'OTT',
    },
    'MUSIC': {
      AppLanguage.english: 'Music',
      AppLanguage.korean: '음악',
      AppLanguage.japanese: '音楽',
    },
    'GAME': {
      AppLanguage.english: 'Game',
      AppLanguage.korean: '게임',
      AppLanguage.japanese: 'ゲーム',
    },
    'FITNESS': {
      AppLanguage.english: 'Fitness',
      AppLanguage.korean: '피트니스',
      AppLanguage.japanese: 'フィットネス',
    },
    'PRODUCTIVITY': {
      AppLanguage.english: 'Productivity',
      AppLanguage.korean: '생산성',
      AppLanguage.japanese: '生産性',
    },
    'SOFTWARE': {
      AppLanguage.english: 'Software',
      AppLanguage.korean: '소프트웨어',
      AppLanguage.japanese: 'ソフトウェア',
    },
    'PET_CARE': {
      AppLanguage.english: 'Pet Care',
      AppLanguage.korean: '반려동물 관리',
      AppLanguage.japanese: 'ペットケア',
    },
    'BEAUTY': {
      AppLanguage.english: 'Beauty',
      AppLanguage.korean: '뷰티',
      AppLanguage.japanese: '美容',
    },
    'CAR_SERVICES': {
      AppLanguage.english: 'Car Services',
      AppLanguage.korean: '자동차 서비스',
      AppLanguage.japanese: '車サービス',
    },
    'STREAMING': {
      AppLanguage.english: 'Streaming Services',
      AppLanguage.korean: '스트리밍 서비스',
      AppLanguage.japanese: 'ストリーミングサービス',
    },
    'RENT': {
      AppLanguage.english: 'Rent',
      AppLanguage.korean: '월세',
      AppLanguage.japanese: '家賃',
    },
    'DELIVERY': {
      AppLanguage.english: 'Delivery Services',
      AppLanguage.korean: '배송 서비스',
      AppLanguage.japanese: '配送サービス',
    },
    'PREMIUM': {
      AppLanguage.english: 'Premium Memberships',
      AppLanguage.korean: '프리미엄 멤버십',
      AppLanguage.japanese: 'プレミアム会員',
    },
    'OTHER': {
      AppLanguage.english: 'Other',
      AppLanguage.korean: '기타',
      AppLanguage.japanese: 'その他',
    },
  };

  static final Map<String, IconData> categoryIcons = {
    'OTT': Icons.movie_outlined,
    'MUSIC': Icons.music_note_outlined,
    'GAME': Icons.games_outlined,
    'FITNESS': Icons.fitness_center_outlined,
    'PRODUCTIVITY': Icons.work_outlined,
    'SOFTWARE': Icons.computer_outlined,
    'PET_CARE': Icons.pets_outlined,
    'BEAUTY': Icons.face_outlined,
    'CAR_SERVICES': Icons.directions_car_outlined,
    'STREAMING': Icons.play_circle_outline,
    'RENT': Icons.home_outlined,
    'DELIVERY': Icons.local_shipping_outlined,
    'PREMIUM': Icons.star_outline,
    'OTHER': Icons.category_outlined,
  };

  static String getLocalizedCategory(BuildContext context, String category) {
    final language = context.read<AppLanguageBloc>().state.language;
    return categories[category.toUpperCase()]?[language] ??
        categories[category.toUpperCase()]?[AppLanguage.korean] ??
        category;
  }
}
