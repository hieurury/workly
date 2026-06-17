import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/work_provider.dart';
import '../../widgets/common/work_card.dart';
import 'work_form_screen.dart';

class WorkListScreen extends StatelessWidget {
  const WorkListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workProvider = context.watch<WorkProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeWorks = workProvider.activeWorks;
    final frozenWorks = workProvider.frozenWorks;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 80,
              pinned: true,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              title: Text(
                AppStrings.workListTitle,
                style: AppTextStyles.headlineMedium(context),
              ),
              centerTitle: false,
            ),
            
            if (activeWorks.isEmpty && frozenWorks.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_outline_rounded,
                        size: 64,
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bạn chưa có công việc nào',
                        style: AppTextStyles.bodyLarge(context).copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                ),
              )
            else ...[
              if (activeWorks.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'Đang hoạt động (${activeWorks.length})',
                      style: AppTextStyles.labelLarge(context).copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: WorkCard(work: activeWorks[index])
                              .animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1),
                        );
                      },
                      childCount: activeWorks.length,
                    ),
                  ),
                ),
              ],
              
              if (frozenWorks.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Text(
                      'Đã đóng băng (${frozenWorks.length})',
                      style: AppTextStyles.labelLarge(context).copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: WorkCard(work: frozenWorks[index])
                              .animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1),
                        );
                      },
                      childCount: frozenWorks.length,
                    ),
                  ),
                ),
              ],
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WorkFormScreen()),
          );
        },
        backgroundColor: isDark ? Colors.white : Colors.black,
        child: Icon(Icons.add_rounded, color: isDark ? Colors.black : Colors.white),
      ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
    );
  }
}
