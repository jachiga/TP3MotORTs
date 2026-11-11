import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/vehicle.dart';
import '../../shared/widgets/vehicle_card.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../screens/vehicle_detail_view.dart';

class FavoritesView extends StatefulWidget {
  static const String name = 'favorites';

  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  Set<String> _localFavorites = {};
  late final Stream<QuerySnapshot> _vehiclesStream;

  String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _vehiclesStream =
        FirebaseFirestore.instance.collection('Vehiculos').snapshots();
    _loadUserFavorites();
  }

  void _loadUserFavorites() {
    final uid = _currentUid;
    if (uid == null) return;

    // Escucha en tiempo real la subcolección oficial de favoritos del usuario
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _localFavorites = snapshot.docs.map((doc) => doc.id).toSet();
        });
      }
    });
  }

  void _toggleFavourite(String autoId) async {
    final uid = _currentUid;
    if (uid == null) return;

    final bool isCurrentlyFav = _localFavorites.contains(autoId);

    // Actualización instantánea en UI
    setState(() {
      if (isCurrentlyFav) {
        _localFavorites.remove(autoId);
      } else {
        _localFavorites.add(autoId);
      }
    });

    try {
      final favDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .doc(autoId);

      if (isCurrentlyFav) {
        await favDocRef.delete();
      } else {
        await favDocRef.set({
          'vehicleId': autoId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error actualizando favorito en Firestore: $e');
    }
  }

  void _openDetail(Vehicle car) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleDetailView(car: car),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1826),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1826),
        elevation: 0,
        title: const Text(
          'Favoritos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _vehiclesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error al conectar con la base de datos',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final allVehicles = docs
              .map((doc) {
                return Vehicle.fromFirestore(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                );
              })
              .where((v) => v.isPublished)
              .toList();

          // Filtra los vehículos cuyos IDs coincidan con los de la subcolección
          final favoriteVehicles = allVehicles
              .where((car) => _localFavorites.contains(car.id))
              .toList();

          if (favoriteVehicles.isEmpty) {
            return EmptyStateWidget(
              title: 'Todavía no guardaste favoritos',
              subtitle:
                  'Explorá autos y tocá el corazón para guardarlos acá.',
              buttonText: 'Explorar autos',
              icon: Icons.favorite_border,
              onButtonPressed: () => context.go('/catalog'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: favoriteVehicles.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final car = favoriteVehicles[index];
              return VehicleCard(
                key: ValueKey(car.id),
                car: car,
                isFavourite: true,
                onTap: () => _openDetail(car),
                onToggleFavourite: () => _toggleFavourite(car.id),
              );
            },
          );
        },
      ),
    );
  }
}
