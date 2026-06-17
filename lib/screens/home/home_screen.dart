import 'dart:io';
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
import '../../data/models/attendance_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/work_provider.dart';
import 'attendance_detail_sheet.dart';
import 'attendance_form_sheet.dart';
import '../work/work_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _show30Days = false;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.homeGreetingMorning;
    if (hour < 18) return AppStrings.homeGreetingAfternoon;
    return AppStrings.homeGreetingEvening;
  }

  void _showAttendanceForm(List<WorkModel> pendingWorks) {
    if (pendingWorks.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => AttendanceFormSheet(
        pendingWorks: pendingWorks,
        currentIndex: 0,
      ),
    );
  }

  void _showDayDetail(WorkModel work, DateTime date) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => AttendanceDetailSheet(
        work: work,
        date: date,
        isMainWork: true,
      ),
    );
  }

  void _showSalaryBreakdown(Map<String, double> breakdown) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        title: Text('Chi tiết thu nhập', style: AppTextStyles.headlineSmall(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBreakdownRow('Lương cơ bản', breakdown['salary']!, isDark),
            _buildBreakdownRow('Tăng ca', breakdown['overtime']!, isDark),
            _buildBreakdownRow('Trợ cấp', breakdown['subsidy']!, isDark),
            _buildBreakdownRow('Đền bù', breakdown['compensation']!, isDark),
            const Divider(height: 24),
            _buildBreakdownRow(
              'Tổng cộng', 
              breakdown['salary']! + breakdown['overtime']! + breakdown['subsidy']! + breakdown['compensation']!, 
              isDark, 
              isTotal: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, double value, bool isDark, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isTotal ? AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.bold) : AppTextStyles.bodyMedium(context)),
          Text(
            WorklyDateUtils.formatCurrency(value), 
            style: isTotal 
                ? AppTextStyles.bodyLarge(context).copyWith(color: AppColors.success, fontWeight: FontWeight.bold) 
                : AppTextStyles.bodyMedium(context).copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }

  void _showOffDaysDetail(List<AttendanceModel> atts) {
    final offDays = atts.where((a) => a.isOff).toList();
    offDays.sort((a, b) => b.date.compareTo(a.date)); // descending
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        title: Text('Ngày nghỉ', style: AppTextStyles.headlineSmall(context)),
        content: offDays.isEmpty 
            ? const Text('Không có ngày nghỉ nào trong chu kỳ này.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: offDays.length,
                  itemBuilder: (ctx, idx) {
                    final date = offDays[idx].date;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('• ${WorklyDateUtils.formatDate(date)}', style: AppTextStyles.bodyMedium(context)),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final workProvider = context.watch<WorkProvider>();
    
    final user = userProvider.user;
    final mainWork = workProvider.mainWork;
    final pendingWorks = workProvider.worksPendingAttendanceToday;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (userProvider.getAvatarFullPath() != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundImage: FileImage(File(userProvider.getAvatarFullPath()!)),
                                  ),
                                )
                              else if (user != null)
                                const Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: CircleAvatar(
                                    radius: 24,
                                    child: Icon(Icons.person, size: 28),
                                  ),
                                ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_getGreeting()}, ${user?.name ?? ""}!',
                                    style: AppTextStyles.headlineMedium(context),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    WorklyDateUtils.formatDate(DateTime.now()),
                                    style: AppTextStyles.bodyMedium(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Streak badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Text('🔥', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 4),
                                Text(
                                  '${user?.streak ?? 0}',
                                  style: AppTextStyles.labelLarge(context).copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildSummaryCard(mainWork, isDark),
                  
                  if (mainWork != null) ...[
                    const SizedBox(height: 24),
                    _buildCalendarHeader(mainWork),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
            
            if (mainWork != null)
              _buildCalendarGrid(mainWork, isDark),
              
            const SliverToBoxAdapter(
              child: SizedBox(height: 100), // padding for FAB
            ),
          ],
        ),
      ),
      
      // Fixed bottom attendance button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: pendingWorks.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: FloatingActionButton.extended(
                  onPressed: () => _showAttendanceForm(pendingWorks),
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  label: Text(
                    pendingWorks.length == 1 
                        ? AppStrings.attendanceTitle 
                        : '${AppStrings.attendanceTitle} (${pendingWorks.length} việc)',
                    style: AppTextStyles.labelLarge(context).copyWith(
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                  icon: Icon(
                    Icons.check_circle_rounded,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ).animate().slideY(begin: 1, duration: 400.ms, curve: Curves.easeOutCubic),
            )
          : null,
    );
  }

  Widget _buildSummaryCard(WorkModel? work, bool isDark) {
    if (work == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
        ),
        child: Column(
          children: [
            Icon(
              Icons.work_off_rounded,
              size: 48,
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.homeNoMainWork,
              style: AppTextStyles.headlineSmall(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkFormScreen()),
                );
              },
              child: const Text(AppStrings.homeAddWorkNow),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
    }

    final color = AppColors.getWorkColor(work.color);
    final now = DateTime.now();
    final cycle = SalaryCalculator.getSalaryCycle(work, now);
    final breakdown = SalaryCalculator.calculateCycleSalaryBreakdown(work, cycle);
    final cycleSalary = breakdown['salary']! + breakdown['overtime']! + breakdown['compensation']! + breakdown['subsidy']!;
    
    final currentCycleAtts = work.data.where((a) => cycle.contains(a.date)).toList();
    
    final daysWorked = currentCycleAtts.where((a) => !a.isOff).length;
    final daysOff = currentCycleAtts.where((a) => a.isOff).length;
    final totalDays = work.config.numberOfDayWork;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                        Flexible(
                          child: Text(
                            work.title,
                            style: AppTextStyles.headlineMedium(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (work.isCompleted) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppStrings.workMain,
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
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                AppStrings.homeDaysWorked,
                '$daysWorked/$totalDays',
                Icons.calendar_month_rounded,
                isDark,
              ),
              _buildStatItem(
                AppStrings.homeEarned,
                WorklyDateUtils.formatCurrency(cycleSalary),
                Icons.account_balance_wallet_rounded,
                isDark,
                isMoney: true,
                onTap: () => _showSalaryBreakdown(breakdown),
              ),
              _buildStatItem(
                AppStrings.homeDaysOff,
                '$daysOff',
                Icons.bed_rounded,
                isDark,
                onTap: () => _showOffDaysDetail(currentCycleAtts),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool isDark, {bool isMoney = false, VoidCallback? onTap}) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.caption(context)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: isMoney 
              ? AppTextStyles.moneyMedium(context).copyWith(color: AppColors.success)
              : AppTextStyles.headlineSmall(context),
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
          child: content,
        ),
      );
    }
    return content;
  }

  Widget _buildCalendarHeader(WorkModel work) {
    final cycle = SalaryCalculator.getSalaryCycle(work, DateTime.now());
    final cycleDaysCount = cycle.end.difference(cycle.start).inDays + 1;

    if (cycleDaysCount <= 7) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'Chu kỳ này ($cycleDaysCount ngày)',
          style: AppTextStyles.headlineSmall(context),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _show30Days ? 'Chu kỳ này' : AppStrings.homeView7Days,
            style: AppTextStyles.headlineSmall(context),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.surfaceVariantDark 
                  : AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleButton(false, '7 ngày'),
                _buildToggleButton(true, '$cycleDaysCount ngày'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(bool value, String label) {
    final isSelected = _show30Days == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => setState(() => _show30Days = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? Colors.white : Colors.black)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium(context).copyWith(
            color: isSelected 
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(WorkModel work, bool isDark) {
    final cycle = SalaryCalculator.getSalaryCycle(work, DateTime.now());
    final cycleDaysCount = cycle.end.difference(cycle.start).inDays + 1;
    
    final cycleDays = <DateTime>[];
    var current = cycle.start;
    while (!current.isAfter(cycle.end)) {
      cycleDays.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    final days = (_show30Days || cycleDaysCount <= 7)
        ? cycleDays.reversed.toList()
        : WorklyDateUtils.getLast7Days().reversed.toList();
        
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final date = days[index];
            final attendance = work.attendanceForDate(date);
            final isToday = WorklyDateUtils.isToday(date);
            
            Color dotColor;
            Color borderColor = Colors.transparent;
            
            if (attendance != null) {
              if (attendance.isOff) {
                dotColor = Colors.grey; // Nghỉ làm
              } else if (attendance.isOvertime) {
                dotColor = AppColors.info; // Tăng ca (xanh dương)
              } else {
                dotColor = AppColors.success; // Điểm danh thường
              }
            } else {
              if (WorklyDateUtils.isFuture(date)) {
                dotColor = Colors.grey.withOpacity(0.4); // Tương lai
              } else if (isToday) {
                dotColor = isDark ? Colors.white : Colors.black; // Hôm nay chưa điểm danh
              } else {
                dotColor = AppColors.warning; // Quá khứ chưa điểm danh
              }
              if (isToday) borderColor = AppColors.getWorkColor(work.color);
            }

            return GestureDetector(
              onTap: () => _showDayDetail(work, date),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(16),
                  border: borderColor != Colors.transparent ? Border.all(color: borderColor, width: 2) : null,
                  boxShadow: isToday ? (isDark ? AppColors.elevatedShadowDark : AppColors.elevatedShadowLight) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      WorklyDateUtils.formatDateShort(date),
                      style: AppTextStyles.caption(context).copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${date.day}',
                      style: AppTextStyles.headlineMedium(context).copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ).animate().scale(delay: (index * 15).ms, duration: 200.ms),
            );
          },
          childCount: days.length,
        ),
      ),
    );
  }
}
