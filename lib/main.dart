import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uni_track/features/home/models/hive_modul.dart';
import 'package:uni_track/features/home/models/hive_weekly_modul.dart';
import 'package:uni_track/shared/hidden_drawer.dart';
import 'package:uni_track/themes/dark_theme.dart';
import 'package:uni_track/themes/light_theme.dart';
import 'package:uni_track/themes/theme_notifier.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive initialisieren
  await Hive.initFlutter();

  // Adapter registrieren
  Hive.registerAdapter(ModuleAdapter());
  Hive.registerAdapter(WeeklyModuleAdapter());

  await Hive.openBox<Module>('hive_modul');
  await Hive.openBox<WeeklyModule>('hive_weekly_modul');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeNotifier.themeMode,
            theme: lightTheme,
            darkTheme: darkTheme,
            supportedLocales: const [Locale('de', 'DE'), Locale('en', 'US')],

            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HiddenDrawer(),
          );
        },
      ),
    );
  }
}
