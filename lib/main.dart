import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/hive_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive local database storage
  await HiveService.init();

  runApp(
    const ProviderScope(
      child: AlocaApp(),
    ),
  );
}
