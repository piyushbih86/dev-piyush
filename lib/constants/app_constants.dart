class AppConstants {
  AppConstants._();

  static const gstRate = 0.05;
  static const deliveryFee = 40.0;
  static const freeDeliveryMin = 499.0;
  static const minPasswordLength = 6;
  static const mockNetworkDelayMs = 450;
  static const splashMs = 900;
  static const toasterMinMs = 1500;
  static const toasterMaxMs = 5000;
  static const toasterMsPerChar = 50;

  static const promoPercentCode = 'KHAANA10';
  static const promoPercentValue = 0.10;
  static const promoFlatCode = 'FIRST50';
  static const promoFlatValue = 50.0;
  static const promoFlatMinSubtotal = 199.0;
  static const promoForceFailCode = 'FAILME';

  static const demoEmail = 'demo@khaanado.app';
  static const demoPassword = 'Demo@123';
  static const demoName = 'Piyush';

  static const preparingAfterSec = 8;
  static const onTheWayAfterSec = 22;
  static const deliveredAfterSec = 45;

  static const maxQty = 20;
  static const rupeesPerCoin = 10.0;
  static const goldMemberCoins = 200;
  static const defaultCity = 'Bengaluru';
  static const defaultLocality = 'MG Road';
}

class ShellTabs {
  ShellTabs._();

  static const home = 0;
  static const quests = 1;
  static const orders = 2;
  static const cart = 3;
  static const profile = 4;
}

class StorageKeys {
  StorageKeys._();

  static const users = 'khaanado.users';
  static const sessionEmail = 'khaanado.session_email';
  static const guest = 'khaanado.guest';
  static const cart = 'khaanado.cart';
  static const orders = 'khaanado.orders';
  static const address = 'khaanado.address';
  static const ftueSeen = 'khaanado.ftue_seen';
  static const promo = 'khaanado.promo';
  static const loyalty = 'khaanado.loyalty';
  static const theme = 'khaanado.theme';
}
