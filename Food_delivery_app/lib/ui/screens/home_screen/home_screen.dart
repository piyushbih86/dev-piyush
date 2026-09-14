import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/route_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/constants/tracking_strings.dart';
import 'package:khaanado/controller/toaster_controller.dart';
import 'package:khaanado/model/food_item.dart';
import 'package:khaanado/model/quest.dart';
import 'package:khaanado/service_locator.dart';
import 'package:khaanado/services/app_logger.dart';
import 'package:khaanado/ui/custom_widgets/diet_filter_chips.dart';
import 'package:khaanado/ui/custom_widgets/daily_reset_ticker.dart';
import 'package:khaanado/ui/custom_widgets/delivery_map.dart';
import 'package:khaanado/ui/custom_widgets/empty_state.dart';
import 'package:khaanado/ui/custom_widgets/food_card.dart';
import 'package:khaanado/ui/custom_widgets/food_image.dart';
import 'package:khaanado/ui/custom_widgets/free_delivery_meter.dart';
import 'package:khaanado/ui/custom_widgets/motion.dart';
import 'package:khaanado/ui/custom_widgets/offer_carousel.dart';
import 'package:khaanado/ui/custom_widgets/quest_tile.dart';
import 'package:khaanado/ui/popups/app_popups.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    catalogController.addListener(_refresh);
    loyaltyController.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) => _surface());
  }

  @override
  void dispose() {
    catalogController.removeListener(_refresh);
    loyaltyController.removeListener(_refresh);
    super.dispose();
  }

  bool _refreshQueued = false;

  void _refresh() {
    if (_refreshQueued || !mounted) return;
    _refreshQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshQueued = false;
      if (mounted) setState(() {});
    });
  }

  Future<void> _surface() async {
    homeSurfacing.onHomeReady();
    if (!homeSurfacing.shouldShowFtue || !mounted) return;
    await FtuePopup.show(
      context,
      onDone: () => homeSurfacing.markFtueSeen(),
    );
  }

  void _openDetail(FoodItem item) {
    AppTracker.track(TrackingStrings.itemOpen, {'id': item.id});
    Navigator.pushNamed(context, RouteConstants.detail, arguments: item);
  }

  Future<void> _add(FoodItem item) async {
    await cartController.add(item);
    appNotifiers.cartCount.value = cartController.itemCount;
    if (!mounted) return;
    toasterController.show(
      context,
      '${item.name} · ${StringConstants.addedToCart}',
      kind: ToasterKind.success,
    );
  }

  Future<void> _claim(QuestProgress quest) async {
    final ok = loyaltyController.claim(quest.definition.id);
    if (!ok || !mounted) return;
    HapticFeedback.mediumImpact();
    toasterController.show(
      context,
      '+${quest.definition.reward} ${StringConstants.coins}',
      kind: ToasterKind.success,
    );
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  List<FoodItem> get _popular {
    return catalogController.filterDiet(
      catalogController.popular,
      loyaltyController.dietFilter,
    );
  }

  List<FoodItem> get _recommended {
    return catalogController.filterDiet(
      catalogController.chefsTable,
      loyaltyController.dietFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = catalogController;
    if (catalog.loading && !catalog.loaded) {
      return const _HomeSkeleton();
    }

    return RefreshIndicator(
      color: ColorConstants.gold,
      onRefresh: () => catalog.load(force: true),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: FadeSlideIn(child: _Header(greeting: _greeting)),
            ),
          ),
          SliverToBoxAdapter(
            child: ListenableBuilder(
              listenable: orderController,
              builder: (context, _) {
                final live = orderController.liveOrder;
                if (live == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: DeliveryMapCard(
                    order: live,
                    height: 168,
                    compact: true,
                    onTap: () => Navigator.pushNamed(
                      context,
                      RouteConstants.tracking,
                      arguments: live.id,
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, RouteConstants.search),
                  child: const _SearchPill(),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: DietFilterChips(
              value: loyaltyController.dietFilter,
              onChanged: loyaltyController.setDietFilter,
            ),
          ),
          SliverToBoxAdapter(
            child: FadeSlideIn(
              delay: const Duration(milliseconds: 100),
              child: OfferCarousel(
                offers: BannerCatalog.offers,
                onTap: (offer) {
                  if (offer.code == 'QUESTS') {
                    appNotifiers.selectedTab.value = ShellTabs.quests;
                    return;
                  }
                  toasterController.show(
                    context,
                    'Use ${offer.code} on your bag',
                    kind: ToasterKind.info,
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: StringConstants.categories,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 108,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: catalog.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = catalog.categories[index];
                  return PressableScale(
                    onTap: () {
                      AppTracker.track(
                        TrackingStrings.categoryOpen,
                        {'id': category.id},
                      );
                      Navigator.pushNamed(
                        context,
                        RouteConstants.catalog,
                        arguments: category.id,
                      );
                    },
                    child: SizedBox(
                      width: 76,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ColorConstants.cardBorder,
                              ),
                            ),
                            child: FoodImage(
                              imagePath: category.image,
                              name: category.name,
                              size: 62,
                              circular: true,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, height: 1.1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: StringConstants.dailyQuests,
              action: StringConstants.seeAll,
              belowTitle: const DailyResetTicker(),
              onAction: () => appNotifiers.selectedTab.value = ShellTabs.quests,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: QuestTile.compactHeight,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: loyaltyController.dailyQuests.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final quest = loyaltyController.dailyQuests[index];
                  return QuestTile(
                    quest: quest,
                    compact: true,
                    celebrate: loyaltyController.lastClaimedId ==
                        quest.definition.id,
                    onClaim: () => _claim(quest),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SectionHeader(title: StringConstants.collections),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 148,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: BannerCatalog.collections.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final collection = BannerCatalog.collections[index];
                  final imageItem = catalog.items.firstWhere(
                    (item) {
                      final hint = collection.imageNameHint;
                      return item.id.contains(hint) ||
                          item.categoryId == hint ||
                          item.name.toLowerCase().contains(hint);
                    },
                    orElse: () => catalog.items.first,
                  );
                  return PressableScale(
                    onTap: () {
                      AppTracker.track(
                        TrackingStrings.collectionOpen,
                        {'id': collection.id},
                      );
                      Navigator.pushNamed(
                        context,
                        RouteConstants.catalog,
                        arguments: collection.id,
                      );
                    },
                    child: SizedBox(
                      width: 220,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            FoodImage(
                              imagePath: imageItem.image,
                              name: imageItem.name,
                              expand: true,
                            ),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x330B0A09),
                                    Color(0xEE0B0A09),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Spacer(),
                                  Text(
                                    collection.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    collection.subtitle,
                                    style: TextStyle(
                                      color: ColorConstants.cream,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListenableBuilder(
              listenable: cartController,
              builder: (context, _) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: FreeDeliveryMeter(
                    subtotal: cartController.subtotal,
                    promoCode: cartController.promoCode,
                  ),
                );
              },
            ),
          ),
          if (_recommended.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: SectionHeader(
                title: StringConstants.recommended,
                action: StringConstants.seeAll,
                onAction: () => Navigator.pushNamed(
                  context,
                  RouteConstants.catalog,
                  arguments: 'chefs',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 248,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _recommended.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = _recommended[index];
                    return SizedBox(
                      width: 160,
                      child: FoodCard(
                        item: item,
                        isFavorite: loyaltyController.isFavorite(item.id),
                        onFavorite: () =>
                            loyaltyController.toggleFavorite(item.id),
                        onAdd: () => _add(item),
                        onTap: () => _openDetail(item),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(
            child: SectionHeader(title: StringConstants.popularNearYou),
          ),
          if (_popular.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 88),
                child: EmptyState(
                  icon: Icons.restaurant_outlined,
                  title: StringConstants.noResults,
                  body: '',
                ),
              ),
            )
          else
            SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _popular[index];
                  return FoodCard(
                    item: item,
                    isFavorite: loyaltyController.isFavorite(item.id),
                    onFavorite: () => loyaltyController.toggleFavorite(item.id),
                    onAdd: () => _add(item),
                    onTap: () => _openDetail(item),
                  );
                },
                childCount: _popular.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    final address = orderController.address;
    final locality = address.isComplete
        ? address.city
        : AppConstants.defaultLocality;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: ColorConstants.accent,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${AppConstants.defaultCity} · $locality',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ColorConstants.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$greeting, ${authController.displayName}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => appNotifiers.selectedTab.value = ShellTabs.quests,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: ColorConstants.accentSoft,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: ColorConstants.accent.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.card_giftcard_rounded,
                  size: 16,
                  color: ColorConstants.accent,
                ),
                const SizedBox(width: 6),
                Text(
                  '${loyaltyController.coins}',
                  style: const TextStyle(
                    color: ColorConstants.accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ColorConstants.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: ColorConstants.cardBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: ColorConstants.textSecondary),
          const SizedBox(width: 12),
          Text(
            StringConstants.searchHint,
            style: TextStyle(color: ColorConstants.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ShimmerBox(height: 22, width: 180),
        SizedBox(height: 10),
        ShimmerBox(height: 52, radius: 26),
        SizedBox(height: 16),
        ShimmerBox(height: 128, radius: 18),
        SizedBox(height: 18),
        ShimmerBox(height: 18, width: 140),
        SizedBox(height: 12),
        Row(
          children: [
            ShimmerBox(height: 72, width: 72, radius: 36),
            SizedBox(width: 12),
            ShimmerBox(height: 72, width: 72, radius: 36),
            SizedBox(width: 12),
            ShimmerBox(height: 72, width: 72, radius: 36),
          ],
        ),
      ],
    );
  }
}
