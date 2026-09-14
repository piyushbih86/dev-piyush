import 'package:flutter/foundation.dart';
import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/constants/tracking_strings.dart';
import 'package:khaanado/model/cart_line.dart';
import 'package:khaanado/model/diet_filter.dart';
import 'package:khaanado/model/order.dart';
import 'package:khaanado/model/quest.dart';
import 'package:khaanado/services/app_logger.dart';
import 'package:khaanado/services/local_storage.dart';

class LoyaltyController extends ChangeNotifier {
  LoyaltyController(this._storage);

  final LocalStorage _storage;

  int _coins = 0;
  int _streak = 0;
  int _ordersPlaced = 0;
  String? _lastOrderDay;
  String _questDay = '';
  final Set<String> _claimed = {};
  final Map<String, int> _progress = {};
  final Set<String> _favorites = {};
  DietFilter _dietFilter = DietFilter.all;
  String? _lastClaimedId;
  bool _hydrated = false;

  int get coins => _coins;
  int get streak => _streak;
  int get ordersPlaced => _ordersPlaced;
  DietFilter get dietFilter => _dietFilter;
  String? get lastClaimedId => _lastClaimedId;
  bool get isGold => _coins >= AppConstants.goldMemberCoins;
  Set<String> get favorites => Set.unmodifiable(_favorites);
  int get favoriteCount => _favorites.length;

  List<QuestProgress> get quests {
    return QuestCatalog.all
        .map(
          (definition) => QuestProgress(
            definition: definition,
            progress: _progress[definition.id] ?? 0,
            claimed: _claimed.contains(definition.id),
          ),
        )
        .toList(growable: false);
  }

  List<QuestProgress> get dailyQuests =>
      quests.where((quest) => quest.definition.isDaily).toList(growable: false);

  List<QuestProgress> get claimable =>
      quests.where((quest) => quest.canClaim).toList(growable: false);

  int get readyCount => claimable.length;

  bool isFavorite(String foodId) => _favorites.contains(foodId);

  void hydrate() {
    final snap = _storage.readLoyalty();
    _coins = snap.coins;
    _streak = snap.streak;
    _ordersPlaced = snap.ordersPlaced;
    _lastOrderDay = snap.lastOrderDay;
    _questDay = snap.questDay;
    _claimed
      ..clear()
      ..addAll(snap.claimed);
    _progress
      ..clear()
      ..addAll(snap.progress);
    _favorites
      ..clear()
      ..addAll(snap.favorites);
    _dietFilter = snap.dietFilter;
    _maybeResetDaily();
    _hydrated = true;
    notifyListeners();
  }

  Future<void> _persist() {
    return _storage.saveLoyalty(
      LoyaltySnapshot(
        coins: _coins,
        streak: _streak,
        ordersPlaced: _ordersPlaced,
        lastOrderDay: _lastOrderDay,
        questDay: _questDay,
        claimed: _claimed.toList(),
        progress: Map<String, int>.from(_progress),
        favorites: _favorites.toList(),
        dietFilter: _dietFilter,
      ),
    );
  }

  void _maybeResetDaily({DateTime? now}) {
    final today = _dayKey(now ?? DateTime.now());
    if (_questDay == today) return;
    _questDay = today;
    for (final quest in QuestCatalog.all) {
      if (!quest.isDaily) continue;
      _claimed.remove(quest.id);
      _progress.remove(quest.id);
    }
  }

  String _dayKey(DateTime time) =>
      '${time.year.toString().padLeft(4, '0')}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';

  DateTime dailyResetAt({DateTime? now}) {
    final current = now ?? DateTime.now();
    return DateTime(current.year, current.month, current.day + 1);
  }

  Duration timeUntilDailyReset({DateTime? now}) {
    final current = now ?? DateTime.now();
    return dailyResetAt(now: current).difference(current);
  }

  String dailyResetLabel({DateTime? now}) {
    final left = timeUntilDailyReset(now: now);
    if (left.isNegative || left.inSeconds < 30) return 'Resets soon';
    if (left.inHours >= 1) {
      final hours = left.inHours;
      final minutes = left.inMinutes.remainder(60);
      return minutes == 0
          ? 'Resets in ${hours}h'
          : 'Resets in ${hours}h ${minutes}m';
    }
    if (left.inMinutes >= 1) return 'Resets in ${left.inMinutes}m';
    return 'Resets in ${left.inSeconds}s';
  }

  String dailyResetShort({DateTime? now}) {
    final left = timeUntilDailyReset(now: now);
    if (left.isNegative || left.inSeconds < 30) return 'soon';
    if (left.inHours >= 1) {
      final minutes = left.inMinutes.remainder(60);
      return minutes == 0 ? '${left.inHours}h' : '${left.inHours}h ${minutes}m';
    }
    if (left.inMinutes >= 1) return '${left.inMinutes}m';
    return '${left.inSeconds}s';
  }

  void tickDay({DateTime? now}) {
    final before = _questDay;
    _maybeResetDaily(now: now);
    if (_questDay == before) return;
    notifyListeners();
    _persist();
  }

  void setDietFilter(DietFilter value) {
    if (_dietFilter == value) return;
    _dietFilter = value;
    notifyListeners();
    _persist();
  }

  void clearLastClaimed() {
    if (_lastClaimedId == null) return;
    _lastClaimedId = null;
  }

  Future<void> toggleFavorite(String foodId) async {
    if (_favorites.contains(foodId)) {
      _favorites.remove(foodId);
    } else {
      _favorites.add(foodId);
    }
    _setProgress(QuestCatalog.collector, _favorites.length);
    AppTracker.track(TrackingStrings.favoriteToggle, {
      'id': foodId,
      'on': _favorites.contains(foodId),
    });
    notifyListeners();
    await _persist();
  }

  void syncFromCart({required List<CartLine> lines, String? promoCode}) {
    if (!_hydrated) return;
    _maybeResetDaily();
    final before = Map<String, int>.from(_progress);
    var dessertCount = 0;
    var itemCount = 0;
    for (final line in lines) {
      itemCount += line.quantity;
      if (line.item.categoryId == 'dessert') {
        dessertCount += line.quantity;
      }
    }
    _setProgress(QuestCatalog.sweetTooth, dessertCount > 0 ? 1 : 0);
    _setProgress(QuestCatalog.feastMode, itemCount);
    if (promoCode != null && promoCode.isNotEmpty) {
      _setProgress(QuestCatalog.couponHunter, 1);
    }
    if (_sameProgress(before, _progress)) return;
    notifyListeners();
    _persist();
  }

  bool _sameProgress(Map<String, int> left, Map<String, int> right) {
    if (left.length != right.length) return false;
    for (final entry in left.entries) {
      if (right[entry.key] != entry.value) return false;
    }
    return true;
  }

  void onOrderPlaced(Order order, {DateTime? now}) {
    _maybeResetDaily(now: now);
    _ordersPlaced += 1;
    _setProgress(QuestCatalog.firstBite, 1);
    _setProgress(QuestCatalog.loyalDiner, _ordersPlaced);

    final today = _dayKey(now ?? DateTime.now());
    if (_lastOrderDay == today) {
      // already counted streak today
    } else if (_isYesterday(_lastOrderDay, now ?? DateTime.now())) {
      _streak += 1;
    } else {
      _streak = 1;
    }
    _lastOrderDay = today;

    final earned = (order.total / AppConstants.rupeesPerCoin).floor();
    if (earned > 0) {
      _coins += earned;
    }
    AppTracker.track(TrackingStrings.orderCoins, {
      'earned': earned,
      'streak': _streak,
    });
    notifyListeners();
    _persist();
  }

  bool _isYesterday(String? day, DateTime now) {
    if (day == null) return false;
    final yesterday = _dayKey(now.subtract(const Duration(days: 1)));
    return day == yesterday;
  }

  void _setProgress(String questId, int value) {
    final definition = QuestCatalog.byId(questId);
    if (definition == null) return;
    if (_claimed.contains(questId)) {
      _progress[questId] = definition.target;
      return;
    }
    final next = value.clamp(0, definition.target).toInt();
    _progress[questId] = next;
  }

  bool claim(String questId) {
    final definition = QuestCatalog.byId(questId);
    if (definition == null) return false;
    final current = _progress[questId] ?? 0;
    if (current < definition.target || _claimed.contains(questId)) {
      return false;
    }
    _claimed.add(questId);
    _progress[questId] = definition.target;
    _lastClaimedId = questId;
    _coins += definition.reward;
    AppTracker.track(TrackingStrings.questClaim, {
      'id': questId,
      'reward': definition.reward,
    });
    notifyListeners();
    _persist();
    return true;
  }
}
