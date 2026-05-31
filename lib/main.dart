import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart' as provider;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Pages/Components/app_route.dart';
import 'Pages/ForgotPassword/view/ResetPasswordPage.dart';

import 'package:untitled6/services/sharedpref.dart';
import 'package:untitled6/services/settings_service.dart';
import 'package:untitled6/services/notification_service.dart';

import 'Pages/Dashboard/View/Dashboard.dart';
import 'Pages/Login/View/LoginScreen.dart';
import 'Pages/Splash/SplashScreen.dart';
import 'Pages/WorkoutBegin/Repository.dart';
import 'Pages/WorkoutBegin/viewmodel/cubit/WorkoutBeginCubit.dart';
import 'Pages/Notifications/Repository/NotificationsRepository.dart';
import 'Pages/Notifications/ViewModel/NotificationsViewModel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('seen_stories');

  await Supabase.initialize(
    url: 'https://noxgwtjrnjnbzmeqlncp.supabase.co',
    anonKey: 'sb_publishable_ZAvTGBdF5WBo39Re9XKr_Q_Nt5xqmyX',
  );

  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(
          create: (_) => SettingsService(),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => NotificationsViewModel(NotificationsRepository()),
        ),
        BlocProvider(
          create: (_) => WorkoutBeginCubit(WorkoutBeginRepository()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final sharedprefs _prefs = sharedprefs();
  String? userid;
  bool isLoading = true;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.push(
            appRoute((_) => const ResetPasswordPage()),
          );
        });
      } else if (event == AuthChangeEvent.signedIn) {
        NotificationService.registerBackgroundSync();
      } else if (event == AuthChangeEvent.signedOut) {
        NotificationService.cancelBackgroundSync();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUser() async {
    userid = await _prefs.getUserId();
    if (userid != null) {
      NotificationService.registerBackgroundSync();
      setState(() => isLoading = false);
    } else {
      await Future.delayed(const Duration(seconds: 3));
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = provider.Provider.of<SettingsService>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: settingsService.themeMode,
      darkTheme: _buildDarkTheme(),
      theme: _buildLightTheme(),
      home: isLoading
          ? const SplashScreen()
          : (userid == null
              ? const LoginScreen()
              : Dashboard(userid: userid!)),
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
