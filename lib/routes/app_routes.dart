import 'package:go_router/go_router.dart';
import '../presentation/auth_screen/auth_screen.dart';
import '../presentation/car_detail_screen/car_detail_screen.dart';
import '../presentation/main_scaffold/main_scaffold.dart';
import '../presentation/reservation_form_screen/reservation_form_screen.dart';

class AppRoutes {
  static const String authScreen = '/auth-screen';
  static const String main = '/home-screen'; // MainScaffold (home tab)
  static const String carDetailScreen = '/car-detail-screen';
  static const String reservationFormScreen = '/reservation-form-screen';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.authScreen,
  routes: [
    GoRoute(
      path: AppRoutes.authScreen,
      builder: (context, state) => const AuthScreen(),
    ),
    // MainScaffold contient Home + Reservations + Profile
    GoRoute(
      path: AppRoutes.main,
      builder: (context, state) => const MainScaffold(),
    ),
    GoRoute(
      path: AppRoutes.carDetailScreen,
      builder: (context, state) {
        final car = state.extra as Map<String, dynamic>;
        return CarDetailScreen(carData: car);
      },
    ),
    GoRoute(
      path: AppRoutes.reservationFormScreen,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return ReservationFormScreen(reservationData: data);
      },
    ),
  ],
);
