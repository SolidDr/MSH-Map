import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'src/modules/_module_registry.dart';
import 'src/modules/events/events_module.dart';
import 'src/modules/family/family_module.dart';
import 'src/modules/gastro/gastro_module.dart';
import 'src/modules/search/search_module.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Module registrieren
  ModuleRegistry.instance.register(GastroModule());
  ModuleRegistry.instance.register(FamilyModule());
  ModuleRegistry.instance.register(EventsModule());
  ModuleRegistry.instance.register(SearchModule());

  // Module initialisieren
  await ModuleRegistry.instance.initializeAll();

  runApp(const MshMapApp());
}
