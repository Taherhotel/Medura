import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MeduraApp());
}

class MeduraApp extends StatelessWidget {
  const MeduraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medura',
      theme: ThemeData(
        useMaterial3: true,
        // Define a modern, healthcare-oriented color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BFA6), // Teal/Turquoise primary
          primary: const Color(0xFF00BFA6),
          secondary: const Color(0xFF3D5AFE), // Soft Blue secondary
          surface: const Color(0xFFF8F9FA), // Very light grey background
          error: const Color(0xFFFF5252),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
          surfaceTintColor: Colors.white,
        ),
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
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
