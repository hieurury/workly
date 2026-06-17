import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/salary_calculator.dart';
import '../../data/models/work_model.dart';
import '../../providers/work_provider.dart';
import 'attendance_form_sheet.dart';

class AttendanceDetailSheet extends StatelessWidget {
  final WorkModel work;
  final DateTime date;
  final bool isMainWork;

  const AttendanceDetailSheet({
    super.key,
    required this.work,
    required this.date,
    this.isMainWork = true,
  });

  @override
  Widget build(BuildContext context) {
    final attendance = work.attendanceForDate(date);
    final isToday = WorklyDateUtils.isToday(date);
    final isPast = WorklyDateUtils.isPast(date);
    final isFuture = WorklyDateUtils.isFuture(date);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String statusText;
    Color statusColor;

    if (attendance != null) {
      if (attendance.isOff) {
        statusText = AppStrings.statusOff;
        statusColor = Colors.grey;
      } else if (attendance.isOvertime) {
        statusText = AppStrings.attendanceIsOvertime;
        statusColor = AppColors.info;
      } else {
        statusText = AppStrings.statusWorked;
        statusColor = AppColors.success;
      }
    } else {
      if (isToday) {
        statusText = AppStrings.statusToday;
        statusColor = AppColors.getWorkColor(work.color);
      } else if (isPast) {
        statusText = AppStrings.statusMissed;
        statusColor = AppColors.warning;
      } else {
        statusText = AppStrings.statusFuture;
        statusColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
      }
    }

    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                WorklyDateUtils.formatDate(date),
                style: AppTextStyles.headlineMedium(context),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.labelMedium(context).copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Details
          if (attendance != null) ...[
            if (!attendance.isOff) ...[
              Builder(
                builder: (context) {
                  final config = work.config;
                  double startH = 0, endH = 0, totalElapsed = 0, breaks = 0, totalWorked = 0, overtime = 0;
                  if (attendance.startTime != null && attendance.endTime != null) {
                    startH = WorklyDateUtils.parseTimeToHours(attendance.startTime!);
                    endH = WorklyDateUtils.parseTimeToHours(attendance.endTime!);
                    if (endH < startH) endH += 24.0;
                    totalElapsed = endH - startH;
                    breaks = totalElapsed > (config.normalWorkTime + config.timeToEat) ? config.timeToEat * 2 : config.timeToEat;
                    totalWorked = math.max(0.0, totalElapsed - breaks);
                    overtime = math.max(0.0, totalWorked - config.normalWorkTime);
                  }

                  return Column(
                    children: [
                      _buildInfoRow(
                        context,
                        Icons.schedule_rounded,
                        'Ca',
                        attendance.typeWorkTime == 'day' ? AppStrings.attendanceDayShift : AppStrings.attendanceNightShift,
                        isDark,
                      ),
                      _buildInfoRow(
                        context,
                        Icons.login_rounded,
                        'Giờ vào',
                        attendance.startTime ?? '-',
                        isDark,
                      ),
                      _buildInfoRow(
                        context,
                        Icons.logout_rounded,
                        'Giờ ra',
                        attendance.endTime ?? '-',
                        isDark,
                      ),
                      _buildInfoRow(
                        context,
                        Icons.coffee_rounded,
                        'Giờ nghỉ',
                        '${breaks.toStringAsFixed(1)} giờ',
                        isDark,
                      ),
                      _buildInfoRow(
                        context,
                        Icons.more_time_rounded,
                        'Tăng ca',
                        '${overtime.toStringAsFixed(1)} giờ',
                        isDark,
                        valueColor: overtime > 0 ? AppColors.info : null,
                      ),
                      _buildInfoRow(
                        context,
                        Icons.payments_rounded,
                        'Lương giờ',
                        WorklyDateUtils.formatCurrency(config.hourSalary),
                        isDark,
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      
                      _buildInfoRow(
                        context,
                        Icons.timer_rounded,
                        'Tổng giờ làm',
                        '${totalWorked.toStringAsFixed(1)} giờ',
                        isDark,
                        valueColor: AppColors.getWorkColor(work.color),
                      ),
                      _buildInfoRow(
                        context,
                        Icons.account_balance_wallet_rounded,
                        'Tổng lương',
                        WorklyDateUtils.formatCurrency(SalaryCalculator.calculateDaySalary(attendance, work)),
                        isDark,
                        valueColor: AppColors.success,
                      ),
                      
                      if (attendance.compensationReceived)
                        _buildInfoRow(
                          context,
                          Icons.card_giftcard_rounded,
                          'Đền bù',
                          WorklyDateUtils.formatCurrency(attendance.typeWorkTime == 'day' 
                              ? config.compensationDay 
                              : config.compensationNight),
                          isDark,
                          valueColor: AppColors.warning,
                        ),
                        
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (ctx) => AttendanceFormSheet(
                                pendingWorks: [work],
                                currentIndex: 0,
                                makeupDate: date,
                                attendanceToEdit: attendance,
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text('Chỉnh sửa'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ],
            if (attendance.note != null && attendance.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildInfoRow(
                  context,
                  Icons.note_rounded,
                  AppStrings.attendanceNote,
                  attendance.note!,
                  isDark,
                ),
              ),
          ] else if (isFuture) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Chưa đến ngày này',
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  isToday 
                      ? 'Bạn chưa điểm danh cho ngày hôm nay' 
                      : 'Bạn đã quên điểm danh ngày này',
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (ctx) => AttendanceFormSheet(
                      pendingWorks: [work],
                      currentIndex: 0,
                      makeupDate: date,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isToday ? AppStrings.attendanceTitle : AppStrings.attendanceMakeup,
                  style: TextStyle(
                    color: isDark ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodyMedium(context)),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.headlineSmall(context).copyWith(
              color: valueColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
          ),
        ],
      ),
    );
  }
}
