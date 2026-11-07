import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Set<String> _favouriteIds = {};
  StreamSubscription<QuerySnapshot>? _favSubscription;

  String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _listenToFavorites();
  }

  @override
  void dispose() {
    _favSubscription?.cancel();
    super.dispose();
  }

  void _listenToFavorites() {
    final uid = _currentUid;
    if (uid == null) return;

    _favSubscription?.cancel();
    _favSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .listen((querySnapshot) {
      if (mounted) {
        setState(() {
          _favouriteIds = querySnapshot.docs.map((doc) => doc.id).toSet();
        });
      }
    }, onError: (error) {
      debugPrint('Error: $error');
    });
  }

  Future<void> _toggleFavourite(String autoId) async {
    final uid = _currentUid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iniciá sesión para guardar favoritos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final updatedFavs = Set<String>.from(_favouriteIds);
    final isFav = updatedFavs.contains(autoId);

    if (isFav) {
      updatedFavs.remove(autoId);
    } else {
      updatedFavs.add(autoId);
    }

    setState(() {
      _favouriteIds = updatedFavs;
    });

    final favDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(autoId);

    try {
      if (isFav) {
        await favDoc.delete();
      } else {
        await favDoc.set({
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
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
