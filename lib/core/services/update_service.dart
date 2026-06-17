import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';

class UpdateService {
  static const String _repoUrl = 'https://api.github.com/repos/hieurury/workly/releases/latest';

  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(Uri.parse(_repoUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String tagName = data['tag_name'] ?? '';
        final String releaseNotes = data['body'] ?? 'Không có thông tin ghi chú.';
        final String downloadUrl = data['html_url'] ?? '';

        final latestVersion = tagName.replaceAll('v', '');

        if (_isNewerVersion(currentVersion, latestVersion)) {
          if (context.mounted) {
            _showUpdateDialog(context, latestVersion, releaseNotes, downloadUrl);
          }
        }
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  static bool _isNewerVersion(String current, String latest) {
    final v1 = current.split('.');
    final v2 = latest.split('.');
    for (var i = 0; i < v1.length && i < v2.length; i++) {
      final num1 = int.tryParse(v1[i]) ?? 0;
      final num2 = int.tryParse(v2[i]) ?? 0;
      if (num2 > num1) return true;
      if (num2 < num1) return false;
    }
    return v2.length > v1.length;
  }

  static void _showUpdateDialog(BuildContext context, String version, String releaseNotes, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.system_update_rounded, color: AppColors.info, size: 28),
              const SizedBox(width: 12),
              const Text('Cập nhật mới!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Phiên bản mới: v$version', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Text(releaseNotes),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Tải xuống ngay'),
            ),
          ],
        );
      },
    );
  }
}
