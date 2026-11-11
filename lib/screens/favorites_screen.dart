import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  static const String name = 'favorites';
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Favoritos', style: TextStyle(color: Colors.white)),
    );
  }
}
