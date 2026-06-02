import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import './widgets/bottom_action_bar_widget.dart';
import './widgets/detail_hero_widget.dart';
import './widgets/detail_info_panel_widget.dart';
import './widgets/detail_specs_widget.dart';

class CarDetailScreen extends StatefulWidget {
  final Map<String, dynamic> carData;

  const CarDetailScreen({super.key, required this.carData});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen>
    with TickerProviderStateMixin {
  bool _isBookmarked = false;
  int _currentImageIndex = 0;
  late AnimationController _entranceController;
  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;

  List<String> get _imageUrls {
    // ✅ FIX: Use imageUrls list from backend if available, fallback to imageUrl
    final urls = widget.carData['imageUrls'];
    if (urls is List && urls.isNotEmpty) {
      return urls.cast<String>();
    }
    final base = widget.carData['imageUrl'] as String? ?? '';
    if (base.isEmpty) return [''];
    return [base];
  }

  // ✅ FIX: Safe isAvailable parsing — Java boolean records serialize
  // as "available" with default Jackson, but our DTO uses explicit "isAvailable"
  bool get _isAvailable => ApiService.parseIsAvailable(widget.carData);

  // ✅ FIX: Safe pricePerDay parsing — BigDecimal comes as num or String
  double get _pricePerDay {
    final p = widget.carData['pricePerDay'];
    if (p == null) return 0.0;
    if (p is num) return p.toDouble();
    if (p is String) return double.tryParse(p) ?? 0.0;
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _entranceSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _onReserveNow() {
    // ✅ FIX: Always pass car as a deep copy to avoid mutation issues
    final car = Map<String, dynamic>.from(widget.carData);
    context.push(AppRoutes.reservationFormScreen, extra: {'car': car});
  }

  void _onBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);
    Fluttertoast.showToast(
      msg: _isBookmarked ? 'Ajouté aux favoris' : 'Retiré des favoris',
      backgroundColor: AppTheme.surfaceElevated,
      textColor: AppTheme.onSurfaceDark,
      fontSize: 13,
    );
  }

  void _onShare() {
    Fluttertoast.showToast(
      msg: 'Partage en cours...',
      backgroundColor: AppTheme.surfaceElevated,
      textColor: AppTheme.onSurfaceDark,
      fontSize: 13,
    );
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.carData;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: DetailHeroWidget(
                  imageUrls: _imageUrls,
                  semanticLabel: car['semanticLabel'] as String? ?? 'Car image',
                  carId: car['id']?.toString() ?? 'car',
                  isBookmarked: _isBookmarked,
                  onBack: () => context.pop(),
                  onBookmark: _onBookmark,
                  onShare: _onShare,
                  onPageChanged: (i) => setState(() => _currentImageIndex = i),
                  currentIndex: _currentImageIndex,
                ),
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _entranceFade,
                  child: SlideTransition(
                    position: _entranceSlide,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.backgroundDark,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          // Drag handle
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppTheme.outlineDark,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DetailInfoPanelWidget(car: car),
                          const SizedBox(height: 8),
                          DetailSpecsWidget(car: car),
                          const SizedBox(height: 24),
                          _buildDescription(car),
                          const SizedBox(height: 16),
                          _buildLocationSection(car),
                          // ✅ FIX: Show "non disponible" badge when unavailable
                          if (!_isAvailable) _buildUnavailableBanner(),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Fixed bottom action bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomActionBarWidget(
              pricePerDay: _pricePerDay,
              // ✅ FIX: Use computed _isAvailable (handles both JSON field names)
              isAvailable: _isAvailable,
              onReserve: _isAvailable ? _onReserveNow : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.errorSurface.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.errorSurface.withAlpha(100)),
        ),
        child: Row(
          children: [
            const Icon(Icons.block_rounded, color: AppTheme.error, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ce véhicule n\'est pas disponible actuellement.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(Map<String, dynamic> car) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurfaceDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            car['description'] as String? ?? 'Aucune description disponible.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.6,
              color: AppTheme.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(Map<String, dynamic> car) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineDark, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(38),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lieu de prise en charge',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    car['location'] as String? ?? 'À confirmer',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceDark,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.onSurfaceMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
