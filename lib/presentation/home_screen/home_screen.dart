import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import './widgets/car_section_widget.dart';
import './widgets/hero_slider_widget.dart';
import './widgets/home_header_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isDarkTheme = true;
  String _selectedLanguage = 'FR';
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<Map<String, dynamic>> _allCars = [];
  String? _error;

  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return _allCars;
    final q = _searchQuery.toLowerCase();
    return _allCars.where((c) {
      return (c['brand'] as String? ?? '').toLowerCase().contains(q) ||
          (c['model'] as String? ?? '').toLowerCase().contains(q) ||
          (c['location'] as String? ?? '').toLowerCase().contains(q);
    }).toList();
  }

  // ✅ FIX: Use ApiService.parseIsAvailable to handle both "isAvailable"
  // and "available" JSON keys (Jackson serializes boolean record fields
  // as "available" by default, but our DTO explicitly names it "isAvailable")
  List<Map<String, dynamic>> get _availableNow =>
      _filtered.where((c) => ApiService.parseIsAvailable(c)).take(4).toList();

  List<Map<String, dynamic>> get _premiumCars =>
      _filtered.where((c) => c['category'] == 'Premium').toList();
  List<Map<String, dynamic>> get _budgetCars =>
      _filtered.where((c) => c['category'] == 'Budget').toList();
  List<Map<String, dynamic>> get _mostRented {
    final sorted = List<Map<String, dynamic>>.from(_filtered);
    sorted.sort(
      (a, b) => (b['totalRentals'] as int? ?? 0).compareTo(
        a['totalRentals'] as int? ?? 0,
      ),
    );
    return sorted.take(4).toList();
  }

  List<Map<String, dynamic>> get _heroFeatured => _allCars.take(3).toList();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final cars = await ApiService.getCars();
      if (mounted) {
        setState(() {
          _allCars = cars;
          _isLoading = false;
        });
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error =
              'Impossible de charger les voitures.\nVérifiez votre connexion au serveur.';
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onCarTap(Map<String, dynamic> car) =>
      context.push(AppRoutes.carDetailScreen, extra: car);
  void _toggleTheme() => setState(() => _isDarkTheme = !_isDarkTheme);
  void _changeLanguage(String lang) => setState(() => _selectedLanguage = lang);

  String _t(String fr, String en, String ar) {
    switch (_selectedLanguage) {
      case 'EN':
        return en;
      case 'AR':
        return ar;
      default:
        return fr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : _error != null
            ? _buildErrorState()
            : FadeTransition(
                opacity: _fadeAnimation,
                child: RefreshIndicator(
                  onRefresh: _loadCars,
                  color: AppTheme.primary,
                  backgroundColor: AppTheme.surfaceDark,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: HomeHeaderWidget(
                          selectedLanguage: _selectedLanguage,
                          isDarkTheme: _isDarkTheme,
                          onLanguageChanged: _changeLanguage,
                          onThemeToggle: _toggleTheme,
                          onSearchTap: () {},
                        ),
                      ),
                      if (_heroFeatured.isNotEmpty)
                        SliverToBoxAdapter(
                          child: HeroSliderWidget(
                            cars: _heroFeatured,
                            onCarTap: _onCarTap,
                          ),
                        ),
                      SliverToBoxAdapter(child: _buildSearchBar()),
                      if (_availableNow.isNotEmpty)
                        SliverToBoxAdapter(
                          child: CarSectionWidget(
                            title: _t(
                              'Disponibles Maintenant',
                              'Available Now',
                              'متاح الآن',
                            ),
                            cars: _availableNow,
                            onCarTap: _onCarTap,
                          ),
                        ),
                      if (_premiumCars.isNotEmpty)
                        SliverToBoxAdapter(
                          child: CarSectionWidget(
                            title: _t(
                              'Voitures Premium',
                              'Premium Cars',
                              'سيارات فاخرة',
                            ),
                            cars: _premiumCars,
                            onCarTap: _onCarTap,
                          ),
                        ),
                      if (_budgetCars.isNotEmpty)
                        SliverToBoxAdapter(
                          child: CarSectionWidget(
                            title: _t(
                              'Petits Budgets',
                              'Budget Cars',
                              'ميزانية محدودة',
                            ),
                            cars: _budgetCars,
                            onCarTap: _onCarTap,
                          ),
                        ),
                      if (_mostRented.isNotEmpty)
                        SliverToBoxAdapter(
                          child: CarSectionWidget(
                            title: _t(
                              'Les Plus Loués',
                              'Most Rented',
                              'الأكثر استئجاراً',
                            ),
                            cars: _mostRented,
                            onCarTap: _onCarTap,
                          ),
                        ),
                      if (_filtered.isEmpty && _searchQuery.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.search_off_rounded,
                                  color: AppTheme.onSurfaceMuted,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Aucun résultat pour "$_searchQuery"',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppTheme.onSurfaceMuted,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppTheme.onSurfaceMuted,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.onSurfaceMuted,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCars,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Réessayer',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariantDark,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: AppTheme.outlineDark, width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(
              Icons.search_rounded,
              color: AppTheme.onSurfaceMuted,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.onSurfaceDark,
                ),
                decoration: InputDecoration(
                  hintText: _t(
                    'Rechercher une voiture...',
                    'Search for a car...',
                    'ابحث عن سيارة...',
                  ),
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.onSurfaceMuted,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  filled: false,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.onSurfaceMuted,
                    size: 16,
                  ),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 80),
          _ShimmerBox(height: 220, radius: 20),
          const SizedBox(height: 16),
          _ShimmerBox(height: 50, radius: 25),
          const SizedBox(height: 24),
          Row(children: [_ShimmerBox(height: 14, width: 120, radius: 4)]),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) =>
                  _ShimmerBox(height: 200, width: 160, radius: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double height;
  final double? width;
  final double radius;
  const _ShimmerBox({required this.height, this.width, required this.radius});
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              Color(0xFF2A2A2A),
              Color(0xFF3A3A3A),
              Color(0xFF2A2A2A),
            ],
            stops: [
              (_anim.value - 0.3).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 0.3).clamp(0.0, 1.0),
            ],
          ),
        ),
      ),
    );
  }
}
