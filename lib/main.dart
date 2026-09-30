import 'package:flutter/material.dart';

import 'features/catalogo/catalogo_view.dart';

void main() => runApp(const MainApp());

const _navy = Color(0xFF0E1826);
const _superficie = Color(0xFF1B2A3F);
const _teal = Color(0xFF2DD4BF);
const _textoSecundario = Color(0xFF94A3B8);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotORTs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _navy,
        colorScheme: const ColorScheme.dark(
          primary: _teal,
          onPrimary: _navy,
          surface: _superficie,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _navy,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _teal,
            foregroundColor: _navy,
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _superficie,
          contentTextStyle: const TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        iconTheme: const IconThemeData(color: _textoSecundario),
        dividerColor: const Color(0xFF2A3D57),
      ),
      home: const CatalogoView(),
    );
  }
}
