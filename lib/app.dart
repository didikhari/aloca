import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/database/hive_service.dart';
import 'screens/onboarding/initial_setup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

import 'theme/app_theme.dart';

class AlocaApp extends StatelessWidget {
  const AlocaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final periods = HiveService.getAllPeriods();
    final allocations = HiveService.getAllAllocations();
    final categories = HiveService.getAllCategories();
    final bool hasInitialPeriod = periods.isNotEmpty && allocations.isNotEmpty && categories.isNotEmpty;

    return MaterialApp(
      title: 'Aloca',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      theme: AppTheme.lightTheme,
      home: hasInitialPeriod
          ? const DashboardScreen()
          : const InitialSetupScreen(),
    );
  }
}
