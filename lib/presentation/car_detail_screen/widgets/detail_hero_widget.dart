import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_theme.dart';

class DetailHeroWidget extends StatelessWidget {
  final List<String> imageUrls;
  final String semanticLabel;
  final String carId;
  final bool isBookmarked;
  final VoidCallback onBack;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final ValueChanged<int> onPageChanged;
  final int currentIndex;

  const DetailHeroWidget({
    super.key,
    required this.imageUrls,
    required this.semanticLabel,
    required this.carId,
    required this.isBookmarked,
    required this.onBack,
    required this.onBookmark,
    required this.onShare,
    required this.onPageChanged,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          // Image carousel
          Hero(
            tag: 'car-card-$carId',
            child: PageView.builder(
              onPageChanged: onPageChanged,
              itemCount: imageUrls.length,
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: imageUrls[i],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 320,
                placeholder: (_, __) =>
                    Container(color: AppTheme.surfaceVariantDark),
                errorWidget: (_, __, ___) => Container(
                  color: AppTheme.surfaceVariantDark,
                  child: const Icon(
                    Icons.directions_car_rounded,
                    color: AppTheme.onSurfaceMuted,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
          // Top gradient for button visibility
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withAlpha(153), Colors.transparent],
                ),
              ),
            ),
          ),
          // Bottom gradient for content overlap
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.backgroundDark.withAlpha(128),
                  ],
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: topPadding + 12,
            left: 16,
            child: _IconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack,
            ),
          ),
          // Right action buttons
          Positioned(
            top: topPadding + 12,
            right: 16,
            child: Row(
              children: [
                _IconButton(
                  icon: isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  onTap: onBookmark,
                  activeColor: isBookmarked ? AppTheme.accentLight : null,
                ),
                const SizedBox(width: 8),
                _IconButton(icon: Icons.share_rounded, onTap: onShare),
              ],
            ),
          ),
          // Page indicator dots
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imageUrls.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: currentIndex == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: currentIndex == i ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? activeColor;

  const _IconButton({
    required this.icon,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(115),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(38), width: 1),
        ),
        child: Icon(icon, color: activeColor ?? Colors.white, size: 18),
      ),
    );
  }
}
