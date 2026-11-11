import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/vehicle.dart';
import '../../shared/widgets/vehicle_card.dart';
import '../catalog/vehicle_detail_view.dart';

class FavoritesView extends StatefulWidget {
  static const String name = 'favorites';

  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  final Set<String> _favoriteIds = {};
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _vehiclesStream;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _favoritesSubscription;
  Object? _favoritesError;
  bool _favoritesLoading = true;

  String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _vehiclesStream = FirebaseFirestore.instance
        .collection('Vehiculos')
        .snapshots();
    _listenToFavorites();
  }

  void _listenToFavorites() {
    final uid = _currentUid;
    if (uid == null) {
      _favoritesLoading = false;
      return;
    }

    _favoritesSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .listen(
          (snapshot) {
            if (!mounted) return;
            setState(() {
              _favoriteIds
                ..clear()
                ..addAll(snapshot.docs.map((doc) => doc.id));
              _favoritesError = null;
              _favoritesLoading = false;
            });
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!mounted) return;
            setState(() {
              _favoritesError = error;
              _favoritesLoading = false;
            });
          },
        );
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _removeFavorite(String vehicleId) async {
    final uid = _currentUid;
    if (uid == null) {
      _showMessage('Debes iniciar sesión para modificar tus favoritos.');
      return;
    }

    setState(() => _favoriteIds.remove(vehicleId));

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .doc(vehicleId)
          .delete();
    } catch (error) {
      if (!mounted) return;
      setState(() => _favoriteIds.add(vehicleId));
      _showMessage('No se pudo quitar el favorito: $error');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openDetail(Vehicle car) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => VehicleDetailView(car: car)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1826),
      appBar: AppBar(
        title: const Text('Favoritos'),
        backgroundColor: const Color(0xFF0E1826),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_currentUid == null) {
      return const _FavoritesMessage(
        icon: Icons.login,
        message: 'Debes iniciar sesión para ver tus favoritos.',
      );
    }

    if (_favoritesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favoritesError != null) {
      return const _FavoritesMessage(
        icon: Icons.error_outline,
        message: 'No se pudieron cargar tus favoritos.',
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _vehiclesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _FavoritesMessage(
            icon: Icons.error_outline,
            message: 'No se pudieron cargar los vehículos.',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final favoriteVehicles =
            (snapshot.data?.docs ??
                    const <QueryDocumentSnapshot<Map<String, dynamic>>>[])
            .map((doc) => Vehicle.fromFirestore(doc.id, doc.data()))
            .where(
              (vehicle) =>
                  vehicle.isPublished && _favoriteIds.contains(vehicle.id),
            )
            .toList();

        if (favoriteVehicles.isEmpty) {
          return const _FavoritesMessage(
            icon: Icons.favorite_border,
            message: 'Aún no tienes vehículos favoritos.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: favoriteVehicles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final car = favoriteVehicles[index];
            return VehicleCard(
              key: ValueKey(car.id),
              car: car,
              isFavourite: true,
              onTap: () => _openDetail(car),
              onToggleFavourite: () => _removeFavorite(car.id),
            );
          },
        );
      },
    );
  }
}

class _FavoritesMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _FavoritesMessage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: const Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFCBD5E1),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
