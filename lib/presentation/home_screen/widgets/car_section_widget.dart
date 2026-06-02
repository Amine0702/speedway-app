import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';
import './car_card_widget.dart';

class CarSectionWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> cars;
  final ValueChanged<Map<String, dynamic>> onCarTap;

  const CarSectionWidget({
    super.key,
    required this.title,
    required this.cars,
    required this.onCarTap,
  });

  @override
  Widget build(BuildContext context) {
    if (cars.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceDark,
                ),
              ),
              const Spacer(),
              Text(
                'Voir tout',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.primary,
                size: 18,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < cars.length - 1 ? 12 : 0,
                ),
                child: CarCardWidget(
                  car: cars[index],
                  onTap: () => onCarTap(cars[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
