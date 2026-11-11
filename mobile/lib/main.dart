import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens.dart';
import 'state.dart';
import 'i18n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app.init();
  runApp(const MaakApp());
}

class MaakApp extends StatelessWidget {
  const MaakApp({super.key});
  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF176B5D);
    const sand = Color(0xFFF7F4EE);
    const coral = Color(0xFFC45C43);
    const gold = Color(0xFFD9A441);
    const darkTeal = Color(0xFF123F3A);
    final scheme = ColorScheme.fromSeed(seedColor: teal).copyWith(
      primary: teal,
      onPrimary: Colors.white,
      secondary: coral,
      tertiary: gold,
      surface: sand,
      onSurface: darkTeal,
      primaryContainer: const Color(0xFFDCEAE5),
      onPrimaryContainer: darkTeal,
    );
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => MaterialApp(
      title: 'MAAK',
      debugShowCheckedModeBanner: false,
      locale: Locale(app.locale),
      supportedLocales: const [Locale('ar'), Locale('fr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: sand,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        textTheme: ThemeData.light().textTheme.apply(bodyColor: darkTeal, displayColor: darkTeal),
      ),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: darkTeal),
      builder: (context, child) => Directionality(textDirection: app.locale == 'ar' ? TextDirection.rtl : TextDirection.ltr, child: child ?? const SizedBox.shrink()),
      home: app.user == null ? const AuthScreen() : (app.isTutor ? const TutorShell() : const StudentShell()),
      ),
    );
  }
}
