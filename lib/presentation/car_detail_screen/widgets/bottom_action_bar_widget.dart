import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class BottomActionBarWidget extends StatelessWidget {
  final double pricePerDay;
  final bool isAvailable;
  final VoidCallback? onReserve;

  const BottomActionBarWidget({
    super.key,
    required this.pricePerDay,
    required this.isAvailable,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(top: BorderSide(color: AppTheme.outlineDark, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(102),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Price column
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prix total estimé',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTheme.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${pricePerDay.toStringAsFixed(0)} TND/j',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentLight,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Reserve button
          Expanded(
            child: ElevatedButton(
              onPressed: onReserve,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable
                    ? AppTheme.primary
                    : AppTheme.surfaceVariantDark,
                foregroundColor: isAvailable
                    ? Colors.white
                    : AppTheme.onSurfaceMuted,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: isAvailable ? 0 : 0,
              ),
              child: Text(
                isAvailable ? 'Réserver Maintenant' : 'Non disponible',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Calendar quick action
          GestureDetector(
            onTap: onReserve,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(38),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primary.withAlpha(102),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
