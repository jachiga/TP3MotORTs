
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/vehicle.dart';
import '../../shared/widgets/vehicle_card.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../catalog/vehicle_detail_view.dart';

class FavoritesView extends StatefulWidget {
  final Set<String> favoriteIds;
  final Function(String) onToggleFavourite;
  final VoidCallback onGoToCatalog;

  const FavoritesView({
    super.key,
    required this.favoriteIds,
    required this.onToggleFavourite,
    required this.onGoToCatalog,
  });

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  late final Stream<QuerySnapshot> _vehiclesStream;

  @override
  void initState() {
    super.initState();
    _vehiclesStream =
        FirebaseFirestore.instance.collection('Vehiculos').snapshots();
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _vehiclesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error al conectar con la base de datos'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final allVehicles = docs.map((doc) {
            return Vehicle.fromFirestore(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).where((v) => v.isPublished).toList();

          // Filtramos solo los autos cuyo ID esté en la lista de favoritos
          final favoriteVehicles = allVehicles
              .where((car) => widget.favoriteIds.contains(car.id))
              .toList();

          // Si no hay favoritos marcados, reutilizamos el EmptyStateWidget
          if (favoriteVehicles.isEmpty) {
            return EmptyStateWidget(
              title: 'No tenés autos favoritos guardados',
              subtitle: 'Explorá el catálogo y guardá los vehículos que más te gusten con el corazón.',
              buttonText: 'Explorar catálogo',
              icon: Icons.favorite_border,
              onButtonPressed: widget.onGoToCatalog,
            );
          }

          // Si hay favoritos, listamos las tarjetas
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
                onToggleFavourite: () => widget.onToggleFavourite(car.id),
              );
            },
          );
        },
      ),
    );
  }
}
