import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class ReservationPersonalInfoWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;

  const ReservationPersonalInfoWidget({
    super.key,
    required this.nameController,
    required this.phoneController,
  });

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
          Row(
            children: [
              const Icon(
                Icons.person_rounded,
                color: AppTheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Informations personnelles',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Full Name
          _buildField(
            controller: nameController,
            label: 'Nom complet *',
            hint: 'Ex: Mohamed Ben Ali',
            icon: Icons.badge_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Nom requis';
              if (v.trim().length < 3) return 'Nom trop court';
              return null;
            },
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 12),
          // Phone
          _buildField(
            controller: phoneController,
            label: 'Téléphone *',
            hint: '+216 XX XXX XXX',
            icon: Icons.phone_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Téléphone requis';
              if (v.trim().length < 8) return 'Numéro invalide';
              return null;
            },
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.onSurfaceDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: AppTheme.onSurfaceMuted,
        ),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: AppTheme.onSurfaceMuted,
        ),
        prefixIcon: Icon(icon, color: AppTheme.onSurfaceMuted, size: 18),
        filled: true,
        fillColor: AppTheme.surfaceVariantDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.outlineDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.outlineDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: validator,
    );
  }
}
