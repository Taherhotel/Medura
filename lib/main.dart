import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/auth_wrapper.dart';
import 'services/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MeduraApp(),
    ),
  );
}

class MeduraApp extends StatelessWidget {
  const MeduraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medura',
      themeMode: themeProvider.themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaleFactor: themeProvider.textScaleFactor,
          ),
          child: child!,
        );
      },
      home: const AuthWrapper(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00BFA6), // Teal/Turquoise primary
        primary: const Color(0xFF00BFA6),
        secondary: const Color.fromARGB(
          255,
          244,
          245,
          246,
        ), // Soft Blue secondary
        surface: const Color(0xFFF8F9FA), // Very light grey background
        error: const Color(0xFFFF5252),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.grey),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0A192F), // Dark Navy Blue primary
        primary: const Color(0xFF0A192F),
        secondary: const Color(0xFF64FFDA), // Cyan/Teal accent for contrast
        tertiary: const Color(0xFF112240), // Slightly lighter navy for cards
        surface: const Color(0xFF0A192F), // Dark background
        onSurface: const Color(0xFFE6F1FF), // Light text
        error: const Color(0xFFFF5252),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0A192F),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFFE6F1FF)),
        titleTextStyle: TextStyle(
          color: Color(0xFFE6F1FF),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color(0xFF112240), // Light navy card bg
        surfaceTintColor: const Color(0xFF112240),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFE6F1FF)),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFFE6F1FF),
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFFE6F1FF),
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFFE6F1FF),
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF8892B0), // Slate for body text
        ),
        bodySmall: TextStyle(color: Color(0xFF8892B0)),
      ),
    );
  }
}
