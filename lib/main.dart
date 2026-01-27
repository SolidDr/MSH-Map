import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'src/modules/_module_registry.dart';
import 'src/modules/asset_locations/asset_locations_module.dart';
import 'src/modules/events/events_module.dart';
import 'src/modules/family/family_module.dart';
import 'src/modules/gastro/gastro_module.dart';
import 'src/modules/health/health_module.dart';
import 'src/modules/search/search_module.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for German locale
  await initializeDateFormatting('de_DE');

  // Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Module registrieren
  ModuleRegistry.instance.register(AssetLocationsModule());
  ModuleRegistry.instance.register(GastroModule());
  ModuleRegistry.instance.register(FamilyModule());
  ModuleRegistry.instance.register(EventsModule());
  ModuleRegistry.instance.register(HealthModule());
  ModuleRegistry.instance.register(SearchModule());

  // Module initialisieren
  await ModuleRegistry.instance.initializeAll();

  runApp(const ProviderScope(child: MshMapApp()));
}
