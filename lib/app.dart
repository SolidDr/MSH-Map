import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'src/core/theme/app_theme.dart';
import 'src/features/authentication/presentation/login_screen.dart';
import 'src/features/feed/presentation/feed_screen.dart';
import 'src/features/merchant_cockpit/presentation/ocr_preview_screen.dart';
import 'src/features/merchant_cockpit/presentation/upload_screen.dart';

/// Router configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/feed',
        name: 'feed',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/upload',
        name: 'upload',
        builder: (context, state) => const UploadScreen(),
      ),
      GoRoute(
        path: '/ocr-preview',
        name: 'ocr-preview',
        builder: (context, state) => const OcrPreviewScreen(),
      ),
    ],
  );
});

/// Main application widget
class LunchRadarApp extends ConsumerWidget {
  const LunchRadarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Lunch Radar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
