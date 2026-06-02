import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import './widgets/reservation_car_summary_widget.dart';
import './widgets/reservation_confirmation_sheet_widget.dart';
import './widgets/reservation_dates_widget.dart';
import './widgets/reservation_nationality_widget.dart';
import './widgets/reservation_personal_info_widget.dart';

class ReservationFormScreen extends StatefulWidget {
  final Map<String, dynamic> reservationData;
  const ReservationFormScreen({super.key, required this.reservationData});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _permitNumberController = TextEditingController();
  final _mileageController = TextEditingController();
  final _depositController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  String? _pickupLocation;
  final List<String> _pickupLocations = [
    'Aéroport',
    'Charguia',
  ];

  String _nationality = 'Tunisian';
  final _documentNumberController = TextEditingController();
  String? _documentImagePath; // local path only — not sent to API

  bool _isSubmitting = false;

  // ── Booked date ranges ─────────────────────────────────────────────────────
  List<DateTimeRange> _bookedRanges = [];
  bool _isLoadingDates = true;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic> get _car =>
      (widget.reservationData['car'] as Map<String, dynamic>?) ?? {};

  int get _totalDays {
    if (_startDate == null || _endDate == null) return 1;
    return _endDate!.difference(_startDate!).inDays.clamp(1, 365);
  }

  double get _pricePerDay {
    final p = _car['pricePerDay'];
    if (p == null) return 0.0;
    if (p is num) return p.toDouble();
    if (p is String) return double.tryParse(p) ?? 0.0;
    return 0.0;
  }

  double get _totalPrice => _pricePerDay * _totalDays;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _slideController.forward();
    _loadUnavailableDates();
  }

  Future<void> _loadUnavailableDates() async {
    final carId = _car['id']?.toString() ?? '';
    if (carId.isEmpty) {
      setState(() => _isLoadingDates = false);
      return;
    }
    try {
      final raw = await ApiService.getCarUnavailableDates(carId);
      setState(() {
        _bookedRanges = raw.map((e) {
          final start = DateTime.parse(e['startDate'] as String);
          final end = DateTime.parse(e['endDate'] as String);
          return DateTimeRange(start: start, end: end);
        }).toList();
        _isLoadingDates = false;
      });
    } catch (_) {
      setState(() => _isLoadingDates = false);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _permitNumberController.dispose();
    _mileageController.dispose();
    _depositController.dispose();
    _documentNumberController.dispose();
    super.dispose();
  }

  void _onProceedToConfirm() {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
        msg: 'Veuillez remplir tous les champs obligatoires',
        backgroundColor: AppTheme.errorSurface,
        textColor: Colors.white,
        fontSize: 13,
      );
      return;
    }
    if (_startDate == null || _endDate == null) {
      Fluttertoast.showToast(
        msg: 'Veuillez sélectionner les dates de location',
        backgroundColor: AppTheme.errorSurface,
        textColor: Colors.white,
        fontSize: 13,
      );
      return;
    }
    if (_pickupLocation == null) {
      Fluttertoast.showToast(
        msg: 'Veuillez choisir un lieu de prise en charge',
        backgroundColor: AppTheme.errorSurface,
        textColor: Colors.white,
        fontSize: 13,
      );
      return;
    }
    _showConfirmationSheet();
  }

  void _showConfirmationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReservationConfirmationSheetWidget(
        car: _car,
        fullName: _nameController.text,
        phone: _phoneController.text,
        permitNumber: _permitNumberController.text,
        mileage: _mileageController.text,
        deposit: _depositController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        pickupLocation: _pickupLocation!,
        nationality: _nationality,
        totalDays: _totalDays,
        totalPrice: _totalPrice,
        onConfirmPayment: _onConfirmReservation,
      ),
    );
  }

  Future<void> _onConfirmReservation() async {
    Navigator.pop(context);
    setState(() => _isSubmitting = true);

    try {
      final carId = _car['id']?.toString() ?? '';
      // ✅ FIX: Pure JSON — no multipart. documentImageFile kept local only.
      await ApiService.createReservation(
        carId: carId,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        permitNumber: _permitNumberController.text.trim(),
        mileage: _mileageController.text.trim(),
        deposit: _depositController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        pickupLocation: _pickupLocation!,
        nationality: _nationality,
        documentNumber: _documentNumberController.text.trim(),
        documentImageFile: _documentImagePath != null
            ? File(_documentImagePath!)
            : null,
      );
      if (mounted) _showSuccess();
    } on ApiException catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: e.message,
          backgroundColor: AppTheme.errorSurface,
          textColor: Colors.white,
          fontSize: 13,
        );
      }
    } catch (_) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Erreur réseau. Vérifiez votre connexion.',
          backgroundColor: AppTheme.errorSurface,
          textColor: Colors.white,
          fontSize: 13,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(
        totalPrice: _totalPrice,
        totalDays: _totalDays,
        onDone: () {
          Navigator.pop(context);
          context.go('/home-screen');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariantDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.onSurfaceDark,
              size: 16,
            ),
          ),
        ),
        title: Text(
          'Réservation',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurfaceDark,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SlideTransition(
            position: _slideAnimation,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReservationCarSummaryWidget(
                      car: _car,
                      totalDays: _totalDays,
                      totalPrice: _totalPrice,
                    ),
                    const SizedBox(height: 20),
                    ReservationPersonalInfoWidget(
                      nameController: _nameController,
                      phoneController: _phoneController,
                    ),
                    const SizedBox(height: 20),
                    _buildPermitField(),
                    const SizedBox(height: 20),
                    ReservationNationalityWidget(
                      nationality: _nationality,
                      documentNumberController: _documentNumberController,
                      documentImagePath: _documentImagePath,
                      onNationalityChanged: (n) {
                        setState(() {
                          _nationality = n;
                          _documentNumberController.clear();
                          _documentImagePath = null;
                        });
                      },
                      onDocumentImagePicked: (path) =>
                          setState(() => _documentImagePath = path),
                    ),
                    const SizedBox(height: 20),
                    ReservationDatesWidget(
                      startDate: _startDate,
                      endDate: _endDate,
                      bookedRanges: _bookedRanges,
                      isLoadingDates: _isLoadingDates,
                      onStartDateChanged: (d) => setState(() => _startDate = d),
                      onEndDateChanged: (d) => setState(() => _endDate = d),
                    ),
                    const SizedBox(height: 20),
                    _buildPickupLocation(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildSubmitBar()),
          if (_isSubmitting) _buildSubmittingOverlay(),
        ],
      ),
    );
  }

  Widget _buildPermitField() {
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
                Icons.badge_rounded,
                color: AppTheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Permis de Conduire',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _permitNumberController,
            label: 'N° Permis de conduire *',
            hint: 'Ex: A123456789',
            icon: Icons.badge_rounded,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Permis requis';
              return null;
            },
            keyboardType: TextInputType.text,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }

  Widget _buildPickupLocation() {
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
                Icons.location_on_rounded,
                color: AppTheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Lieu de prise en charge',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _pickupLocation,
            dropdownColor: AppTheme.surfaceElevated,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.onSurfaceDark,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.onSurfaceMuted,
            ),
            decoration: InputDecoration(
              hintText: 'Choisir une ville...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.onSurfaceMuted,
              ),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            items: _pickupLocations
                .map(
                  (loc) => DropdownMenuItem(
                    value: loc,
                    child: Text(loc, style: GoogleFonts.poppins(fontSize: 14)),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _pickupLocation = v),
            validator: (v) =>
                v == null ? 'Lieu de prise en charge requis' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding + 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(top: BorderSide(color: AppTheme.outlineDark, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(102),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total estimé',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTheme.onSurfaceMuted,
                ),
              ),
              Text(
                '${_totalPrice.toStringAsFixed(0)} TND',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentLight,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _onProceedToConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                'Confirmer la réservation',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha(153),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: AppTheme.primary,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Enregistrement...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.onSurfaceDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Success dialog ─────────────────────────────────────────────────────────

class _SuccessDialog extends StatefulWidget {
  final double totalPrice;
  final int totalDays;
  final VoidCallback onDone;
  const _SuccessDialog({
    required this.totalPrice,
    required this.totalDays,
    required this.onDone,
  });

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Dialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.success.withAlpha(38),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.success, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppTheme.success,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Réservation Confirmée !',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Votre réservation a été enregistrée.\nPaiement en espèces à la prise en charge.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.onSurfaceMuted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.success.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.success.withAlpha(77)),
                ),
                child: Column(
                  children: [
                    Text(
                      '${widget.totalDays} jour(s)',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.onSurfaceMuted,
                      ),
                    ),
                    Text(
                      '${widget.totalPrice.toStringAsFixed(0)} TND — Cash',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.success,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    "Retour à l'accueil",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
