import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class DetailSpecsWidget extends StatelessWidget {
  final Map<String, dynamic> car;

  const DetailSpecsWidget({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final specs = [
      (
        Icons.calendar_today_rounded,
        'Année',
        '${car['year'] ?? 2022}',
        AppTheme.primary,
      ),
      (
        Icons.settings_rounded,
        'Transmission',
        car['transmission'] as String? ?? 'Manuelle',
        AppTheme.accent,
      ),
      (
        Icons.local_gas_station_rounded,
        'Carburant',
        car['fuel'] as String? ?? 'Essence',
        AppTheme.success,
      ),
      (
        Icons.people_rounded,
        'Places',
        '${car['seats'] ?? 5}',
        Color(0xFF8B5CF6),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Caractéristiques',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurfaceDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: specs.map((spec) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: spec == specs.last ? 0 : 10),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: spec.$4.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: spec.$4.withAlpha(64), width: 1),
                  ),
                  child: Column(
                    children: [
                      Icon(spec.$1, color: spec.$4, size: 22),
                      const SizedBox(height: 6),
                      Text(
                        spec.$3,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurfaceDark,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        spec.$2,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppTheme.onSurfaceMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
