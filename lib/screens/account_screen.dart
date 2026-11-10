import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  static const String name = 'account';
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Mi Cuenta', style: TextStyle(color: Colors.white)),
    );
  }
}
