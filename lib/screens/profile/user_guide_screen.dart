import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Hướng dẫn sử dụng')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildStep(
            context,
            isDark,
            step: 1,
            title: 'Tạo công việc mới',
            description: 'Vào mục "Công việc" và bấm nút (+) để thêm công việc mới. Điền đầy đủ thông tin về mức lương cơ bản, giờ làm, cấu hình cuối tuần và các mục trợ cấp nếu có.',
            icon: Icons.work_outline_rounded,
          ),
          const SizedBox(height: 16),
          _buildStep(
            context,
            isDark,
            step: 2,
            title: 'Điểm danh hàng ngày',
            description: 'Trang chủ sẽ hiển thị nhắc nhở điểm danh mỗi ngày. Bấm vào nút "Điểm danh" trôi nổi ở dưới màn hình. Bạn có thể chọn Đi làm, Tăng ca, hoặc Nghỉ làm.',
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(height: 16),
          _buildStep(
            context,
            isDark,
            step: 3,
            title: 'Theo dõi Chu kỳ & Lương',
            description: 'Workly tự động theo dõi tiến trình làm việc của bạn trong tháng. Bạn có thể xem tổng thu nhập, lương tăng ca và biểu đồ chi tiết từng ngày tại trang "Dự đoán".',
            icon: Icons.auto_graph_rounded,
          ),
          const SizedBox(height: 16),
          _buildStep(
            context,
            isDark,
            step: 4,
            title: 'Chốt lương và Tạo bản sao',
            description: 'Khi nhận được lương, hãy bấm nút "Đã nhận lương hôm nay". Công việc sẽ được đánh dấu hoàn thành (✅). Sau đó bạn có thể bấm vào dấu 3 chấm để "Tạo bản sao" cho tháng tiếp theo mà không cần cấu hình lại từ đầu.',
            icon: Icons.copy_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, bool isDark, {
    required int step,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$step',
              style: AppTextStyles.headlineMedium(context).copyWith(color: AppColors.info),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: AppColors.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.headlineSmall(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
