import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/icon_helper.dart';
import '../../core/utils/salary_calculator.dart';
import '../../data/models/work_model.dart';
import '../../providers/work_provider.dart';
import '../home/attendance_detail_sheet.dart';
import 'work_form_screen.dart';

class WorkDetailScreen extends StatefulWidget {
  final String workId;

  const WorkDetailScreen({super.key, required this.workId});

  @override
  State<WorkDetailScreen> createState() => _WorkDetailScreenState();
}

class _WorkDetailScreenState extends State<WorkDetailScreen> {
  int _currentPage = 1;
  final int _itemsPerPage = 7;

  @override
  Widget build(BuildContext context) {
    final workProvider = context.watch<WorkProvider>();
    final work = workProvider.getWorkById(widget.workId);
    
    if (work == null) {
      return const Scaffold(body: Center(child: Text('Không tìm thấy công việc')));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppColors.getWorkColor(work.color);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: color,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: WorkIcon(iconName: work.icon, color: Colors.white, size: 32),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    work.title,
                                    style: AppTextStyles.headlineLarge(context).copyWith(color: Colors.white, fontSize: 24),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (work.description != null && work.description!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      work.description!,
                                      style: AppTextStyles.bodyMedium(context).copyWith(color: Colors.white.withOpacity(0.8)),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (work.isMain)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        AppStrings.workMain,
                                        style: AppTextStyles.labelSmall(context).copyWith(color: Colors.white),
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  Text('Lương cơ bản', style: AppTextStyles.labelSmall(context).copyWith(color: Colors.white.withOpacity(0.7))),
                                  Text(WorklyDateUtils.formatCurrency(work.config.baseSalary), style: AppTextStyles.labelMedium(context).copyWith(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  Text('Ngày công', style: AppTextStyles.labelSmall(context).copyWith(color: Colors.white.withOpacity(0.7))),
                                  Text('${work.config.numberOfDayWork} ngày', style: AppTextStyles.labelMedium(context).copyWith(color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => WorkFormScreen(workToEdit: work)),
                    );
                  } else if (value == 'main' && !work.isMain) {
                    await workProvider.setMainWork(work.id);
                  } else if (value == 'freeze') {
                    await workProvider.toggleFreeze(work.id);
                  } else if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Xóa công việc?'),
                        content: const Text('Dữ liệu điểm danh của công việc này cũng sẽ bị xóa vĩnh viễn.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Xóa', style: TextStyle(color: AppColors.danger)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await workProvider.deleteWork(work.id);
                      if (context.mounted) Navigator.pop(context);
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Sửa cấu hình'),
                  ),
                  if (!work.isMain)
                    const PopupMenuItem(
                      value: 'main',
                      child: Text('Đặt làm công việc chính'),
                    ),
                  PopupMenuItem(
                    value: 'freeze',
                    child: Text(work.isActived ? 'Đóng băng' : 'Mở đóng băng'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Xóa công việc', style: TextStyle(color: AppColors.danger)),
                  ),
                ],
              ),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatCards(context, work, isDark),
                  const SizedBox(height: 32),
                  
                  Text('Cơ cấu lương chu kỳ này', style: AppTextStyles.headlineMedium(context)),
                  const SizedBox(height: 16),
                  _buildSalaryPieChart(context, work, isDark),
                  
                  const SizedBox(height: 32),
                  Text('Lịch sử chu kỳ này', style: AppTextStyles.headlineMedium(context)),
                  const SizedBox(height: 16),
                  _buildHistory(work, isDark),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, WorkModel work, bool isDark) {
    final now = DateTime.now();
    final cycle = SalaryCalculator.getSalaryCycle(work, now);
    
    final breakdown = SalaryCalculator.calculateCycleSalaryBreakdown(work, cycle);
    final totalSalary = breakdown['salary']! + breakdown['overtime']! + breakdown['compensation']! + breakdown['subsidy']!;
    
    final weekSalary = SalaryCalculator.calculateWeekSalary(work, now.subtract(Duration(days: now.weekday - 1)));
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Lương tuần này',
            WorklyDateUtils.formatCurrency(weekSalary),
            Icons.payments_rounded,
            AppColors.getWorkColor(work.color),
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Lương chu kỳ này',
            WorklyDateUtils.formatCurrency(totalSalary),
            Icons.account_balance_wallet_rounded,
            AppColors.success,
            isDark,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(label, style: AppTextStyles.caption(context)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.headlineSmall(context).copyWith(color: color, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSalaryPieChart(BuildContext context, WorkModel work, bool isDark) {
    final cycle = SalaryCalculator.getSalaryCycle(work, DateTime.now());
    final breakdown = SalaryCalculator.calculateCycleSalaryBreakdown(work, cycle);
    
    final salary = breakdown['salary'] ?? 0;
    final overtime = breakdown['overtime'] ?? 0;
    final compensation = breakdown['compensation'] ?? 0;
    final subsidy = breakdown['subsidy'] ?? 0;
    
    final hasData = (salary + overtime + compensation + subsidy) > 0;
    
    if (!hasData) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
        ),
        child: const Center(child: Text('Chưa có dữ liệu lương chu kỳ này')),
      ).animate().fadeIn().slideY(begin: 0.1, delay: 100.ms);
    }
    
    final cSalary = Colors.blue.shade400;
    final cOvertime = Colors.orange.shade400;
    final cSubsidy = Colors.green.shade400;
    final cCompensation = Colors.purple.shade400;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 25,
                  sections: [
                    if (salary > 0) PieChartSectionData(color: cSalary, value: salary, title: '', radius: 45),
                    if (overtime > 0) PieChartSectionData(color: cOvertime, value: overtime, title: '', radius: 45),
                    if (subsidy > 0) PieChartSectionData(color: cSubsidy, value: subsidy, title: '', radius: 45),
                    if (compensation > 0) PieChartSectionData(color: cCompensation, value: compensation, title: '', radius: 45),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Lương CB', salary, cSalary),
                const SizedBox(height: 12),
                _buildLegendItem('Tăng ca', overtime, cOvertime),
                const SizedBox(height: 12),
                _buildLegendItem('Trợ cấp', subsidy, cSubsidy),
                const SizedBox(height: 12),
                _buildLegendItem('Đền bù', compensation, cCompensation),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, delay: 100.ms);
  }
  
  Widget _buildLegendItem(String label, double value, Color color) {
    if (value <= 0) return const SizedBox.shrink();
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
        Text(WorklyDateUtils.formatCurrency(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildHistory(WorkModel work, bool isDark) {
    final cycle = SalaryCalculator.getSalaryCycle(work, DateTime.now());
    
    // Generate list of days in cycle
    final daysInCycle = <DateTime>[];
    var current = cycle.start;
    while (!current.isAfter(cycle.end)) {
      daysInCycle.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    // Sort ascending: oldest to newest
    daysInCycle.sort((a, b) => a.compareTo(b));
    
    // Pagination logic
    final totalPages = (daysInCycle.length / _itemsPerPage).ceil();
    if (_currentPage > totalPages && totalPages > 0) _currentPage = totalPages;
    
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage < daysInCycle.length) ? startIndex + _itemsPerPage : daysInCycle.length;
    final currentDays = daysInCycle.sublist(startIndex, endIndex);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
          ),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentDays.length,
            separatorBuilder: (_, __) => Divider(
              height: 1, 
              indent: 16, 
              endIndent: 16,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            itemBuilder: (context, index) {
              final date = currentDays[index];
              final att = work.attendanceForDate(date);
              final isToday = WorklyDateUtils.isToday(date);
              final isFuture = WorklyDateUtils.isFuture(date);
              
              Widget badge;
              Color badgeColor;
              String badgeText;
              Color? badgeTextColor;
              
              if (att != null) {
                if (att.isOff) {
                  badgeColor = Colors.grey; 
                  badgeText = 'Nghỉ làm';
                } else if (att.isOvertime) {
                  badgeColor = AppColors.info; // Xanh dương
                  badgeText = 'Tăng ca';
                } else {
                  badgeColor = AppColors.success; // Xanh lá
                  badgeText = 'Đã điểm danh';
                }
              } else {
                if (isFuture) {
                  badgeColor = Colors.grey; // Xám
                  badgeText = 'Chưa đến';
                } else if (isToday) {
                  badgeColor = isDark ? Colors.white : Colors.black; // Trắng/Đen tùy theme
                  badgeText = 'Chưa điểm danh';
                  badgeTextColor = isDark ? Colors.black : Colors.white; // Nghịch đảo cho chữ
                } else {
                  badgeColor = AppColors.warning; // Vàng
                  badgeText = 'Điểm danh muộn';
                }
              }

              badge = Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(isFuture ? 0.3 : 1.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeTextColor ?? Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );

              return ListTile(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => AttendanceDetailSheet(work: work, date: date),
                  );
                },
                title: Text(
                  isToday ? 'Hôm nay' : WorklyDateUtils.formatDate(date),
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    color: isFuture ? (isDark ? Colors.white38 : Colors.black38) : null,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: badge,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              );
            },
          ),
        ).animate().fadeIn().slideY(begin: 0.1, delay: 200.ms),
        
        if (totalPages > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
              ),
              ...List.generate(totalPages, (index) {
                final pageNum = index + 1;
                final isSelected = _currentPage == pageNum;
                return GestureDetector(
                  onTap: () => setState(() => _currentPage = pageNum),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.info : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? null : Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    child: Center(
                      child: Text(
                        '$pageNum',
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
              ),
            ],
          )
        ],
      ],
    );
  }
}
