import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/icon_helper.dart';
import '../../data/models/subsidy_model.dart';
import '../../data/models/work_config_model.dart';
import '../../data/models/work_model.dart';
import '../../providers/work_provider.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    final numValue = int.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (numValue == null) return oldValue;
    final formatter = NumberFormat('#,###', 'vi_VN');
    final newText = formatter.format(numValue);
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class WorkFormScreen extends StatefulWidget {
  final WorkModel? workToEdit;

  const WorkFormScreen({super.key, this.workToEdit});

  @override
  State<WorkFormScreen> createState() => _WorkFormScreenState();
}

class _WorkFormScreenState extends State<WorkFormScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  int _maxReachedStep = 0;
  
  // -- Step 1 --
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _icon = 'work';
  String _color = 'blue';
  bool _isMain = false;

  // -- Step 2 --
  final _baseSalaryController = TextEditingController();
  final _daysController = TextEditingController();
  final _hoursController = TextEditingController();
  final _breakController = TextEditingController();

  // -- Step 3 --
  final Map<String, bool> _weekends = {
    'monday': false, 'tuesday': false, 'wednesday': false,
    'thursday': false, 'friday': false, 'saturday': true, 'sunday': true
  };
  final Map<String, String> _dayNames = {
    'monday': 'Thứ 2', 'tuesday': 'Thứ 3', 'wednesday': 'Thứ 4',
    'thursday': 'Thứ 5', 'friday': 'Thứ 6', 'saturday': 'Thứ 7', 'sunday': 'Chủ nhật'
  };

  // -- Step 4 --
  TimeOfDay? _dayStart;
  TimeOfDay? _dayEnd;
  TimeOfDay? _nightStart;
  TimeOfDay? _nightEnd;

  // -- Step 5 --
  int? _dayStartWork;
  int? _dayToSalary;

  // -- Step 6 --
  final _otDayController = TextEditingController(text: '1.0');
  final _otNightController = TextEditingController(text: '1.0');
  final _otWkDayController = TextEditingController(text: '1.0');
  final _otWkNightController = TextEditingController(text: '1.0');
  final _otHolDayController = TextEditingController(text: '1.0');
  final _otHolNightController = TextEditingController(text: '1.0');

  // -- Step 7 --
  final _compDayController = TextEditingController(text: '0');
  final _compNightController = TextEditingController(text: '0');

  // -- Step 8 --
  List<SubsidyModel> _subsidies = [];

  // -- Step 9 --
  List<SubsidyModel> _conditionalSubsidies = [];

  @override
  void initState() {
    super.initState();
    if (widget.workToEdit != null) {
      _maxReachedStep = 8;
      _loadExistingWork(widget.workToEdit!);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadExistingWork(WorkModel w) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    
    // Step 1
    _titleController.text = w.title;
    _descController.text = w.description ?? '';
    _icon = w.icon;
    _color = w.color;
    _isMain = w.isMain;

    // Step 2
    _baseSalaryController.text = fmt.format(w.config.baseSalary);
    _daysController.text = w.config.numberOfDayWork.toString();
    _hoursController.text = w.config.normalWorkTime.toString();
    _breakController.text = w.config.timeToEat.toString();

    // Step 3
    for (var key in _weekends.keys) {
      _weekends[key] = w.config.weekend.contains(key);
    }

    // Step 4
    if (w.config.dayWorkTime != null) {
      final pts = w.config.dayWorkTime!.split('-');
      if (pts.length == 2) {
        _dayStart = _parseTime(pts[0].trim());
        _dayEnd = _parseTime(pts[1].trim());
      }
    }
    if (w.config.nightWorkTime != null) {
      final pts = w.config.nightWorkTime!.split('-');
      if (pts.length == 2) {
        _nightStart = _parseTime(pts[0].trim());
        _nightEnd = _parseTime(pts[1].trim());
      }
    }

    // Step 5
    _dayStartWork = w.config.dayStartWork;
    _dayToSalary = w.config.dayToSalary;

    // Step 6
    _otDayController.text = w.config.percentBonusDayOvertime.toString();
    _otNightController.text = w.config.percentBonusNightOvertime.toString();
    _otWkDayController.text = w.config.percentBonusWeekendDayOvertime.toString();
    _otWkNightController.text = w.config.percentBonusWeekendNightOvertime.toString();
    _otHolDayController.text = w.config.percentBonusHolidayDayOvertime.toString();
    _otHolNightController.text = w.config.percentBonusHolidayNightOvertime.toString();

    // Step 7
    _compDayController.text = fmt.format(w.config.compensationDay);
    _compNightController.text = fmt.format(w.config.compensationNight);

    // Step 8 & 9
    _subsidies = List.from(w.config.subsidy);
    _conditionalSubsidies = List.from(w.config.conditionalSubsidies);
  }

  TimeOfDay? _parseTime(String t) {
    try {
      final p = t.split(':');
      return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
    } catch (_) {
      return null;
    }
  }

  String? _formatTime(TimeOfDay? t) {
    if (t == null) return null;
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  double _parseDouble(String val) {
    if (val.isEmpty) return 0.0;
    return double.tryParse(val) ?? 0.0;
  }

  double _parseCurrency(String val) {
    if (val.isEmpty) return 0.0;
    final numStr = val.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(numStr) ?? 0.0;
  }

  Future<void> _submit() async {
    final workProvider = context.read<WorkProvider>();
    
    final base = _parseCurrency(_baseSalaryController.text);
    final days = int.tryParse(_daysController.text) ?? 26;
    final hours = _parseDouble(_hoursController.text);
    final hourly = (days > 0 && hours > 0) ? base / days / hours : 0.0;

    final weekendList = _weekends.entries.where((e) => e.value).map((e) => e.key).toList();
    
    final dayStr = '${_formatTime(_dayStart)} - ${_formatTime(_dayEnd)}';
    final nightStr = '${_formatTime(_nightStart)} - ${_formatTime(_nightEnd)}';

    final config = WorkConfigModel(
      baseSalary: base,
      hourSalary: hourly,
      normalWorkTime: hours,
      timeToEat: _parseDouble(_breakController.text),
      weekend: weekendList,
      dayWorkTime: dayStr,
      nightWorkTime: nightStr,
      dayStartWork: _dayStartWork,
      dayToSalary: _dayToSalary,
      percentBonusDayOvertime: _parseDouble(_otDayController.text),
      percentBonusNightOvertime: _parseDouble(_otNightController.text),
      percentBonusWeekendDayOvertime: _parseDouble(_otWkDayController.text),
      percentBonusWeekendNightOvertime: _parseDouble(_otWkNightController.text),
      percentBonusHolidayDayOvertime: _parseDouble(_otHolDayController.text),
      percentBonusHolidayNightOvertime: _parseDouble(_otHolNightController.text),
      compensationDay: _parseCurrency(_compDayController.text),
      compensationNight: _parseCurrency(_compNightController.text),
      numberOfDayWork: days,
      subsidy: _subsidies,
      conditionalSubsidies: _conditionalSubsidies,
    );

    if (widget.workToEdit != null) {
      final updated = widget.workToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        icon: _icon,
        color: _color,
        isMain: _isMain,
        config: config,
      );
      await workProvider.updateWork(updated);
    } else {
      final isFirst = workProvider.works.isEmpty;
      final newWork = WorkModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        icon: _icon,
        color: _color,
        isMain: isFirst || _isMain,
        isActived: true,
        config: config,
        data: [],
        createdAt: DateTime.now(),
      );
      await workProvider.addWork(newWork);
    }

    if (mounted) Navigator.pop(context);
  }

  void _nextStep() {
    if (_currentStep == 0 && _titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên công việc')));
      return;
    }
    if (_currentStep == 1 && (_baseSalaryController.text.isEmpty || _daysController.text.isEmpty || _hoursController.text.isEmpty || _breakController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đủ thông tin tiêu chuẩn tính lương')));
      return;
    }
    if (_currentStep == 3) {
      if (_dayStart == null || _dayEnd == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ca ngày là bắt buộc. Vui lòng chọn khung giờ')));
        return;
      }
      if (_nightStart == null || _nightEnd == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ca đêm là bắt buộc. Vui lòng chọn khung giờ')));
        return;
      }
    }

    if (_currentStep < 8) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _submit();
    }
  }

  void _cancelStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chọn màu chủ đạo', style: AppTextStyles.headlineMedium(context)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16, runSpacing: 16,
              alignment: WrapAlignment.center,
              children: AppColors.workColors.keys.map((c) => GestureDetector(
                onTap: () {
                  setState(() => _color = c);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.workColors[c],
                    shape: BoxShape.circle,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chọn Icon', style: AppTextStyles.headlineMedium(context)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16, runSpacing: 16,
              alignment: WrapAlignment.center,
              children: WorkIcon.allIcons.keys.map((c) => GestureDetector(
                onTap: () {
                  setState(() => _icon = c);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.surfaceVariantDark 
                        : AppColors.surfaceVariantLight,
                    shape: BoxShape.circle,
                  ),
                  child: WorkIcon(iconName: c, color: AppColors.info),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDayPicker(String title, int? currentDay, Function(int?) onPicked) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: AppTextStyles.headlineMedium(context)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: 31,
                itemBuilder: (context, i) {
                  final day = i + 1;
                  final isSelected = currentDay == day;
                  return GestureDetector(
                    onTap: () {
                      onPicked(day);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.info 
                            : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('$day', style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                onPicked(null);
                Navigator.pop(ctx);
              },
              child: const Text('Bỏ chọn'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workToEdit == null ? 'Thêm công việc' : 'Sửa công việc'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _cancelStep,
        ),
      ),
      body: Column(
        children: [
          // Indicator
          Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(9, (index) {
                  final isReached = index <= _maxReachedStep;
                  final isActive = index == _currentStep;
                  
                  Color bgColor;
                  Color txtColor;
                  
                  if (isActive) {
                    bgColor = AppColors.info;
                    txtColor = Colors.white;
                  } else if (isReached) {
                    bgColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;
                    txtColor = isDark ? Colors.white : Colors.black;
                  } else {
                    bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
                    txtColor = isDark ? Colors.white38 : Colors.black38;
                  }

                  return GestureDetector(
                    onTap: () {
                      if (isReached) {
                        _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bgColor,
                        border: isReached && !isActive ? Border.all(color: AppColors.info.withValues(alpha: 0.5), width: 1) : null,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: txtColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() {
                _currentStep = page;
                if (page > _maxReachedStep) _maxReachedStep = page;
              }),
              children: [
                _buildPage(_buildStep1()),
                _buildPage(_buildStep2()),
                _buildPage(_buildStep3()),
                _buildPage(_buildStep4()),
                _buildPage(_buildStep5()),
                _buildPage(_buildStep6()),
                _buildPage(_buildStep7()),
                _buildPage(_buildStep8()),
                _buildPage(_buildStep9()),
              ],
            ),
          ),
          
          // Controls
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _currentStep == 8 ? 'Hoàn tất' : 'Tiếp theo',
                  style: TextStyle(
                    color: isDark ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(Widget content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: content,
    );
  }

  // --- STEPS BUILDERS ---

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thông tin cơ bản', style: AppTextStyles.headlineSmall(context)),
        const SizedBox(height: 24),
        _buildTextField('Tên công việc', _titleController, isRequired: true),
        const SizedBox(height: 16),
        _buildTextField('Mô tả', _descController),
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(
              child: _buildSelectorButton('Chọn màu sắc', () => _showColorPicker(), child: Container(
                width: 24, height: 24,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.getWorkColor(_color)),
              )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSelectorButton('Chọn Icon', () => _showIconPicker(), child: WorkIcon(iconName: _icon, color: AppColors.getWorkColor(_color))),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        SwitchListTile.adaptive(
          title: const Text('Đây là công việc chính'),
          value: _isMain,
          onChanged: (val) => setState(() => _isMain = val),
          contentPadding: EdgeInsets.zero,
          activeTrackColor: AppColors.info,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tiêu chuẩn tính lương', style: AppTextStyles.headlineSmall(context)),
        const SizedBox(height: 24),
        _buildTextField('Lương cơ bản', _baseSalaryController, isCurrency: true, isRequired: true),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('Số ngày công/tháng', _daysController, isNumber: true, isRequired: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Giờ làm/ca', _hoursController, isNumber: true, isRequired: true)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField('Thời gian nghỉ giữa ca (Giờ)', _breakController, isNumber: true, isRequired: true),
      ],
    );
  }

  Widget _buildStep3() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ngày cuối tuần', style: AppTextStyles.headlineSmall(context)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12, runSpacing: 12,
          children: _weekends.keys.map((day) {
            final isChecked = _weekends[day]!;
            return GestureDetector(
              onTap: () => setState(() => _weekends[day] = !isChecked),
              child: Container(
                width: (MediaQuery.of(context).size.width - 40 - 24) / 3, 
                height: 80,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isChecked ? AppColors.info : Colors.transparent, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Stack(
                  children: [
                    Center(child: Text(_dayNames[day]!, style: AppTextStyles.labelLarge(context).copyWith(color: isChecked ? AppColors.info : null))),
                    if (isChecked) const Positioned(top: 8, right: 8, child: Icon(Icons.check_circle, color: AppColors.info, size: 18)),
                  ],
                ),
              )
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Khung giờ ca làm', style: AppTextStyles.headlineSmall(context)),
        const SizedBox(height: 24),
        Text('Ca ngày (*)', style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTimePicker('Giờ vào', _dayStart, (t) => setState(() => _dayStart = t))),
            const SizedBox(width: 16),
            Expanded(child: _buildTimePicker('Giờ ra', _dayEnd, (t) => setState(() => _dayEnd = t))),
          ],
        ),
        const SizedBox(height: 32),
        Text('Ca đêm (*)', style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTimePicker('Giờ vào', _nightStart, (t) => setState(() => _nightStart = t))),
            const SizedBox(width: 16),
            Expanded(child: _buildTimePicker('Giờ ra', _nightEnd, (t) => setState(() => _nightEnd = t))),
          ],
        ),
      ],
    );
  }

  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chu kỳ lương (Tùy chọn)', style: AppTextStyles.headlineSmall(context)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildSelectorButton(
                'Bắt đầu làm', 
                () => _showDayPicker('Chọn ngày', _dayStartWork, (d) => setState(() => _dayStartWork = d)), 
                child: Text(_dayStartWork != null ? 'Ngày $_dayStartWork' : 'Chưa chọn', style: TextStyle(color: AppColors.info, fontWeight: FontWeight.bold))
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSelectorButton(
                'Nhận lương', 
                () => _showDayPicker('Chọn ngày', _dayToSalary, (d) => setState(() => _dayToSalary = d)), 
                child: Text(_dayToSalary != null ? 'Ngày $_dayToSalary' : 'Chưa chọn', style: TextStyle(color: AppColors.info, fontWeight: FontWeight.bold))
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep6() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hệ số tăng ca', style: AppTextStyles.headlineSmall(context)),
        const SizedBox(height: 24),
        Text('Ngày thường', style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField('Ca ngày', _otDayController, isNumber: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Ca đêm', _otNightController, isNumber: true)),
          ],
        ),
        const SizedBox(height: 24),
        Text('Cuối tuần', style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField('Ca ngày', _otWkDayController, isNumber: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Ca đêm', _otWkNightController, isNumber: true)),
          ],
        ),
        const SizedBox(height: 24),
        Text('Ngày lễ', style: AppTextStyles.labelLarge(context)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField('Ca ngày', _otHolDayController, isNumber: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Ca đêm', _otHolNightController, isNumber: true)),
          ],
        ),
      ],
    );
  }

  Widget _buildStep7() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Đền bù ca', style: AppTextStyles.headlineSmall(context)),
        const SizedBox(height: 24),
        _buildTextField('Đền bù ca ngày', _compDayController, isCurrency: true),
        const SizedBox(height: 16),
        _buildTextField('Đền bù ca đêm', _compNightController, isCurrency: true),
      ],
    );
  }

  Widget _buildStep8() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phụ cấp (Tùy chọn)', style: AppTextStyles.headlineSmall(context)),
        const SizedBox(height: 24),
        ..._subsidies.asMap().entries.map((e) {
          final idx = e.key;
          final sub = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: ListTile(
              title: Text(sub.title, style: AppTextStyles.labelLarge(context)),
              subtitle: Text('${NumberFormat('#,###', 'vi_VN').format(sub.value)} VNĐ'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: AppColors.danger),
                onPressed: () => setState(() => _subsidies.removeAt(idx)),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            onPressed: _showAddSubsidyDialog,
            icon: const Icon(Icons.add),
            label: const Text('Thêm phụ cấp'),
          ),
        ),
      ],
    );
  }

  // --- HELPERS ---

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, bool isCurrency = false, bool isRequired = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: (isNumber || isCurrency) ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        inputFormatters: isCurrency ? [CurrencyInputFormatter()] : null,
        decoration: InputDecoration(
          label: isRequired 
            ? RichText(
                text: TextSpan(
                  text: label,
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16),
                  children: const [
                    TextSpan(text: ' (*)', style: TextStyle(color: AppColors.danger)),
                  ],
                ),
              )
            : Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
          suffixText: isCurrency ? 'VNĐ' : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? time, Function(TimeOfDay) onPicked) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: time ?? const TimeOfDay(hour: 8, minute: 0));
        if (t != null) onPicked(t);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(time != null ? _formatTime(time)! : label, style: time != null ? AppTextStyles.bodyLarge(context) : AppTextStyles.bodyMedium(context)),
            const Icon(Icons.access_time, size: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSelectorButton(String label, VoidCallback onTap, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.bodySmall(context).copyWith(color: isDark ? Colors.white54 : Colors.black54)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  void _showAddSubsidyDialog() {
    final titleCtrl = TextEditingController();
    final valCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm phụ cấp cứng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('Tên phụ cấp', titleCtrl),
            const SizedBox(height: 16),
            _buildTextField('Số tiền', valCtrl, isCurrency: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && valCtrl.text.isNotEmpty) {
                setState(() {
                  _subsidies.add(SubsidyModel(
                    id: const Uuid().v4(),
                    title: titleCtrl.text,
                    value: _parseCurrency(valCtrl.text),
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep9() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phụ cấp theo ngày công (Tùy chọn)', style: AppTextStyles.headlineSmall(context)),
        const SizedBox(height: 8),
        Text('Các khoản này (đi lại, ăn trưa...) sẽ được cộng vào thu nhập mỗi ngày đi làm.', style: AppTextStyles.bodyMedium(context).copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        const SizedBox(height: 24),
        ..._conditionalSubsidies.asMap().entries.map((e) {
          final idx = e.key;
          final sub = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: ListTile(
              title: Text(sub.title, style: AppTextStyles.labelLarge(context)),
              subtitle: Text('${NumberFormat('#,###', 'vi_VN').format(sub.value)} VNĐ'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: AppColors.danger),
                onPressed: () => setState(() => _conditionalSubsidies.removeAt(idx)),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            onPressed: _showAddConditionalSubsidyDialog,
            icon: const Icon(Icons.add),
            label: const Text('Thêm phụ cấp theo điều kiện'),
          ),
        ),
      ],
    );
  }

  void _showAddConditionalSubsidyDialog() {
    final titleCtrl = TextEditingController();
    final valCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm phụ cấp theo điều kiện'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('Tên phụ cấp', titleCtrl),
            const SizedBox(height: 16),
            _buildTextField('Số tiền', valCtrl, isCurrency: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && valCtrl.text.isNotEmpty) {
                setState(() {
                  _conditionalSubsidies.add(SubsidyModel(
                    id: const Uuid().v4(),
                    title: titleCtrl.text,
                    value: _parseCurrency(valCtrl.text),
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}
