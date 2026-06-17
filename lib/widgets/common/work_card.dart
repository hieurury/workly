import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/icon_helper.dart';
import '../../data/models/work_model.dart';
import '../../providers/work_provider.dart';
import '../../screens/work/work_detail_screen.dart';
import 'package:provider/provider.dart';

class WorkCard extends StatelessWidget {
  final WorkModel work;

  const WorkCard({super.key, required this.work});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppColors.getWorkColor(work.color);
    
    // If frozen, we dim the card
    final opacity = work.isActived ? 1.0 : 0.5;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WorkDetailScreen(workId: work.id)),
        );
      },
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: WorkIcon(iconName: work.icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  work.title,
                                  style: AppTextStyles.headlineMedium(context).copyWith(fontSize: 18),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (work.isCompleted) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                              ],
                            ],
                          ),
                        ),
                        if (work.isMain) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Chính',
                              style: AppTextStyles.caption(context).copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (work.description != null && work.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        work.description!,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                onSelected: (value) async {
                  final provider = context.read<WorkProvider>();
                  if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Xóa công việc'),
                        content: Text('Bạn có chắc chắn muốn xóa công việc "${work.title}"? Dữ liệu không thể khôi phục.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: AppColors.danger))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      provider.deleteWork(work.id);
                    }
                  } else if (value == 'main') {
                    provider.setMainWork(work.id);
                  } else if (value == 'duplicate') {
                    provider.duplicateWork(work);
                  }
                },
                itemBuilder: (ctx) => [
                  if (!work.isMain)
                    const PopupMenuItem(
                      value: 'main',
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded, color: AppColors.warning),
                          SizedBox(width: 12),
                          Text('Đặt làm việc chính'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy_rounded, color: AppColors.info),
                        SizedBox(width: 12),
                        Text('Tạo bản sao'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, color: AppColors.danger),
                        SizedBox(width: 12),
                        Text('Xóa', style: TextStyle(color: AppColors.danger)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
