import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/di.dart';
import 'app/navigation/router.dart';
import 'app/theme/app_theme.dart';
import 'presentation/widgets/offline_banner.dart';

/// Bootstraps env, dependency injection, SQLite, and navigation.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await setupDi();
  runApp(const App());
}

/// Root widget: Material 3 theme with dark mode support, GoRouter, offline indicator.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Destinos Turísticos Nicaragua',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      builder: (BuildContext context, Widget? child) {
        return OfflineBanner(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
