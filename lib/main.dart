
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/firebase_config.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseConfig.webOptions,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MotORTs',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0E1826),
        primaryColor: const Color(0xFF2DD4BF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2DD4BF),
          surface: Color(0xFF1B2A3F),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
