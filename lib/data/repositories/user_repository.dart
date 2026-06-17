/// user_repository.dart
///
/// Provides all data access operations for the user profile.
/// Reads and writes [UserModel] to/from `user.json` via [FileStorageService],
/// and manages avatar / cover image files in the `/public` directory.

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import 'file_storage_service.dart';

/// Repository responsible for persisting and retrieving [UserModel] data.
class UserRepository {
  /// Singleton storage service used for all file I/O.
  final FileStorageService _storage = FileStorageService.instance;

  /// Internal UUID generator for unique image file names.
  static const _uuid = Uuid();

  // ──────────────────────────────────────────────────────────────────────────
  // User CRUD
  // ──────────────────────────────────────────────────────────────────────────

  /// Reads and returns the stored [UserModel] from `user.json`.
  ///
  /// Returns `null` if the file does not yet exist (i.e. first launch / before
  /// onboarding is completed).
  Future<UserModel?> getUser() async {
    try {
      final json = await _storage.readUser();
      if (json == null) return null;
      return UserModel.fromJson(json);
    } catch (e) {
      // Corrupt or malformed JSON — treat as no user.
      return null;
    }
  }

  /// Serializes [user] and writes it to `user.json`.
  ///
  /// Creates the file if it does not exist; overwrites otherwise.
  Future<void> saveUser(UserModel user) async {
    try {
      await _storage.writeUser(user.toJson());
    } catch (e) {
      throw Exception('Khong the luu thong tin nguoi dung: $e');
    }
  }

  /// Returns `true` if `user.json` exists, indicating that onboarding has
  /// already been completed on this device.
  Future<bool> hasUser() async {
    try {
      return await _storage.hasUser();
    } catch (_) {
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Image management
  // ──────────────────────────────────────────────────────────────────────────

  /// Copies the image at [sourcePath] into the `/public` directory with a
  /// uniquely generated filename and returns the relative path (e.g.
  /// `public/avatar_<uuid>.jpg`) that should be persisted to [UserModel].
  ///
  /// Throws if the source file does not exist or the copy operation fails.
  Future<String> saveAvatar(String sourcePath) async {
    try {
      final ext = p.extension(sourcePath).isNotEmpty
          ? p.extension(sourcePath)
          : '.jpg';
      final fileName = 'avatar_${_uuid.v4()}$ext';
      return await _storage.saveImage(sourcePath, fileName);
    } catch (e) {
      throw Exception('Khong the luu anh dai dien: $e');
    }
  }

  /// Copies the image at [sourcePath] into the `/public` directory with a
  /// uniquely generated filename and returns the relative path (e.g.
  /// `public/cover_<uuid>.jpg`) that should be persisted to [UserModel].
  ///
  /// Throws if the source file does not exist or the copy operation fails.
  Future<String> saveCover(String sourcePath) async {
    try {
      final ext = p.extension(sourcePath).isNotEmpty
          ? p.extension(sourcePath)
          : '.jpg';
      final fileName = 'cover_${_uuid.v4()}$ext';
      return await _storage.saveImage(sourcePath, fileName);
    } catch (e) {
      throw Exception('Khong the luu anh bia: $e');
    }
  }

  /// Deletes the avatar file at the given relative [path] from `/public`.
  ///
  /// No-ops silently if [path] is `null` or the file does not exist.
  Future<void> deleteAvatar(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      await _storage.deleteImage(path);
    } catch (_) {
      // Best-effort deletion; ignore failures.
    }
  }

  /// Deletes the cover image file at the given relative [path] from `/public`.
  ///
  /// No-ops silently if [path] is `null` or the file does not exist.
  Future<void> deleteCover(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      await _storage.deleteImage(path);
    } catch (_) {
      // Best-effort deletion; ignore failures.
    }
  }

  /// Converts a relative image path stored in [UserModel] to an absolute
  /// filesystem path suitable for display widgets (e.g. [FileImage]).
  ///
  /// Example: `'public/avatar_abc.jpg'` -> `/data/user/0/.../workly/public/avatar_abc.jpg`
  Future<String> getFullImagePath(String relativePath) async {
    try {
      return await _storage.getFullPath(relativePath);
    } catch (e) {
      throw Exception('Khong the lay duong dan anh: $e');
    }
  }

  /// Checks whether the image file at [relativePath] actually exists on disk.
  ///
  /// Useful for graceful fallback when a stored path points to a deleted file.
  Future<bool> imageExists(String relativePath) async {
    try {
      final fullPath = await _storage.getFullPath(relativePath);
      return File(fullPath).exists();
    } catch (_) {
      return false;
    }
  }
}
