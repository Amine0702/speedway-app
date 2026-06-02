import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_theme.dart';

class ReservationCarSummaryWidget extends StatelessWidget {
  final Map<String, dynamic> car;
  final int totalDays;
  final double totalPrice;

  const ReservationCarSummaryWidget({
    super.key,
    required this.car,
    required this.totalDays,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary.withAlpha(51), AppTheme.surfaceDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primary.withAlpha(77), width: 1),
      ),
      child: Row(
        children: [
          // Car thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(17),
              bottomLeft: Radius.circular(17),
            ),
            child: CachedNetworkImage(
              imageUrl: car['imageUrl'] as String? ?? '',
              width: 120,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 120,
                height: 100,
                color: AppTheme.surfaceVariantDark,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 120,
                height: 100,
                color: AppTheme.surfaceVariantDark,
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: AppTheme.onSurfaceMuted,
                ),
              ),
            ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${car['brand'] ?? ''} ${car['model'] ?? ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurfaceDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalDays jour${totalDays > 1 ? 's' : ''} × ${(car['pricePerDay'] as double? ?? 0).toStringAsFixed(0)} TND',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${totalPrice.toStringAsFixed(0)} TND',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accentLight,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
