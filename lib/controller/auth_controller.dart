import 'package:flutter/material.dart';
import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/constants/tracking_strings.dart';
import 'package:khaanado/model/user_profile.dart';
import 'package:khaanado/services/app_logger.dart';
import 'package:khaanado/services/local_storage.dart';
import 'package:khaanado/app_util.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._storage);

  final LocalStorage _storage;

  UserProfile? _user;
  bool _guest = false;
  bool _hydrated = false;

  UserProfile? get user => _user;
  bool get isGuest => _guest;
  bool get isLoggedIn => _user != null && !_guest;
  bool get hasSession => isLoggedIn || _guest;
  bool get hydrated => _hydrated;
  String get displayName => _user?.name ?? StringConstants.guestUser;
  String get displayEmail =>
      isLoggedIn ? _user!.email : StringConstants.guestEmail;

  Future<void> hydrate() async {
    await _ensureDemoUser();
    _guest = _storage.readGuest();
    final email = _storage.readSessionEmail();
    if (email != null) {
      final match = _storage.readUsers().where((u) => u.email == email);
      _user = match.isEmpty ? null : match.first;
    }
    if (_user == null && _guest) {
      _user = UserProfile.guest;
    }
    _hydrated = true;
    notifyListeners();
  }

  Future<void> _ensureDemoUser() async {
    final users = _storage.readUsers();
    final exists = users.any((u) => u.email == AppConstants.demoEmail);
    if (!exists) {
      users.add(
        const UserProfile(
          name: AppConstants.demoName,
          email: AppConstants.demoEmail,
          password: AppConstants.demoPassword,
        ),
      );
      await _storage.saveUsers(users);
    }
  }

  String? validateEmail(String email) {
    if (email.trim().isEmpty) return StringConstants.emailEmpty;
    if (!AppUtil.isValidEmail(email)) return StringConstants.emailInvalid;
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return StringConstants.passwordEmpty;
    if (!AppUtil.isValidPassword(password)) {
      return StringConstants.passwordShort;
    }
    return null;
  }

  String? validateName(String name) {
    if (name.trim().isEmpty) return StringConstants.nameEmpty;
    return null;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    await _ensureDemoUser();
    final emailError = validateEmail(email);
    if (emailError != null) return emailError;
    final passwordError = validatePassword(password);
    if (passwordError != null) return passwordError;

    final users = _storage.readUsers();
    UserProfile? match;
    for (final user in users) {
      if (user.email.toLowerCase() == email.trim().toLowerCase() &&
          user.password == password) {
        match = user;
        break;
      }
    }
    if (match == null) return StringConstants.loginFailed;

    _user = match;
    _guest = false;
    await _storage.saveGuest(false);
    await _storage.saveSessionEmail(match.email);
    AppTracker.track(TrackingStrings.loginSuccess, {'email': match.email});
    notifyListeners();
    return null;
  }

  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String confirm,
  }) async {
    final nameError = validateName(name);
    if (nameError != null) return nameError;
    final emailError = validateEmail(email);
    if (emailError != null) return emailError;
    final passwordError = validatePassword(password);
    if (passwordError != null) return passwordError;
    if (password != confirm) return StringConstants.passwordMismatch;

    final users = _storage.readUsers();
    final taken = users.any(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
    );
    if (taken) return StringConstants.emailTaken;

    final profile = UserProfile(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
    );
    users.add(profile);
    await _storage.saveUsers(users);
    _user = profile;
    _guest = false;
    await _storage.saveGuest(false);
    await _storage.saveSessionEmail(profile.email);
    AppTracker.track(TrackingStrings.signupSuccess);
    notifyListeners();
    return null;
  }

  Future<void> continueAsGuest() async {
    _user = UserProfile.guest;
    _guest = true;
    await _storage.saveGuest(true);
    await _storage.clearSession();
    AppTracker.track(TrackingStrings.guestContinue);
    notifyListeners();
  }

  Future<String?> changePassword({
    required String current,
    required String next,
  }) async {
    if (!isLoggedIn) return StringConstants.genericError;
    if (_user!.password != current) {
      return StringConstants.currentPasswordWrong;
    }
    final nextError = validatePassword(next);
    if (nextError != null) return nextError;
    final updated = _user!.copyWith(password: next);
    final users = _storage.readUsers();
    final index = users.indexWhere((u) => u.email == updated.email);
    if (index >= 0) {
      users[index] = updated;
      await _storage.saveUsers(users);
    }
    _user = updated;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _user = null;
    _guest = false;
    await _storage.clearSession();
    await _storage.saveGuest(false);
    AppTracker.track(TrackingStrings.logout);
    notifyListeners();
  }
}
