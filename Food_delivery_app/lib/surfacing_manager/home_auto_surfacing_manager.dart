import 'package:khaanado/constants/tracking_strings.dart';
import 'package:khaanado/services/app_logger.dart';
import 'package:khaanado/services/local_storage.dart';

/// Ordered auto-surface checks after Home mounts — same idea as P2E
/// `home_screen_auto_surfacing_manager`.
class HomeAutoSurfacingManager {
  HomeAutoSurfacingManager(this._storage);

  final LocalStorage _storage;

  bool get shouldShowFtue => !_storage.readFtueSeen();

  Future<void> markFtueSeen() async {
    await _storage.saveFtueSeen();
    AppTracker.track(TrackingStrings.ftueDismissed);
  }

  void onHomeReady() {
    if (shouldShowFtue) {
      AppTracker.track(TrackingStrings.ftueShown);
    }
  }
}
