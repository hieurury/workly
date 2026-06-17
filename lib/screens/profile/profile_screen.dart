import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import 'profile_edit_screen.dart';
import 'user_guide_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final avatarPath = userProvider.getAvatarFullPath();
    final coverPath = userProvider.getCoverFullPath();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover
                  if (coverPath != null)
                    Image.file(File(coverPath), fit: BoxFit.cover)
                  else
                    Container(color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
                  
                  // Gradient overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          (isDark ? AppColors.surfaceDark : AppColors.surfaceLight).withOpacity(0.8),
                          isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        ],
                      ),
                    ),
                  ),

                  // Avatar & Info
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? Colors.black : Colors.white, width: 3),
                            image: avatarPath != null
                                ? DecorationImage(image: FileImage(File(avatarPath)), fit: BoxFit.cover)
                                : null,
                            color: AppColors.surfaceVariantLight,
                          ),
                          child: avatarPath == null ? const Icon(Icons.person, size: 40) : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user.name,
                                style: AppTextStyles.headlineLarge(context),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '🔥 ${user.streak} ngày streak',
                                  style: AppTextStyles.caption(context).copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cài đặt', style: AppTextStyles.headlineMedium(context)),
                  const SizedBox(height: 16),
                  
                  _buildSettingCard(
                    context,
                    isDark,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.dark_mode_rounded),
                        title: const Text('Giao diện tối'),
                        trailing: Switch.adaptive(
                          value: isDark,
                          onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
                        ),
                      ),
                      const Divider(indent: 56),
                      ListTile(
                        leading: const Icon(Icons.edit_rounded),
                        title: const Text('Chỉnh sửa thông tin cá nhân'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Text('Thông tin ứng dụng', style: AppTextStyles.headlineMedium(context)),
                  const SizedBox(height: 16),

                  _buildSettingCard(
                    context,
                    isDark,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline_rounded),
                        title: const Text('Phiên bản'),
                        trailing: Text('1.0.0', style: AppTextStyles.bodyMedium(context)),
                      ),
                      const Divider(indent: 56),
                      ListTile(
                        leading: const Icon(Icons.help_outline_rounded),
                        title: const Text('Hướng dẫn sử dụng'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const UserGuideScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, bool isDark, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
      child: Column(children: children),
    );
  }
}
