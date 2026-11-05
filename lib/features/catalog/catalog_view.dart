
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/vehicle.dart';
import '../../shared/widgets/vehicle_card.dart';
import 'package:tp3motorts/shared/widgets/empty_state_widget.dart';
import 'vehicle_detail_view.dart';

class CatalogView extends StatefulWidget {
  const CatalogView({super.key});

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  final Set<String> _favourite = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedBrand = 'Todas';
  late final Stream<QuerySnapshot> _vehiclesStream;

  @override
  void initState() {
    super.initState();
    _vehiclesStream =
        FirebaseFirestore.instance.collection('Vehiculos').snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFavourite(String autoId) {
    setState(() {
      if (!_favourite.remove(autoId)) {
        _favourite.add(autoId);
      }
    });
  }

  void _openDetail(Vehicle car) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleDetailView(car: car),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedBrand = 'Todas';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notificaciones',
          ),
          const SizedBox(width: 4),
        ],
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
          final vehicles = docs.map((doc) {
            return Vehicle.fromFirestore(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).where((v) => v.isPublished).toList();

          final filteredVehicles = vehicles.where((car) {
            final query = _searchQuery.toLowerCase();
            final matchesSearch = query.isEmpty ||
                car.title.toLowerCase().contains(query) ||
                car.brand.toLowerCase().contains(query) ||
                car.model.toLowerCase().contains(query);

            final matchesBrand = _selectedBrand == 'Todas' ||
                car.brand.toLowerCase() == _selectedBrand.toLowerCase();

            return matchesSearch && matchesBrand;
          }).toList();

          return CustomScrollView(
            slivers: [
              // Cabecera fija: buscador, pastillas de marca y contador
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SearchBar(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.trim();
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      _FilterPills(
                        selectedBrand: _selectedBrand,
                        onBrandSelected: (brand) {
                          setState(() {
                            _selectedBrand = brand;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${filteredVehicles.length} autos disponibles',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Si no hay resultados -> mostramos el EmptyStateWidget
              if (filteredVehicles.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateWidget(
                    title: 'No se encontraron autos con esos criterios',
                    subtitle: 'Intentá modificando los filtros de búsqueda',
                    buttonText: 'Limpiar filtros',
                    icon: Icons.search,
                    onButtonPressed: _clearFilters,
                  ),
                )
              // Si hay autos -> listado de tarjetas
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final car = filteredVehicles[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: VehicleCard(
                            key: ValueKey(car.id),
                            car: car,
                            isFavourite: _favourite.contains(car.id),
                            onTap: () => _openDetail(car),
                            onToggleFavourite: () => _toggleFavourite(car.id),
                          ),
                        );
                      },
                      childCount: filteredVehicles.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.onChanged, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A3F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF94A3B8), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Buscar marca o modelo',
                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const Icon(Icons.tune, color: Color(0xFF2DD4BF), size: 22),
        ],
      ),
    );
  }
}

class _FilterPills extends StatelessWidget {
  final String selectedBrand;
  final ValueChanged<String> onBrandSelected;

  const _FilterPills({
    required this.selectedBrand,
    required this.onBrandSelected,
  });

  static const _brands = [
    'Todas',
    'Honda',
    'Toyota',
    'Volkswagen',
    'Ford',
    'Chevrolet'
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _brands.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final brand = _brands[index];
          final isSelected = selectedBrand == brand;
          return _Pill(
            text: brand,
            isSelected: isSelected,
            onTap: () => onBrandSelected(brand),
          );
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _Pill({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFF2DD4BF) : const Color(0xFF1B2A3F),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF2DD4BF) : const Color(0xFF2A3D57),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF0E1826) : Colors.white,
                ),
          ),
        ),
      ),
    );
  }
}
