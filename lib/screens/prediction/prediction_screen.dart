import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/salary_calculator.dart';
import '../../data/models/work_model.dart';
import '../../providers/work_provider.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  WorkModel? _selectedWork;

  @override
  Widget build(BuildContext context) {
    final workProvider = context.watch<WorkProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Auto select first active work if none selected
    if (_selectedWork == null && workProvider.works.isNotEmpty) {
      _selectedWork = workProvider.mainWork ?? workProvider.works.first;
    }
    
    // Ensure selected work still exists
    if (_selectedWork != null && !workProvider.works.any((w) => w.id == _selectedWork!.id)) {
      _selectedWork = workProvider.works.isNotEmpty ? workProvider.works.first : null;
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 80,
              pinned: true,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              title: Text(
                AppStrings.predictionTitle,
                style: AppTextStyles.headlineMedium(context),
              ),
              centerTitle: false,
              actions: [
                if (workProvider.works.length > 1 && _selectedWork != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<WorkModel>(
                        value: _selectedWork,
                        items: workProvider.works.map((w) {
                          return DropdownMenuItem(
                            value: w,
                            child: Text(w.title, style: AppTextStyles.bodyMedium(context)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedWork = val);
                        },
                      ),
                    ),
                  ),
              ],
            ),
            
            if (_selectedWork == null)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Bạn chưa có công việc nào',
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),
                    _buildPredictionCards(context, _selectedWork!, isDark),
                    
                    const SizedBox(height: 32),
                    Text('Thống kê thu nhập', style: AppTextStyles.headlineMedium(context)),
                    const SizedBox(height: 16),
                    _buildStats(context, _selectedWork!, isDark),
                    
                    const SizedBox(height: 32),
                    Text('Biểu đồ thu nhập chu kỳ này', style: AppTextStyles.headlineMedium(context)),
                    const SizedBox(height: 16),
                    _buildChart(context, _selectedWork!, isDark),
                    
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCards(BuildContext context, WorkModel work, bool isDark) {
    final weekSalary = SalaryCalculator.predictWeekSalary(work);
    final monthSalary = SalaryCalculator.predictMonthSalary(work);

    return Column(
      children: [
        _buildPredCard(
          context,
          'Dự đoán tuần này',
          WorklyDateUtils.formatCurrency(weekSalary),
          Icons.auto_graph_rounded,
          AppColors.info,
          isDark,
        ),
        const SizedBox(height: 16),
        _buildPredCard(
          context,
          'Dự đoán chu kỳ 30 ngày',
          WorklyDateUtils.formatCurrency(monthSalary),
          Icons.account_balance_wallet_rounded,
          AppColors.success,
          isDark,
        ),
      ],
    );
  }

  Widget _buildPredCard(BuildContext context, String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
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
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodyLarge(context)),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: AppTextStyles.displayMedium(context).copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, WorkModel work, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
      child: Column(
        children: [
          _buildStatRow(
            context, 
            'Trung bình mỗi giờ', 
            WorklyDateUtils.formatCurrency(SalaryCalculator.averageHourlySalary(work)), 
            isDark,
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            context, 
            'Trung bình mỗi ngày', 
            WorklyDateUtils.formatCurrency(SalaryCalculator.averageDailySalary(work)), 
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.headlineSmall(context),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context, WorkModel work, bool isDark) {
    final now = DateTime.now();
    final cycle = SalaryCalculator.getSalaryCycle(work, now);
    final dailyIncome = SalaryCalculator.dailyIncomeCycle(work, cycle);
    
    if (dailyIncome.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
        ),
        child: const Center(
          child: Text('Chưa có dữ liệu để vẽ biểu đồ'),
        ),
      );
    }

    final spots = <FlSpot>[];
    double maxIncome = 0;
    for (int i = 0; i < dailyIncome.length; i++) {
      final value = dailyIncome[i].value;
      if (value > maxIncome) maxIncome = value;
      spots.add(FlSpot(i.toDouble() + 1, value));
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = (spot.x - 1).toInt();
                  if (index < 0 || index >= dailyIncome.length) return null;
                  final day = dailyIncome[index].key;
                  return LineTooltipItem(
                    'Ngày ${WorklyDateUtils.formatDateShort(day)}\n${WorklyDateUtils.formatCurrency(spot.y.roundToDouble())}',
                    AppTextStyles.bodyMedium(context).copyWith(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxIncome > 0 ? (maxIncome / 5).clamp(1.0, double.infinity) : 100000,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? Colors.white24 : Colors.black12,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      value.toInt().toString(),
                      style: AppTextStyles.caption(context),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '${(value / 1000000).toStringAsFixed(1)}M',
                      style: AppTextStyles.caption(context),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 1,
          maxX: dailyIncome.length.toDouble(),
          minY: 0,
          maxY: maxIncome > 0 ? maxIncome * 1.2 : 500000,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.getWorkColor(work.color),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.getWorkColor(work.color).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
