import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'features/destinations/data/datasources/local_datasource.dart';
import 'features/destinations/presentation/widgets/offline_banner.dart';

/// Bootstraps env, dependency injection, SQLite, and navigation.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  setupDi();
  await sl<DatabaseHelper>().init();
  runApp(const App());
}

/// Root widget: Material 3 theme, GoRouter, and global offline indicator.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Destinos turísticos',
      theme: AppTheme.light,
      routerConfig: appRouter,
      builder: (BuildContext context, Widget? child) {
        return OfflineBanner(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
