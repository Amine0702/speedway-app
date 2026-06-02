import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class ReservationDatesWidget extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<DateTimeRange> bookedRanges; // ← NEW
  final bool isLoadingDates;              // ← NEW
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;

  const ReservationDatesWidget({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    this.bookedRanges = const [],
    this.isLoadingDates = false,
  });

  // Returns true if a given day overlaps any booked range.
  bool _isBooked(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    for (final r in bookedRanges) {
      final s = DateTime(r.start.year, r.start.month, r.start.day);
      final e = DateTime(r.end.year, r.end.month, r.end.day);
      if (!d.isBefore(s) && !d.isAfter(e)) return true;
    }
    return false;
  }

  // Returns true if every day in [from, to] is free.
  bool _rangeIsFree(DateTime from, DateTime to) {
    DateTime cur = from;
    while (!cur.isAfter(to)) {
      if (_isBooked(cur)) return false;
      cur = cur.add(const Duration(days: 1));
    }
    return true;
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final initial = isStart
        ? (startDate ?? now)
        : (endDate ?? (startDate ?? now).add(const Duration(days: 1)));
    final first = isStart
        ? now
        : (startDate ?? now).add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
      selectableDayPredicate: (day) {
        if (_isBooked(day)) return false;
        // For end-date: the whole range must be free
        if (!isStart && startDate != null && day.isAfter(startDate!)) {
          return _rangeIsFree(startDate!.add(const Duration(days: 1)), day);
        }
        return true;
      },
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            onPrimary: Colors.white,
            surface: AppTheme.surfaceElevated,
            onSurface: AppTheme.onSurfaceDark,
          ),
          dialogTheme: DialogThemeData(backgroundColor: AppTheme.surfaceDark),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      if (isStart) {
        onStartDateChanged(picked);
      } else {
        onEndDateChanged(picked);
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sélectionner';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  int get _totalDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays.clamp(1, 365);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: AppTheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Dates de location',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceDark,
                ),
              ),
              if (_totalDays > 0) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(38),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primary.withAlpha(102)),
                  ),
                  child: Text(
                    '$_totalDays jour${_totalDays > 1 ? 's' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // ── Availability loading indicator ───────────────────────────────────
          if (isLoadingDates) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    color: AppTheme.primary,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Chargement des disponibilités…',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ],

          // ── Booked ranges chips ──────────────────────────────────────────────
          if (!isLoadingDates && bookedRanges.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.errorSurface.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.errorSurface.withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.event_busy_rounded,
                        color: AppTheme.errorSurface,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Dates déjà réservées :',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.errorSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: bookedRanges.map((r) {
                      final s = _formatDate(r.start);
                      final e = _formatDate(r.end);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorSurface.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.errorSurface.withAlpha(100),
                          ),
                        ),
                        child: Text(
                          '$s → $e',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.errorSurface,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ces dates sont grisées dans le calendrier.',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Available confirmation banner ────────────────────────────────────
          if (!isLoadingDates && bookedRanges.isEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.success.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.success.withAlpha(64)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_available_rounded,
                    color: AppTheme.success,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ce véhicule est entièrement disponible.',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ── Date pickers ─────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _DatePickerButton(
                  label: 'Date de début *',
                  value: _formatDate(startDate),
                  icon: Icons.flight_takeoff_rounded,
                  isSet: startDate != null,
                  onTap: () => _pickDate(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DatePickerButton(
                  label: 'Date de fin *',
                  value: _formatDate(endDate),
                  icon: Icons.flight_land_rounded,
                  isSet: endDate != null,
                  onTap: () => _pickDate(context, false),
                ),
              ),
            ],
          ),
          if (startDate != null && endDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.success.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.success.withAlpha(64)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppTheme.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Du ${_formatDate(startDate)} au ${_formatDate(endDate)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isSet;
  final VoidCallback onTap;

  const _DatePickerButton({
    required this.label,
    required this.value,
    required this.icon,
    required this.isSet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: AppTheme.primary.withAlpha(26),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariantDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSet ? AppTheme.primary.withAlpha(128) : AppTheme.outlineDark,
            width: isSet ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppTheme.onSurfaceMuted,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSet ? AppTheme.primary : AppTheme.onSurfaceMuted,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: isSet ? FontWeight.w600 : FontWeight.w400,
                      color: isSet ? AppTheme.onSurfaceDark : AppTheme.onSurfaceMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
