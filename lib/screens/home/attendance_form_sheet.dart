import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/salary_calculator.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/work_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/work_provider.dart';

class AttendanceFormSheet extends StatefulWidget {
  final List<WorkModel> pendingWorks;
  final int currentIndex;
  final DateTime? makeupDate;
  final AttendanceModel? attendanceToEdit;

  const AttendanceFormSheet({
    super.key,
    required this.pendingWorks,
    required this.currentIndex,
    this.makeupDate,
    this.attendanceToEdit,
  });

  @override
  State<AttendanceFormSheet> createState() => _AttendanceFormSheetState();
}

class _AttendanceFormSheetState extends State<AttendanceFormSheet> {
  late WorkModel _work;
  bool _isOff = false;
  String _shift = 'day';
  String _startTime = '08:00';
  String _endTime = '17:00';
  bool _compensation = false;
  bool _salaryReceived = false;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default to the current index
    _work = widget.pendingWorks[widget.currentIndex];
    
    if (widget.attendanceToEdit != null) {
      final att = widget.attendanceToEdit!;
      _isOff = att.isOff;
      _shift = att.typeWorkTime;
      _compensation = att.compensationReceived;
      _salaryReceived = att.salaryReceived;
      _noteController.text = att.note ?? '';
      
      if (att.startTime != null && att.endTime != null) {
        _startTime = att.startTime!;
        _endTime = att.endTime!;
      } else {
        _applyWorkConfig(_work);
      }
    } else {
      _applyWorkConfig(_work);
    }
  }
  
  void _applyWorkConfig(WorkModel work) {
    if (work.config.dayWorkTime != null) {
      final parts = work.config.dayWorkTime!.split('-');
      if (parts.length == 2) {
        setState(() {
          _shift = 'day';
          _startTime = parts[0].trim();
          _endTime = parts[1].trim();
        });
      }
    } else if (work.config.nightWorkTime != null) {
      final parts = work.config.nightWorkTime!.split('-');
      if (parts.length == 2) {
        setState(() {
          _shift = 'night';
          _startTime = parts[0].trim();
          _endTime = parts[1].trim();
        });
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _setShift(String value) {
    setState(() {
      _shift = value;
      if (value == 'day' && _work.config.dayWorkTime != null) {
        final parts = _work.config.dayWorkTime!.split('-');
        if (parts.length == 2) {
          _startTime = parts[0].trim();
          _endTime = parts[1].trim();
        }
      } else if (value == 'night' && _work.config.nightWorkTime != null) {
        final parts = _work.config.nightWorkTime!.split('-');
        if (parts.length == 2) {
          _startTime = parts[0].trim();
          _endTime = parts[1].trim();
        }
      }
    });
  }

  Future<void> _submit() async {
    final workProvider = context.read<WorkProvider>();
    final userProvider = context.read<UserProvider>();
    
    final date = widget.makeupDate ?? DateTime.now();
    
    final attendance = AttendanceModel(
      id: widget.attendanceToEdit?.id ?? const Uuid().v4(),
      workId: _work.id,
      date: date,
      isOff: _isOff,
      typeWorkTime: _shift,
      isOvertime: false, // will calculate
      startTime: _isOff ? null : _startTime,
      endTime: _isOff ? null : _endTime,
      compensationReceived: _compensation,
      salaryReceived: _salaryReceived,
      note: _noteController.text.trim(),
    );
    
    // Auto-calculate overtime flag
    final overtime = SalaryCalculator.calculateOvertimeHours(attendance, _work.config);
    final finalAttendance = attendance.copyWith(isOvertime: overtime > 0);

    if (widget.attendanceToEdit != null) {
      await workProvider.updateAttendance(_work.id, finalAttendance);
    } else {
      await workProvider.addAttendance(_work.id, finalAttendance);
      // If it's today's attendance, process streak
      if (WorklyDateUtils.isToday(date)) {
        await userProvider.incrementStreak();
      }
    }
    
    if (!mounted) return;
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Điểm danh thành công'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _selectTime(bool isStart) async {
    final current = isStart ? _startTime : _endTime;
    final parts = current.split(':');
    final time = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final selected = await showTimePicker(
      context: context,
      initialTime: time,
    );

    if (selected != null) {
      setState(() {
        final formatted = '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
        if (isStart) {
          _startTime = formatted;
        } else {
          _endTime = formatted;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = WorklyDateUtils.formatDate(widget.makeupDate ?? DateTime.now());
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 24),
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
              Text(
                widget.attendanceToEdit != null ? 'Sửa điểm danh' : 'Điểm danh',
                style: AppTextStyles.labelMedium(context).copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              
              if (widget.pendingWorks.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<WorkModel>(
                      value: _work,
                      isExpanded: true,
                      items: widget.pendingWorks.map((w) {
                        return DropdownMenuItem(
                          value: w,
                          child: Text(w.title, style: AppTextStyles.headlineMedium(context).copyWith(fontSize: 18)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _work = val);
                          _applyWorkConfig(val);
                        }
                      },
                    ),
                  ),
                )
              else
                Text(
                  _work.title,
                  style: AppTextStyles.headlineMedium(context),
                ),
                
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: AppTextStyles.bodyMedium(context),
              ),
              
              const SizedBox(height: 32),
              
              // Off Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nghỉ làm', style: AppTextStyles.headlineSmall(context)),
                  Switch.adaptive(
                    value: _isOff,
                    onChanged: (val) => setState(() => _isOff = val),
                    activeTrackColor: AppColors.info,
                  ),
                ],
              ),
              
              if (!_isOff) ...[
                const SizedBox(height: 24),
                
                // Shift Selector
                Row(
                  children: [
                    _buildShiftButton('day', AppStrings.attendanceDayShift, isDark),
                    const SizedBox(width: 12),
                    _buildShiftButton('night', AppStrings.attendanceNightShift, isDark),
                  ],
                ).animate().fadeIn().slideY(begin: 0.1),
                
                const SizedBox(height: 24),
                
                // Time Selectors
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeSelector(
                        AppStrings.attendanceStartTime,
                        _startTime,
                        () => _selectTime(true),
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeSelector(
                        AppStrings.attendanceEndTime,
                        _endTime,
                        () => _selectTime(false),
                        isDark,
                      ),
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: 0.1),
                
                const SizedBox(height: 24),
                
                // Compensation & Salary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.attendanceCompensation, style: AppTextStyles.bodyLarge(context)),
                    Checkbox(
                      value: _compensation,
                      onChanged: (val) => setState(() => _compensation = val ?? false),
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: 0.1),
                
                if (_work.config.dayToSalary == null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Đã nhận lương hôm nay', style: AppTextStyles.bodyLarge(context)),
                      Checkbox(
                        value: _salaryReceived,
                        onChanged: (val) => setState(() => _salaryReceived = val ?? false),
                      ),
                    ],
                  ).animate().fadeIn().slideY(begin: 0.1),
              ],
              
              const SizedBox(height: 24),
              
              // Note
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: AppStrings.attendanceNote,
                  hintText: 'Nhập ghi chú (nếu có)',
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 32),
              
              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Lưu',
                    style: TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShiftButton(String value, String label, bool isDark) {
    final isSelected = _shift == value;
    final bg = isSelected 
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight);
    final textCol = isSelected
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
        
    return Expanded(
      child: GestureDetector(
        onTap: () => _setShift(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? null : Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelLarge(context).copyWith(color: textCol),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector(String label, String time, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelMedium(context)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time, style: AppTextStyles.headlineSmall(context)),
                Icon(Icons.access_time_rounded, size: 20, 
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
