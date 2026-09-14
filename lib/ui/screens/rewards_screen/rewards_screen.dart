import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/route_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/controller/toaster_controller.dart';
import 'package:khaanado/model/quest.dart';
import 'package:khaanado/service_locator.dart';
import 'package:khaanado/ui/custom_widgets/daily_reset_ticker.dart';
import 'package:khaanado/ui/custom_widgets/food_card.dart';
import 'package:khaanado/ui/custom_widgets/motion.dart';
import 'package:khaanado/ui/custom_widgets/quest_tile.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  String? _celebrateId;

  @override
  void initState() {
    super.initState();
    loyaltyController.addListener(_refresh);
    catalogController.addListener(_refresh);
    appNotifiers.selectedTab.addListener(_onTab);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncCelebrate());
  }

  @override
  void dispose() {
    loyaltyController.removeListener(_refresh);
    catalogController.removeListener(_refresh);
    appNotifiers.selectedTab.removeListener(_onTab);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _onTab() {
    if (appNotifiers.selectedTab.value == ShellTabs.quests) {
      _syncCelebrate();
    }
  }

  void _syncCelebrate() {
    final id = loyaltyController.lastClaimedId;
    if (id == null || !mounted) return;
    if (appNotifiers.selectedTab.value != ShellTabs.quests) return;
    setState(() => _celebrateId = id);
  }

  Future<void> _claim(QuestProgress quest) async {
    final ok = loyaltyController.claim(quest.definition.id);
    if (!ok || !mounted) return;
    HapticFeedback.mediumImpact();
    setState(() => _celebrateId = quest.definition.id);
    toasterController.show(
      context,
      '+${quest.definition.reward} ${StringConstants.coins}',
      kind: ToasterKind.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loyalty = loyaltyController;
    final favs = catalogController.favoritesOf(loyalty.favorites);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      children: [
        FadeSlideIn(
          child: Text(
            StringConstants.rewardsTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: ColorConstants.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          StringConstants.earnCoins,
          style: TextStyle(color: ColorConstants.textSecondary),
        ),
        const SizedBox(height: 16),
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: ColorConstants.card,
              border: Border.all(color: ColorConstants.cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loyalty.isGold
                            ? StringConstants.goldMember
                            : '${AppConstants.goldMemberCoins - loyalty.coins} to Gold',
                        style: const TextStyle(
                          color: ColorConstants.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${loyalty.coins}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: ColorConstants.textPrimary,
                        ),
                      ),
                      Text(
                        StringConstants.coins,
                        style: TextStyle(color: ColorConstants.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: ColorConstants.accent,
                      size: 28,
                    ),
                    Text(
                      '${loyalty.streak}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: ColorConstants.textPrimary,
                      ),
                    ),
                    Text(
                      StringConstants.streak,
                      style: TextStyle(
                        color: ColorConstants.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          StringConstants.dailyQuests,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ColorConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const DailyResetTicker(),
        const SizedBox(height: 10),
        ...loyalty.quests.map(
          (quest) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: QuestTile(
              quest: quest,
              celebrate: _celebrateId == quest.definition.id,
              onCelebrateDone: () {
                if (_celebrateId == quest.definition.id) {
                  loyaltyController.clearLastClaimed();
                  if (mounted) setState(() => _celebrateId = null);
                }
              },
              onClaim: () => _claim(quest),
            ),
          ),
        ),
        if (favs.isNotEmpty) ...[
          const SizedBox(height: 8),
          Sectionish(title: StringConstants.favorites),
          const SizedBox(height: 10),
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: favs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = favs[index];
                return SizedBox(
                  width: 160,
                  child: FoodCard(
                    item: item,
                    isFavorite: true,
                    onFavorite: () => loyalty.toggleFavorite(item.id),
                    onTap: () => Navigator.pushNamed(
                      context,
                      RouteConstants.detail,
                      arguments: item,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class Sectionish extends StatelessWidget {
  const Sectionish({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: ColorConstants.textPrimary,
      ),
    );
  }
}
