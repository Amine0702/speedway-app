import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class HomeHeaderWidget extends StatelessWidget {
  final String selectedLanguage;
  final bool isDarkTheme;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onThemeToggle;
  final VoidCallback onSearchTap;

  const HomeHeaderWidget({
    super.key,
    required this.selectedLanguage,
    required this.isDarkTheme,
    required this.onLanguageChanged,
    required this.onThemeToggle,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          // Logo
          Image.asset(
            'assets/images/logo.png',
            height: 36,
          ),
          const Spacer(),
          _LanguageSelector(
            selected: selectedLanguage,
            onChanged: onLanguageChanged,
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onThemeToggle,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.outlineDark, width: 1),
              ),
              child: Icon(
                isDarkTheme
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: AppTheme.onSurfaceMuted,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.outlineDark, width: 1),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppTheme.onSurfaceMuted,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _LanguageSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLanguagePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariantDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_flag(selected), style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              selected,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.primary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  String _flag(String lang) {
    switch (lang) {
      case 'FR':
        return '🇫🇷';
      case 'EN':
        return '🇬🇧';
      case 'AR':
        return '🇹🇳';
      default:
        return '🌐';
    }
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            const SizedBox(height: 20),
            Text(
              'Choisir la langue',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceDark,
              ),
            ),
            const SizedBox(height: 16),
            for (final lang in [
              ('FR', '🇫🇷', 'Français'),
              ('EN', '🇬🇧', 'English'),
              ('AR', '🇹🇳', 'العربية'),
            ])
              _LanguageOption(
                flag: lang.$2,
                code: lang.$1,
                label: lang.$3,
                isSelected: selected == lang.$1,
                onTap: () {
                  onChanged(lang.$1);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag, code, label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.code,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withAlpha(38)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.outlineDark,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.primary : AppTheme.onSurfaceDark,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
