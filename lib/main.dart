import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:untitled6/services/sharedpref.dart';
import 'package:untitled6/services/theme_service.dart';

import 'Pages/Dashboard/View/Dashboard.dart';
import 'Pages/Login/View/LoginScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://noxgwtjrnjnbzmeqlncp.supabase.co',
    anonKey: 'sb_publishable_ZAvTGBdF5WBo39Re9XKr_Q_Nt5xqmyX',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final sharedprefs _prefs = sharedprefs();
  String? userid;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    userid = await _prefs.getUserId();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();

    if (isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: themeService.themeMode,
        darkTheme: _buildDarkTheme(),
        theme: _buildLightTheme(),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeService.themeMode,
      darkTheme: _buildDarkTheme(),
      theme: _buildLightTheme(),
      home: userid == null
          ? const LoginScreen()
          : Dashboard(userid: userid!),
    );
  }
}

ThemeData _buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1E3A8A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFF60A5FA),
      surface: Color(0xFF2E4C8C),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E3A8A),
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardColor: const Color(0xFF2E4C8C),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF1A2E5C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );
}

ThemeData _buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF0F5FF),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2563EB),
      secondary: Color(0xFF3B82F6),
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1D4ED8),
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardColor: Colors.white,
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: const Color(0xFF0F1F44).withValues(alpha: 0.4)),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF0F1F44)),
    ),
  );
}
