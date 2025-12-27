import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../providers/data_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Календарь', style: AppTextStyles.heading1),
            ),
            _buildMonthNavigation(),
            _buildWeekDays(),
            _buildCalendarGrid(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildAssignmentsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy', 'ru').format(_currentMonth),
            style: AppTextStyles.heading3,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    final weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays
            .map((day) => SizedBox(
                  width: 40,
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Consumer<DataProvider>(
      builder: (context, provider, _) {
        final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
        final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
        
        // Adjust for Monday start
        int startWeekday = firstDayOfMonth.weekday - 1;
        if (startWeekday < 0) startWeekday = 6;

        final days = <Widget>[];

        // Empty cells for days before the first day of the month
        for (int i = 0; i < startWeekday; i++) {
          days.add(const SizedBox(width: 40, height: 40));
        }

        // Days of the month
        for (int day = 1; day <= lastDayOfMonth.day; day++) {
          final date = DateTime(_currentMonth.year, _currentMonth.month, day);
          final assignments = provider.getAssignmentsForDate(date);
          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isSameDay(date, DateTime.now());

          days.add(_buildDayCell(date, day, isSelected, isToday, assignments));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            alignment: WrapAlignment.start,
            children: days,
          ),
        );
      },
    );
  }

  Widget _buildDayCell(
    DateTime date,
    int day,
    bool isSelected,
    bool isToday,
    List<Assignment> assignments,
  ) {
    Color? dotColor;
    if (assignments.isNotEmpty) {
      final hasConfirmed = assignments.any((a) => a.status == AssignmentStatus.confirmed);
      final hasPending = assignments.any((a) => a.status == AssignmentStatus.pending);
      final hasCompleted = assignments.any((a) => a.status == AssignmentStatus.completed);

      if (hasConfirmed) {
        dotColor = AppColors.success;
      } else if (hasPending) {
        dotColor = AppColors.warning;
      } else if (hasCompleted) {
        dotColor = AppColors.textMuted;
      }
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple
              : isToday
                  ? AppColors.primaryPurple.withValues(alpha: 0.2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primaryPurple)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (dotColor != null)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsList() {
    return Consumer<DataProvider>(
      builder: (context, provider, _) {
        final assignments = provider.getAssignmentsForDate(_selectedDate);

        if (provider.isLoadingAssignments && provider.assignments.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryPurple),
          );
        }

        if (assignments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 48, color: AppColors.textMuted),
                const SizedBox(height: 12),
                Text(
                  'Нет назначений на ${DateFormat('d MMMM', 'ru').format(_selectedDate)}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: assignments.length,
          itemBuilder: (context, index) {
            return _AssignmentCard(assignment: assignments[index]);
          },
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;

  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  assignment.jobTitle,
                  style: AppTextStyles.heading3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusChip(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            assignment.role,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryPurple),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${assignment.venueName}, ${assignment.city}',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                _formatTimeRange(),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          if (assignment.dressCode != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.checkroom, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  assignment.dressCode!,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.payments_outlined, size: 16, color: AppColors.primaryPurple),
              const SizedBox(width: 4),
              Text(
                '${assignment.confirmedRate} ${assignment.rateCurrency}/hr',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    IconData icon;

    switch (assignment.status) {
      case AssignmentStatus.pending:
        color = AppColors.warning;
        icon = Icons.hourglass_empty;
        break;
      case AssignmentStatus.confirmed:
        color = AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      case AssignmentStatus.checkedIn:
        color = AppColors.info;
        icon = Icons.login;
        break;
      case AssignmentStatus.completed:
        color = AppColors.textMuted;
        icon = Icons.done_all;
        break;
      case AssignmentStatus.noShow:
        color = AppColors.error;
        icon = Icons.person_off;
        break;
      case AssignmentStatus.cancelled:
        color = AppColors.error;
        icon = Icons.cancel_outlined;
        break;
    }

    return StatusChip(
      text: assignment.status.displayName,
      color: color,
      icon: icon,
    );
  }

  String _formatTimeRange() {
    try {
      final start = DateTime.parse(assignment.scheduledStart);
      final end = DateTime.parse(assignment.scheduledEnd);
      final formatter = DateFormat('HH:mm');
      return '${formatter.format(start)} - ${formatter.format(end)}';
    } catch (_) {
      return '';
    }
  }
}
