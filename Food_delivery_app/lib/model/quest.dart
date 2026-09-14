import 'package:flutter/material.dart';

enum QuestKind { daily, story }

class QuestDefinition {
  const QuestDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.target,
    required this.reward,
    required this.kind,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final int target;
  final int reward;
  final QuestKind kind;
  final IconData icon;

  bool get isDaily => kind == QuestKind.daily;
}

class QuestProgress {
  const QuestProgress({
    required this.definition,
    required this.progress,
    required this.claimed,
  });

  final QuestDefinition definition;
  final int progress;
  final bool claimed;

  bool get complete => progress >= definition.target;
  bool get canClaim => complete && !claimed;
  int get displayProgress =>
      claimed ? definition.target : progress.clamp(0, definition.target);
  double get fraction =>
      (displayProgress / definition.target).clamp(0, 1).toDouble();
}

class QuestCatalog {
  QuestCatalog._();

  static const firstBite = 'first_bite';
  static const sweetTooth = 'sweet_tooth';
  static const couponHunter = 'coupon_hunter';
  static const feastMode = 'feast_mode';
  static const loyalDiner = 'loyal_diner';
  static const collector = 'collector';

  static const all = <QuestDefinition>[
    QuestDefinition(
      id: firstBite,
      title: 'First bite',
      subtitle: 'Place your first order',
      target: 1,
      reward: 80,
      kind: QuestKind.story,
      icon: Icons.restaurant_rounded,
    ),
    QuestDefinition(
      id: sweetTooth,
      title: 'Sweet tooth',
      subtitle: 'Add a dessert',
      target: 1,
      reward: 25,
      kind: QuestKind.daily,
      icon: Icons.cake_outlined,
    ),
    QuestDefinition(
      id: couponHunter,
      title: 'Coupon hunter',
      subtitle: 'Apply a promo',
      target: 1,
      reward: 30,
      kind: QuestKind.daily,
      icon: Icons.local_offer_outlined,
    ),
    QuestDefinition(
      id: feastMode,
      title: 'Feast mode',
      subtitle: 'Add 3 dishes',
      target: 3,
      reward: 25,
      kind: QuestKind.daily,
      icon: Icons.dinner_dining,
    ),
    QuestDefinition(
      id: loyalDiner,
      title: 'Loyal diner',
      subtitle: 'Complete 2 orders',
      target: 2,
      reward: 120,
      kind: QuestKind.story,
      icon: Icons.verified_outlined,
    ),
    QuestDefinition(
      id: collector,
      title: 'Table for favourites',
      subtitle: 'Heart 2 dishes you love',
      target: 2,
      reward: 20,
      kind: QuestKind.story,
      icon: Icons.favorite_outline,
    ),
  ];

  static QuestDefinition? byId(String id) {
    for (final quest in all) {
      if (quest.id == id) return quest;
    }
    return null;
  }
}

class OfferBanner {
  const OfferBanner({
    required this.title,
    required this.subtitle,
    required this.code,
    required this.start,
    required this.end,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String code;
  final Color start;
  final Color end;
  final IconData icon;
}

class FoodCollection {
  const FoodCollection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageNameHint,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageNameHint;
}

class BannerCatalog {
  BannerCatalog._();

  static const offers = <OfferBanner>[
    OfferBanner(
      title: '10% off the table',
      subtitle: 'Use KHAANA10 on any bag',
      code: 'KHAANA10',
      start: Color(0xFF4A1F14),
      end: Color(0xFFB03A2E),
      icon: Icons.local_offer_rounded,
    ),
    OfferBanner(
      title: 'Flat ₹50 tonight',
      subtitle: 'FIRST50 on orders over ₹199',
      code: 'FIRST50',
      start: Color(0xFF1A2418),
      end: Color(0xFF3D6B3A),
      icon: Icons.wallet_giftcard_rounded,
    ),
    OfferBanner(
      title: 'Earn Rewards',
      subtitle: 'Claim Gold on every bag',
      code: 'QUESTS',
      start: Color(0xFF2A2110),
      end: Color(0xFF8A6A12),
      icon: Icons.card_giftcard_rounded,
    ),
    OfferBanner(
      title: 'Free delivery',
      subtitle: 'On bags over ₹499',
      code: 'FREEDEL',
      start: Color(0xFF1A2030),
      end: Color(0xFF3D5A80),
      icon: Icons.delivery_dining_rounded,
    ),
  ];

  static const collections = <FoodCollection>[
    FoodCollection(
      id: 'chefs',
      title: "Chef's table",
      subtitle: 'Highest rated tonight',
      imageNameHint: 'biryani',
    ),
    FoodCollection(
      id: 'under150',
      title: 'Under ₹150',
      subtitle: 'Light, quick, perfect',
      imageNameHint: 'dosa',
    ),
    FoodCollection(
      id: 'midnight',
      title: 'Midnight cravings',
      subtitle: 'Dessert, pours & dum',
      imageNameHint: 'dessert',
    ),
  ];
}
