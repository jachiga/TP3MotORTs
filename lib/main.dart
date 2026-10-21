import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/firebase_config.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'features/home/home_screen.dart';
import 'services/auth_service.dart';
import 'views/login_view.dart';

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
scaffoldBackgroundColor: const Color(0xFF0B111A),
primaryColor: const Color(0xFF00D2A0),
colorScheme: const ColorScheme.dark(
primary: Color(0xFF00D2A0),
surface: Color(0xFF131D2A),
),
),
home: StreamBuilder<User?>(
stream: AuthService().authStateChanges,
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return const Scaffold(
backgroundColor: Color(0xFF0B111A),
body: Center(
child: CircularProgressIndicator(color: Color(0xFF00D2A0)),
),
);
}

      if (snapshot.hasData && snapshot.data != null) {
        return const HomeScreen();
      }

      return const LoginView();
    },
  ),
);


}
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

 
  await initializeDateFormatting('es');

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