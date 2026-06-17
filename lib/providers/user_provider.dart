/// user_provider.dart
///
/// State management for the authenticated user's profile data.
/// Uses [UserRepository] for persistence and [StreakManager] for streak logic.

import 'package:flutter/material.dart';

import '../core/utils/streak_manager.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';

/// Provides the current [UserModel] to the widget tree and exposes all
/// user-related mutation methods.
///
/// Register as a [ChangeNotifierProvider] near the root of the widget tree.
class UserProvider extends ChangeNotifier {
  final UserRepository _repo = UserRepository();

  UserModel? _user;
  bool _isLoading = false;
  bool _isFirstLaunch = true;
  String? _error;

  // ──────────────────────────────────────────────────────────────────────────
  // Getters
  // ──────────────────────────────────────────────────────────────────────────

  /// The current user profile, or `null` if not yet loaded / created.
  UserModel? get user => _user;

  /// `true` while any async operation is in progress.
  bool get isLoading => _isLoading;

  /// `true` when the app has not yet completed onboarding (no saved user).
  bool get isFirstLaunch => _isFirstLaunch;

  /// Convenience getter — `true` when a [UserModel] has been loaded.
  bool get hasUser => _user != null;

  /// The last error message, if any async operation failed. `null` on success.
  String? get error => _error;

  // ──────────────────────────────────────────────────────────────────────────
  // Initialization
  // ──────────────────────────────────────────────────────────────────────────

  /// Checks whether a user profile exists and loads it if so.
  ///
  /// Sets [isFirstLaunch] to `false` when a profile is found.
  /// Always call this once on app startup (e.g. in a [FutureProvider] or
  /// inside `main()` before `runApp`).
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final exists = await _repo.hasUser();
      if (exists) {
        final loaded = await _repo.getUser();
        _user = loaded;
        _isFirstLaunch = loaded == null;
      } else {
        _isFirstLaunch = true;
      }
      _error = null;
    } catch (e) {
      _error = 'Khong the khoi tao du lieu nguoi dung: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Mutations
  // ──────────────────────────────────────────────────────────────────────────

  /// Persists [user] and updates the in-memory state.
  ///
  /// Use for the initial profile creation during onboarding.
  Future<void> saveUser(UserModel user) async {
    _setLoading(true);
    try {
      await _repo.saveUser(user);
      _user = user;
      _isFirstLaunch = false;
      _error = null;
    } catch (e) {
      _error = 'Khong the luu nguoi dung: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Updates the persisted profile with [user] and refreshes in-memory state.
  ///
  /// Semantically equivalent to [saveUser] but signals intent to update an
  /// existing record rather than create a new one.
  Future<void> updateUser(UserModel user) async {
    _setLoading(true);
    try {
      await _repo.saveUser(user);
      _user = user;
      _error = null;
    } catch (e) {
      _error = 'Khong the cap nhat nguoi dung: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Saves the image at [sourcePath] as the new avatar, updates [UserModel],
  /// and deletes the previous avatar file to free disk space.
  ///
  /// Returns the new relative avatar path on success, or `null` on failure.
  Future<String?> updateAvatar(String sourcePath) async {
    if (_user == null) return null;
    _setLoading(true);
    try {
      final oldPath = _user!.avatarPath;
      final newRelativePath = await _repo.saveAvatar(sourcePath);
      final updated = _user!.copyWith(avatarPath: newRelativePath);
      await _repo.saveUser(updated);
      _user = updated;
      // Clean up the old avatar file after successful save.
      if (oldPath != null) await _repo.deleteAvatar(oldPath);
      _error = null;
      return newRelativePath;
    } catch (e) {
      _error = 'Khong the cap nhat anh dai dien: $e';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Saves the image at [sourcePath] as the new cover photo, updates
  /// [UserModel], and deletes the previous cover file.
  ///
  /// Returns the new relative cover path on success, or `null` on failure.
  Future<String?> updateCover(String sourcePath) async {
    if (_user == null) return null;
    _setLoading(true);
    try {
      final oldPath = _user!.coverPath;
      final newRelativePath = await _repo.saveCover(sourcePath);
      final updated = _user!.copyWith(coverPath: newRelativePath);
      await _repo.saveUser(updated);
      _user = updated;
      // Clean up the old cover file after successful save.
      if (oldPath != null) await _repo.deleteCover(oldPath);
      _error = null;
      return newRelativePath;
    } catch (e) {
      _error = 'Khong the cap nhat anh bia: $e';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Streak management
  // ──────────────────────────────────────────────────────────────────────────

  /// Increments the user's check-in streak using [StreakManager.processCheckin].
  ///
  /// Handles the reset-then-increment flow internally. No-ops if the user has
  /// already checked in today.
  Future<void> incrementStreak() async {
    if (_user == null) return;
    try {
      final updated = StreakManager.processCheckin(_user!);
      // Only persist and notify if the model actually changed.
      if (updated != _user) {
        await _repo.saveUser(updated);
        _user = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Khong the cap nhat streak: $e';
      notifyListeners();
    }
  }

  /// Checks whether the streak should be reset (user missed a day) and resets
  /// it if necessary.
  ///
  /// Call this on each app launch after [initialize] to ensure the streak
  /// counter is always accurate.
  Future<void> checkAndResetStreak() async {
    if (_user == null) return;
    try {
      if (StreakManager.shouldResetStreak(_user!)) {
        final reset = StreakManager.resetStreak(_user!);
        await _repo.saveUser(reset);
        _user = reset;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Khong the kiem tra streak: $e';
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Image path helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Returns the full filesystem path for the user's avatar image, suitable
  /// for use with [FileImage], or `null` if no avatar is set.
  ///
  /// This is a synchronous snapshot — call [_repo.getFullImagePath] directly
  /// when you need the resolved path asynchronously.
  String? getAvatarFullPath() {
    if (_user?.avatarPath == null) return null;
    // Full path resolution requires async; callers should use FutureBuilder
    // or call _repo.getFullImagePath(_user!.avatarPath!) directly.
    // This method exists for convenience and is populated after initialization.
    return _avatarFullPath;
  }

  /// Returns the full filesystem path for the user's cover image, or `null`
  /// if no cover is set.
  String? getCoverFullPath() {
    if (_user?.coverPath == null) return null;
    return _coverFullPath;
  }

  // Cached full paths resolved after each update.
  String? _avatarFullPath;
  String? _coverFullPath;

  /// Resolves and caches full image paths for both avatar and cover.
  ///
  /// Call this after [initialize] or any update that changes image paths to
  /// keep [getAvatarFullPath] and [getCoverFullPath] in sync.
  Future<void> resolveImagePaths() async {
    if (_user == null) return;
    try {
      if (_user!.avatarPath != null && await _repo.imageExists(_user!.avatarPath!)) {
        _avatarFullPath = await _repo.getFullImagePath(_user!.avatarPath!);
      } else {
        _avatarFullPath = null;
      }
      if (_user!.coverPath != null && await _repo.imageExists(_user!.coverPath!)) {
        _coverFullPath = await _repo.getFullImagePath(_user!.coverPath!);
      } else {
        _coverFullPath = null;
      }
      notifyListeners();
    } catch (_) {
      // Non-fatal; paths simply remain unresolved.
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
