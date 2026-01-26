import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/constants/app_strings.dart';
import 'src/core/router/app_router.dart';
import 'src/core/theme/msh_theme.dart';

class MshMapApp extends StatelessWidget {
  const MshMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: AppStrings.appName,
        theme: MshTheme.light,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
