import 'package:flutter/material.dart';
import '../catalog/catalog_view.dart';
import '../visits/my_visits_view.dart';
import '../favorites/favorites_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final Set<String> _favouriteIds = {};

  void _toggleFavourite(String autoId) {
    setState(() {
      if (!_favouriteIds.remove(autoId)) {
        _favouriteIds.add(autoId);
      }
    });
  }

  void _goToCatalog() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final views = [
      CatalogView(
        favoriteIds: _favouriteIds,
        onToggleFavourite: _toggleFavourite,
      ),
      FavoritesView(
        favoriteIds: _favouriteIds,
        onToggleFavourite: _toggleFavourite,
        onGoToCatalog: _goToCatalog,
      ),
      MyVisitsView(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: views,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF1B2A3F),
        selectedItemColor: const Color(0xFF2DD4BF),
        unselectedItemColor: const Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            activeIcon: Icon(Icons.directions_car),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            activeIcon: Icon(Icons.event_note),
            label: 'Mis Visitas',
          ),
        ],
      ),
    );
  }
}
