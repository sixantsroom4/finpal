import 'package:flutter/material.dart';

class SubscriptionService {
  final String id;
  final String name;
  final String logoUrl;
  final Color primaryColor;
  final String category;

  const SubscriptionService({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.primaryColor,
    required this.category,
  });
}

class SubscriptionContents {
  static final List<SubscriptionService> services = [
    SubscriptionService(
      id: 'netflix',
      name: 'Netflix',
      logoUrl: 'assets/sub_icon/netflix.png',
      primaryColor: const Color(0xFFE50914),
      category: 'OTT',
    ),
    SubscriptionService(
      id: 'amazon_prime',
      name: 'Amazon Prime',
      logoUrl: 'assets/sub_icon/amzon_prime.png',
      primaryColor: const Color(0xFF00A8E1),
      category: 'OTT',
    ),
    SubscriptionService(
      id: 'apple_music',
      name: 'Apple Music',
      logoUrl: 'assets/sub_icon/apple_music.png',
      primaryColor: const Color(0xFFFA243C),
      category: 'Music',
    ),
    SubscriptionService(
      id: 'youtube_premium',
      name: 'YouTube Premium',
      logoUrl: 'assets/sub_icon/youtube.png',
      primaryColor: const Color(0xFFFF0000),
      category: 'OTT',
    ),
    SubscriptionService(
      id: 'youtube_music',
      name: 'YouTube Music',
      logoUrl: 'assets/sub_icon/YouTube Music.png',
      primaryColor: const Color(0xFFFF0000),
      category: 'Music',
    ),
    SubscriptionService(
      id: 'cursor_pro',
      name: 'Cursor Pro',
      logoUrl: 'assets/sub_icon/Cursor.jpeg',
      primaryColor: const Color(0xFF000000),
      category: 'Development',
    ),
    SubscriptionService(
      id: 'lg_uplus',
      name: 'LG U+ 유독',
      logoUrl: 'assets/sub_icon/lg.png',
      primaryColor: const Color(0xFFE6007E),
      category: 'OTT',
    ),
    SubscriptionService(
      id: 'skt_universe',
      name: 'SKT 우주패스',
      logoUrl: 'assets/sub_icon/skt.png',
      primaryColor: const Color(0xFFEA1C48),
      category: 'OTT',
    ),
    SubscriptionService(
      id: 'naver_plus',
      name: '네이버플러스',
      logoUrl: 'assets/sub_icon/naver.png',
      primaryColor: const Color(0xFF03C75A),
      category: 'OTT',
    ),
    SubscriptionService(
      id: 'spotify',
      name: 'Spotify Premium',
      logoUrl: 'assets/sub_icon/Spotify.png',
      primaryColor: const Color(0xFF1DB954),
      category: 'OTT',
    ),
    SubscriptionService(
      id: 'chatgpt',
      name: 'ChatGPT',
      logoUrl: 'assets/sub_icon/ChatGPT.png',
      primaryColor: const Color(0xFF10A37F),
      category: 'AI',
    ),
    SubscriptionService(
      id: 'claude',
      name: 'Claude',
      logoUrl: 'assets/sub_icon/claude.png',
      primaryColor: const Color(0xFF7C3AED),
      category: 'AI',
    ),
    SubscriptionService(
      id: 'disney_plus',
      name: 'Disney Plus',
      logoUrl: 'assets/sub_icon/disney plus.jpeg',
      primaryColor: const Color(0xFF113CCF),
      category: 'OTT',
    ),
    SubscriptionService(
      id: 'hulu',
      name: 'Hulu',
      logoUrl: 'assets/sub_icon/hulu.png',
      primaryColor: const Color(0xFF1CE783),
      category: 'OTT',
    ),
    SubscriptionService(
      id: 'watcha',
      name: 'Watcha',
      logoUrl: 'assets/sub_icon/watcha.png',
      primaryColor: const Color(0xFFFF0558),
      category: 'OTT',
    ),
    SubscriptionService(
      id: 'coupang',
      name: 'Coupang WOW',
      logoUrl: 'assets/sub_icon/coopang.png',
      primaryColor: const Color(0xFF5B32FF),
      category: 'Shopping',
    ),
    SubscriptionService(
      id: 'house_loan',
      name: '주택담보대출',
      logoUrl: 'assets/sub_icon/house.png',
      primaryColor: const Color(0xFF4A90E2),
      category: 'Finance',
    ),
  ];

  static SubscriptionService? getServiceById(String id) {
    try {
      return services.firstWhere((service) => service.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<SubscriptionService> search(String query) {
    query = query.toLowerCase();
    return services
        .where((service) => service.name.toLowerCase().contains(query))
        .toList();
  }
}
