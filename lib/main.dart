import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'src/features/about/data/traffic_counter_service.dart';
import 'src/modules/_module_registry.dart';
import 'src/modules/asset_locations/asset_locations_module.dart';
import 'src/modules/events/events_module.dart';
import 'src/modules/family/family_module.dart';
import 'src/modules/gastro/gastro_module.dart';
import 'src/modules/health/health_module.dart';
import 'src/modules/search/search_module.dart';

Future<void> main() async {
  // Global error handler for async errors
  FlutterError.onError = (details) {
    debugPrint('Flutter error: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize date formatting for German locale
    await initializeDateFormatting('de_DE');

    // Firebase init mit Error-Handling
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
    } catch (e, stack) {
      debugPrint('Firebase init error: $e');
      debugPrint('Stack: $stack');
    }

    // Traffic Counter (anonymisiert, einmal pro Tag)
    try {
      unawaited(TrafficCounterService().incrementIfNeeded());
    } catch (e) {
      debugPrint('Traffic counter error: $e');
    }

    // Module registrieren
    ModuleRegistry.instance.register(AssetLocationsModule());
    ModuleRegistry.instance.register(GastroModule());
    ModuleRegistry.instance.register(FamilyModule());
    ModuleRegistry.instance.register(EventsModule());
    ModuleRegistry.instance.register(HealthModule());
    ModuleRegistry.instance.register(SearchModule());

    // Module initialisieren
    try {
      await ModuleRegistry.instance.initializeAll();
    } catch (e) {
      debugPrint('Module init error: $e');
    }

    runApp(const ProviderScope(child: MshMapApp()));
  }, (error, stack) {
    debugPrint('Uncaught error: $error');
    debugPrint('Stack: $stack');
  });
}
