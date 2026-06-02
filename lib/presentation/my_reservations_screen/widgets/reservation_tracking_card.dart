import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class ReservationTrackingCard extends StatelessWidget {
  final Map<String, dynamic> reservation;
  final int index;

  const ReservationTrackingCard({
    super.key,
    required this.reservation,
    required this.index,
  });

  // ── Status config ──────────────────────────────────────────────────────────

  static const Map<String, _StatusConfig> _statusConfig = {
    'PENDING': _StatusConfig(
      label: 'En attente',
      icon: Icons.hourglass_top_rounded,
      color: Color(0xFFD97706),
      surface: Color(0xFF78350F),
      step: 1,
    ),
    'CONFIRMED': _StatusConfig(
      label: 'Confirmée',
      icon: Icons.check_circle_rounded,
      color: Color(0xFF16A34A),
      surface: Color(0xFF14532D),
      step: 2,
    ),
    'COMPLETED': _StatusConfig(
      label: 'Terminée',
      icon: Icons.flag_rounded,
      color: Color(0xFF2563EB),
      surface: Color(0xFF1D3461),
      step: 3,
    ),
    'CANCELLED': _StatusConfig(
      label: 'Annulée',
      icon: Icons.cancel_rounded,
      color: Color(0xFFDC2626),
      surface: Color(0xFF7F1D1D),
      step: -1,
    ),
  };

  _StatusConfig get _cfg =>
      _statusConfig[reservation['status']] ?? _statusConfig['PENDING']!;

  // ── Date formatter (sans intl) ─────────────────────────────────────────────

  static const _months = [
    '',
    'Jan',
    'Fév',
    'Mar',
    'Avr',
    'Mai',
    'Juin',
    'Juil',
    'Aoû',
    'Sep',
    'Oct',
    'Nov',
    'Déc',
  ];

  String _formatDate(dynamic raw) {
    if (raw == null) return '—';
    try {
      final d = DateTime.parse(raw.toString());
      return '${d.day.toString().padLeft(2, '0')} ${_months[d.month]} ${d.year}';
    } catch (_) {
      return raw.toString();
    }
  }

  String _formatPrice(dynamic v) {
    if (v == null) return '—';
    final n = v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    return '${n.toStringAsFixed(0)} TND';
  }

  int _totalDays() {
    try {
      final s = DateTime.parse(reservation['startDate'].toString());
      final e = DateTime.parse(reservation['endDate'].toString());
      return e.difference(s).inDays.clamp(1, 365);
    } catch (_) {
      return 1;
    }
  }

  String _shortId() {
    final id = reservation['id']?.toString() ?? '';
    return id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
  }

  String _carLabel() {
    // Backend returns carId (UUID string), not a nested car object
    final carId = reservation['carId']?.toString() ?? '';
    if (carId.length >= 6)
      return 'Voiture #${carId.substring(0, 6).toUpperCase()}';
    return 'Voiture';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cfg = _cfg;
    final status = reservation['status']?.toString() ?? 'PENDING';
    final isCancelled = status == 'CANCELLED';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cfg.color.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cfg.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.directions_car_filled_rounded,
                    color: cfg.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _carLabel(),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurfaceDark,
                        ),
                      ),
                      Text(
                        'Réf. ${_shortId()}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: cfg.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cfg.icon, color: cfg.color, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        cfg.label,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cfg.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Progress tracker ──────────────────────────────────────────────
          if (!isCancelled)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: _buildProgressTracker(cfg),
            ),

          // ── Divider ───────────────────────────────────────────────────────
          const Divider(height: 1, color: Color(0xFF2A2A2A)),

          // ── Info ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _chip(
                      Icons.calendar_today_rounded,
                      _formatDate(reservation['startDate']),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppTheme.onSurfaceMuted,
                      ),
                    ),
                    _chip(
                      Icons.event_rounded,
                      _formatDate(reservation['endDate']),
                    ),
                    const Spacer(),
                    _chip(Icons.access_time_rounded, '${_totalDays()}j'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _chip(
                      Icons.location_on_rounded,
                      reservation['pickupLocation']?.toString() ?? '—',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.onSurfaceMuted,
                      ),
                    ),
                    Text(
                      _formatPrice(reservation['totalPrice']),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Cancelled bar ─────────────────────────────────────────────────
          if (isCancelled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0x337F1D1D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.error,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Réservation annulée',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.error,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Progress tracker ───────────────────────────────────────────────────────

  Widget _buildProgressTracker(_StatusConfig cfg) {
    final step = cfg.step;
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          _dot(
            Icons.hourglass_top_rounded,
            'En attente',
            step >= 1,
            step == 1 ? const Color(0xFFD97706) : AppTheme.success,
          ),
          Expanded(child: _line(step >= 2)),
          _dot(
            Icons.check_circle_outline_rounded,
            'Confirmée',
            step >= 2,
            AppTheme.success,
          ),
          Expanded(child: _line(step >= 3)),
          _dot(Icons.flag_rounded, 'Terminée', step >= 3, AppTheme.primary),
        ],
      ),
    );
  }

  Widget _dot(IconData icon, String label, bool active, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: active
                ? color.withOpacity(0.15)
                : AppTheme.surfaceVariantDark,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? color : AppTheme.outlineDark,
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 14,
            color: active ? color : AppTheme.onSurfaceMuted,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? color : AppTheme.onSurfaceMuted,
          ),
        ),
      ],
    );
  }

  Widget _line(bool filled) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: filled ? AppTheme.success : AppTheme.outlineDark,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // ── Info chip ──────────────────────────────────────────────────────────────

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariantDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.onSurfaceMuted),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.onSurfaceDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status config model ────────────────────────────────────────────────────

class _StatusConfig {
  final String label;
  final IconData icon;
  final Color color;
  final Color surface;
  final int step;
  const _StatusConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.surface,
    required this.step,
  });
}
