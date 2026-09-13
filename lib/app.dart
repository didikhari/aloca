import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/database/hive_service.dart';
import 'screens/onboarding/initial_setup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

class AlocaApp extends StatelessWidget {
  const AlocaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final periods = HiveService.getAllPeriods();
    final bool hasInitialPeriod = periods.isNotEmpty;

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
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A884),
          primary: const Color(0xFF00A884),
          secondary: const Color(0xFF008B74),
          background: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: hasInitialPeriod ? const DashboardScreen() : const InitialSetupScreen(),
    );
  }
}
