import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../shared/models/vehicle.dart';
import '../../shared/repositories/visit_repository.dart';
import '../../shared/widgets/vehicle_card.dart' show VehicleImage;

const _timeSlots = ['09:00', '10:30', '12:00', '14:00'];

class ScheduleVisitScreen extends StatefulWidget { final Vehicle car; final VisitRepository repository; ScheduleVisitScreen({ super.key, required this.car, VisitRepository? repository, }) : repository = repository ?? VisitRepository(); @override State<ScheduleVisitScreen> createState() => _ScheduleVisitScreenState(); }

class _ScheduleVisitScreenState extends State<ScheduleVisitScreen> {
  static const _locale = 'es';

  late final DateTime _firstDay;
  late final DateTime _lastDay;
  late DateTime _focusedDay;

  DateTime? _selectedDay;
  String? _selectedSlot;
  bool _isSubmitting = false;

  bool get _canRequest =>
      _selectedDay != null && _selectedSlot != null && !_isSubmitting;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _firstDay = DateTime(now.year, now.month, now.day);
    _lastDay = DateTime(now.year, now.month + 3, now.day);
    _focusedDay = _firstDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  Future<void> _requestVisit() async {
    final day = _selectedDay!;
    final slot = _selectedSlot!;
    final [hour, minute] = slot.split(':').map(int.parse).toList();
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSubmitting = true);
    try {
      await widget.repository.requestVisit(
        clientId: currentClientId,
        car: widget.car,
        dateTime: DateTime(day.year, day.month, day.day, hour, minute),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No pudimos enviar la solicitud')),
      );
      return;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }

    final date = DateFormat.MMMMd(_locale).format(day);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Solicitud enviada: $date a las $slot. '
          'Te avisaremos cuando sea confirmada.',
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _selectedDay = null;
        _selectedSlot = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Agendá tu visita')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _CarSummary(car: widget.car),
          const SizedBox(height: 24),
          const _SectionTitle('Fecha'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TableCalendar<void>(
              locale: _locale,
              firstDay: _firstDay,
              lastDay: _lastDay,
              focusedDay: _focusedDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              headerStyle: _headerStyle(theme),
              daysOfWeekStyle: _daysOfWeekStyle(theme),
              calendarStyle: _calendarStyle(theme),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Horario'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final slot in _timeSlots)
                _TimeSlotChip(
                  label: slot,
                  selected: slot == _selectedSlot,
                  onSelected: () => setState(() => _selectedSlot = slot),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _PendingNotice(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _canRequest ? _requestVisit : null,
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Solicitar visita'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  HeaderStyle _headerStyle(ThemeData theme) {
    return HeaderStyle(
      formatButtonVisible: false,
      titleCentered: true,
      // Spanish month names come lowercase ("octubre de 2026").
      titleTextFormatter: (date, locale) =>
          toBeginningOfSentenceCase(DateFormat.yMMMM(locale).format(date)),
      titleTextStyle: theme.textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.w600,
      ),
      leftChevronIcon: Icon(
        Icons.chevron_left,
        color: theme.colorScheme.primary,
      ),
      rightChevronIcon: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.primary,
      ),
    );
  }

  DaysOfWeekStyle _daysOfWeekStyle(ThemeData theme) {
    final style = theme.textTheme.bodySmall!.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      fontWeight: FontWeight.w600,
    );

    return DaysOfWeekStyle(
      weekdayStyle: style,
      weekendStyle: style,
      dowTextFormatter: (date, locale) =>
          toBeginningOfSentenceCase(DateFormat.E(locale).format(date)),
    );
  }

  CalendarStyle _calendarStyle(ThemeData theme) {
    final colors = theme.colorScheme;
    final dayStyle = TextStyle(color: colors.onSurface);

    return CalendarStyle(
      outsideDaysVisible: false,
      defaultTextStyle: dayStyle,
      weekendTextStyle: dayStyle,
      disabledTextStyle: TextStyle(
        color: colors.onSurface.withValues(alpha: 0.25),
      ),
      todayDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.primary),
      ),
      todayTextStyle: TextStyle(
        color: colors.primary,
        fontWeight: FontWeight.w700,
      ),
      selectedDecoration: BoxDecoration(
        color: colors.primary,
        shape: BoxShape.circle,
      ),
      selectedTextStyle: TextStyle(
        color: colors.onPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _CarSummary extends StatelessWidget {
  final Vehicle car;

  const _CarSummary({required this.car});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: VehicleImage(
              url: car.imageUrl,
              height: 76,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${car.year}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _PendingNotice extends StatelessWidget {
  const _PendingNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Row(
      children: [
        Icon(Icons.schedule, size: 18, color: mutedColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Un asesor revisará tu solicitud y te confirmará la visita.',
            style: theme.textTheme.bodySmall?.copyWith(color: mutedColor),
          ),
        ),
      ],
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _TimeSlotChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      backgroundColor: colors.surface,
      selectedColor: colors.primary,
      side: BorderSide(color: selected ? colors.primary : theme.dividerColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: theme.textTheme.bodyLarge?.copyWith(
        color: selected ? colors.onPrimary : colors.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
