import 'package:go_router/go_router.dart';

import '../../features/about/presentation/about_screen.dart';
import '../../features/about/presentation/datenschutz_screen.dart';
import '../../features/about/presentation/impressum_screen.dart';
import '../../features/about/presentation/nutzungsbedingungen_screen.dart';
import '../../features/admin/presentation/admin_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/discover/presentation/discover_screen.dart';
import '../../features/feedback/presentation/suggest_location_screen.dart';
import '../../features/mobility/presentation/mobility_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/accessibility_settings_screen.dart';
import '../../home_screen.dart';
import '../../modules/_module_registry.dart';
import '../../modules/events/presentation/screens/events_screen.dart';
import '../../modules/gastro/presentation/menu_upload/ocr_preview.dart';
import '../../modules/gastro/presentation/menu_upload/upload_screen.dart';
import '../../modules/health/presentation/health_screen.dart';
import '../../modules/civic/presentation/soziales_screen.dart';
import '../../modules/nightlife/presentation/nightlife_screen.dart';
import '../../modules/radwege/presentation/radwege_screen.dart';
import '../config/feature_flags.dart';
import '../shell/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            // Extract query parameters for POI navigation
            final lat = double.tryParse(state.uri.queryParameters['lat'] ?? '');
            final lng = double.tryParse(state.uri.queryParameters['lng'] ?? '');
            final poiId = state.uri.queryParameters['id'];

            return HomeScreen(
              targetLatitude: lat,
              targetLongitude: lng,
              targetPoiId: poiId,
            );
          },
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutScreen(),
        ),
        if (FeatureFlags.enableSuggestLocation)
          GoRoute(
            path: '/suggest-location',
            builder: (context, state) => const SuggestLocationScreen(),
          ),
        GoRoute(
          path: '/accessibility',
          builder: (context, state) => const AccessibilitySettingsScreen(),
        ),
        GoRoute(
          path: '/discover',
          builder: (context, state) => const DiscoverScreen(),
        ),
        GoRoute(
          path: '/events',
          builder: (context, state) => const EventsScreen(),
        ),
        GoRoute(
          path: '/mobility',
          builder: (context, state) => const MobilityScreen(),
        ),
        GoRoute(
          path: '/health',
          builder: (context, state) => const HealthScreen(),
        ),
        GoRoute(
          path: '/soziales',
          builder: (context, state) => const SozialesScreen(),
        ),
        GoRoute(
          path: '/nightlife',
          builder: (context, state) => const NightlifeScreen(),
        ),
        GoRoute(
          path: '/radwege',
          builder: (context, state) => const RadwegeScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/impressum',
          builder: (context, state) => const ImpressumScreen(),
        ),
        GoRoute(
          path: '/datenschutz',
          builder: (context, state) => const DatenschutzScreen(),
        ),
        GoRoute(
          path: '/nutzungsbedingungen',
          builder: (context, state) => const NutzungsbedingungenScreen(),
        ),
        // Admin Dashboard (versteckte Route, Zugang über ?key=...)
        GoRoute(
          path: '/admin',
          builder: (context, state) {
            final key = state.uri.queryParameters['key'];
            return AdminScreen(adminKey: key);
          },
        ),
        // Modul-Routes dynamisch sammeln
        ...ModuleRegistry.instance.collectAllRoutes(),
      ],
    ),
    // Routes ohne Shell (Login, Upload)
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/upload',
      builder: (context, state) => const MenuUploadScreen(),
    ),
    GoRoute(
      path: '/ocr-preview',
      builder: (context, state) => const OcrPreviewScreen(),
    ),
  ],
);
