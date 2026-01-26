import 'package:go_router/go_router.dart';
import '../../features/about/presentation/about_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../home_screen.dart';
import '../../modules/_module_registry.dart';
import '../../modules/gastro/presentation/menu_upload/ocr_preview.dart';
import '../../modules/gastro/presentation/menu_upload/upload_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
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
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
    // Modul-Routes dynamisch sammeln
    ...ModuleRegistry.instance.collectAllRoutes(),
  ],
);
