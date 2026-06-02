import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/reservation_tracking_card.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _reservations = [];
  bool _isLoading = true;
  String? _error;
  String _activeFilter = 'ALL';
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final List<_FilterTab> _filters = const [
    _FilterTab('ALL', 'Toutes'),
    _FilterTab('PENDING', 'En attente'),
    _FilterTab('CONFIRMED', 'Confirmées'),
    _FilterTab('COMPLETED', 'Terminées'),
    _FilterTab('CANCELLED', 'Annulées'),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadReservations();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getMyReservations();
      // Sort newest first
      data.sort((a, b) {
        final da = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(0);
        final db = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(0);
        return db.compareTo(da);
      });
      if (mounted) {
        setState(() {
          _reservations = data;
          _isLoading = false;
        });
        _fadeCtrl.forward(from: 0);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Impossible de charger vos réservations.';
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_activeFilter == 'ALL') return _reservations;
    return _reservations
        .where((r) => (r['status'] ?? '') == _activeFilter)
        .toList();
  }

  int _countFor(String status) {
    if (status == 'ALL') return _reservations.length;
    return _reservations.where((r) => r['status'] == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildFilterTabs(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.onSurfaceDark,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mes Réservations',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceDark,
                  ),
                ),
                if (!_isLoading && _error == null)
                  Text(
                    '${_reservations.length} réservation${_reservations.length > 1 ? 's' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
              ],
            ),
          ),
          // Refresh button
          GestureDetector(
            onTap: _loadReservations,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = _filters[i];
          final isActive = _activeFilter == f.value;
          final count = _countFor(f.value);
          return GestureDetector(
            onTap: () {
              setState(() => _activeFilter = f.value);
              _fadeCtrl.forward(from: 0);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primary
                    : AppTheme.surfaceVariantDark,
                borderRadius: BorderRadius.circular(10),
                border: isActive
                    ? null
                    : Border.all(color: AppTheme.outlineDark, width: 1),
              ),
              child: Row(
                children: [
                  Text(
                    f.label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? Colors.white : AppTheme.onSurfaceMuted,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white.withOpacity(0.25)
                            : AppTheme.outlineDark,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : AppTheme.onSurfaceMuted,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.errorSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: AppTheme.error,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _loadReservations,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Réessayer'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final list = _filtered;

    if (list.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: RefreshIndicator(
        onRefresh: _loadReservations,
        color: AppTheme.primary,
        backgroundColor: AppTheme.surfaceDark,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) =>
              ReservationTrackingCard(reservation: list[i], index: i),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final messages = {
      'ALL': (
        'Aucune réservation',
        'Vous n\'avez pas encore effectué de réservation.',
      ),
      'PENDING': (
        'Aucune réservation en attente',
        'Toutes vos demandes ont été traitées.',
      ),
      'CONFIRMED': (
        'Aucune réservation confirmée',
        'Vos confirmations apparaîtront ici.',
      ),
      'COMPLETED': (
        'Aucun trajet terminé',
        'Vos locations passées apparaîtront ici.',
      ),
      'CANCELLED': (
        'Aucune annulation',
        'Vous n\'avez aucune réservation annulée.',
      ),
    };
    final msg = messages[_activeFilter]!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantDark,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppTheme.onSurfaceMuted,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              msg.$1,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              msg.$2,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.onSurfaceMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab {
  final String value;
  final String label;
  const _FilterTab(this.value, this.label);
}
