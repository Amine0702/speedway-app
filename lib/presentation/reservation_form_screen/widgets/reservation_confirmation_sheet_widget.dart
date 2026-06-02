import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class ReservationConfirmationSheetWidget extends StatefulWidget {
  final Map<String, dynamic> car;
  final String fullName;
  final String phone;
  final String permitNumber;
  final String mileage;
  final String deposit;
  final DateTime startDate;
  final DateTime endDate;
  final String pickupLocation;
  final String nationality;
  final int totalDays;
  final double totalPrice;
  final VoidCallback onConfirmPayment;

  const ReservationConfirmationSheetWidget({
    super.key,
    required this.car,
    required this.fullName,
    required this.phone,
    required this.permitNumber,
    required this.mileage,
    required this.deposit,
    required this.startDate,
    required this.endDate,
    required this.pickupLocation,
    required this.nationality,
    required this.totalDays,
    required this.totalPrice,
    required this.onConfirmPayment,
  });

  @override
  State<ReservationConfirmationSheetWidget> createState() =>
      _ReservationConfirmationSheetWidgetState();
}

class _ReservationConfirmationSheetWidgetState
    extends State<ReservationConfirmationSheetWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Confirmer la réservation',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Vérifiez les détails avant de confirmer',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariantDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outlineDark, width: 1),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      icon: Icons.directions_car_rounded,
                      label: 'Véhicule',
                      value: '${widget.car['brand']} ${widget.car['model']}',
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.person_rounded,
                      label: 'Locataire',
                      value: widget.fullName,
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.phone_rounded,
                      label: 'Téléphone',
                      value: widget.phone,
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.badge_rounded,
                      label: 'Permis',
                      value: widget.permitNumber,
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.speed_rounded,
                      label: 'Kilométrage',
                      value: '${widget.mileage} km',
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.money_rounded,
                      label: 'Cautionnement',
                      value: '${widget.deposit} TND',
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Début',
                      value: _formatDate(widget.startDate),
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.event_rounded,
                      label: 'Fin',
                      value: _formatDate(widget.endDate),
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.location_on_rounded,
                      label: 'Lieu',
                      value: widget.pickupLocation,
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.public_rounded,
                      label: 'Nationalité',
                      value: widget.nationality == 'Tunisian'
                          ? '🇹🇳 Tunisien'
                          : '✈️ Touriste',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppTheme.outlineDark, height: 1),
                    ),
                    Row(
                      children: [
                        Text(
                          'Total (${widget.totalDays}j)',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceDark,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${widget.totalPrice.toStringAsFixed(0)} TND',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.accentLight,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Cash payment notice
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.success.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.success.withAlpha(51)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payments_rounded,
                      color: AppTheme.success,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Paiement en espèces à la prise en charge du véhicule.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.onSurfaceMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onConfirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    'Confirmer — ${widget.totalPrice.toStringAsFixed(0)} TND Cash',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Annuler',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 16),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppTheme.onSurfaceMuted,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceDark,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
