import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_theme.dart';

class ReservationNationalityWidget extends StatelessWidget {
  final String nationality;
  final TextEditingController documentNumberController;
  final String? documentImagePath;
  final ValueChanged<String> onNationalityChanged;
  final ValueChanged<String?> onDocumentImagePicked;

  const ReservationNationalityWidget({
    super.key,
    required this.nationality,
    required this.documentNumberController,
    required this.documentImagePath,
    required this.onNationalityChanged,
    required this.onDocumentImagePicked,
  });

  bool get _isTunisian => nationality == 'Tunisian';

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
                Icons.public_rounded,
                color: AppTheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Nationalité & Document',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Nationality toggle
          Row(
            children: [
              Expanded(
                child: _NationalityOption(
                  label: '🇹🇳 Tunisien',
                  isSelected: _isTunisian,
                  onTap: () => onNationalityChanged('Tunisian'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NationalityOption(
                  label: '✈️ Touriste',
                  isSelected: !_isTunisian,
                  onTap: () => onNationalityChanged('Tourist'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Conditional document fields
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _isTunisian
                ? _DocumentSection(
                    key: const ValueKey('tunisian'),
                    numberController: documentNumberController,
                    numberLabel: 'Numéro CIN *',
                    numberHint: 'Ex: 12345678',
                    photoLabel: 'Photo CIN *',
                    documentImagePath: documentImagePath,
                    onImagePicked: onDocumentImagePicked,
                    icon: Icons.credit_card_rounded,
                  )
                : _DocumentSection(
                    key: const ValueKey('tourist'),
                    numberController: documentNumberController,
                    numberLabel: 'Numéro de passeport *',
                    numberHint: 'Ex: AB1234567',
                    photoLabel: 'Photo passeport *',
                    documentImagePath: documentImagePath,
                    onImagePicked: onDocumentImagePicked,
                    icon: Icons.book_rounded,
                  ),
          ),
        ],
      ),
    );
  }
}

class _NationalityOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NationalityOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withAlpha(38)
              : AppTheme.surfaceVariantDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.outlineDark,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? AppTheme.primary : AppTheme.onSurfaceMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentSection extends StatelessWidget {
  final TextEditingController numberController;
  final String numberLabel;
  final String numberHint;
  final String photoLabel;
  final String? documentImagePath;
  final ValueChanged<String?> onImagePicked;
  final IconData icon;

  const _DocumentSection({
    super.key,
    required this.numberController,
    required this.numberLabel,
    required this.numberHint,
    required this.photoLabel,
    required this.documentImagePath,
    required this.onImagePicked,
    required this.icon,
  });

  // ✅ FIX: Real image picker using image_picker package
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (pickedFile != null) {
        onImagePicked(pickedFile.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Impossible d\'accéder à la ${source == ImageSource.camera ? 'caméra' : 'galerie'}. Vérifiez les permissions.',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: AppTheme.errorSurface,
          ),
        );
      }
    }
  }

  void _showPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
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
              'Ajouter une photo',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceDark,
              ),
            ),
            const SizedBox(height: 16),
            _UploadOption(
              icon: Icons.photo_library_rounded,
              label: 'Galerie photos',
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
            _UploadOption(
              icon: Icons.camera_alt_rounded,
              label: 'Prendre une photo',
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
            // Option to remove existing photo
            if (documentImagePath != null) ...[
              const SizedBox(height: 8),
              _UploadOption(
                icon: Icons.delete_outline_rounded,
                label: 'Supprimer la photo',
                onTap: () {
                  Navigator.pop(context);
                  onImagePicked(null);
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Document number field
        TextFormField(
          controller: numberController,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.onSurfaceDark,
          ),
          decoration: InputDecoration(
            labelText: numberLabel,
            labelStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.onSurfaceMuted,
            ),
            hintText: numberHint,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Numéro de document requis';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        // ✅ FIX: Photo upload area with real preview
        GestureDetector(
          onTap: () => _showPickerSheet(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            decoration: BoxDecoration(
              color: documentImagePath != null
                  ? AppTheme.success.withAlpha(20)
                  : AppTheme.surfaceVariantDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: documentImagePath != null
                    ? AppTheme.success.withAlpha(128)
                    : AppTheme.outlineDark,
                width: documentImagePath != null ? 1.5 : 1,
              ),
            ),
            child: documentImagePath != null
                // ✅ Show real image preview when photo is picked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(11),
                        ),
                        child: Image.file(
                          File(documentImagePath!),
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.success,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Photo ajoutée — appuyez pour changer',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppTheme.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                // Show upload prompt when no photo
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.upload_file_rounded,
                            color: AppTheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                photoLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.onSurfaceDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'JPG, PNG — max 5MB',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppTheme.onSurfaceMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.onSurfaceMuted,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UploadOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: AppTheme.primary.withAlpha(26),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariantDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.outlineDark, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.onSurfaceDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
