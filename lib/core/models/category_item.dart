import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';

class CategoryItem {
  static String getLocalizedCategory(BuildContext context, String category) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> categories = {
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
    return categories[category.toUpperCase()]?[language] ??
        categories[category.toUpperCase()]?[AppLanguage.korean] ??
        category;
  }

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'ott':
        return Icons.movie_outlined;
      case 'music':
        return Icons.music_note_outlined;
      case 'game':
        return Icons.games_outlined;
      case 'fitness':
        return Icons.fitness_center_outlined;
      case 'productivity':
        return Icons.work_outlined;
      case 'software':
        return Icons.computer_outlined;
      case 'pet_care':
        return Icons.pets_outlined;
      case 'beauty':
        return Icons.face_outlined;
      case 'car_services':
        return Icons.directions_car_outlined;
      case 'streaming':
        return Icons.play_circle_outline;
      case 'rent':
        return Icons.home_outlined;
      case 'delivery':
        return Icons.local_shipping_outlined;
      case 'premium':
        return Icons.star_outline;
      default:
        return Icons.category_outlined;
    }
  }
}
