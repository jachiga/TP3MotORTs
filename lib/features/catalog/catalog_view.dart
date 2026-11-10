import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../shared/models/vehicle.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/vehicle_card.dart';
import 'vehicle_detail_view.dart';

class CatalogView extends StatefulWidget {
  final Set<String>? favoriteIds;
  final Function(String)? onToggleFavourite;

  const CatalogView({
    super.key,
    this.favoriteIds,
    this.onToggleFavourite,
  });

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  final Set<String> _localFavourites = {};
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
    if (widget.onToggleFavourite != null) {
      widget.onToggleFavourite!(autoId);
    } else {
      setState(() {
        if (!_localFavourites.remove(autoId)) {
          _localFavourites.add(autoId);
        }
      });
    }
  }

  bool _isCarFavourite(String autoId) {
    if (widget.favoriteIds != null) {
      return widget.favoriteIds!.contains(autoId);
    }
    return _localFavourites.contains(autoId);
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
      backgroundColor: const Color(0xFF0E1826),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1826),
        elevation: 0,
        title: const Text(
          'MotORTs',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: Color(0xFF2DD4BF),
            fontSize: 22,
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
          final vehicles = docs
              .map((doc) {
                return Vehicle.fromFirestore(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                );
              })
              .where((v) => v.isPublished)
              .toList();

          // Extracción dinámica de marcas directamente desde Firestore
          final dynamicBrands = <String>{'Todas'};
          for (final v in vehicles) {
            if (v.brand.trim().isNotEmpty && v.brand != 'Sin marca') {
              dynamicBrands.add(v.brand.trim());
            }
          }
          final brandsList = dynamicBrands.toList();

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

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount:
                filteredVehicles.isEmpty ? 2 : filteredVehicles.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
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
                      brands: brandsList,
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
                );
              }

              if (filteredVehicles.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: EmptyStateWidget(
                    title: 'No se encontraron vehículos',
                    subtitle:
                        'Probá ajustando la búsqueda o quitando los filtros de marca.',
                    buttonText: 'Limpiar filtros',
                    onButtonPressed: _clearFilters,
                  ),
                );
              }

              final car = filteredVehicles[index - 1];

              return VehicleCard(
                key: ValueKey(car.id),
                car: car,
                isFavourite: _isCarFavourite(car.id),
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
          
        ],
      ),
    );
  }
}

class _FilterPills extends StatelessWidget {
  final List<String> brands;
  final String selectedBrand;
  final ValueChanged<String> onBrandSelected;

  const _FilterPills({
  
    required this.brands,
    required this.selectedBrand,
    required this.onBrandSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final brand = brands[index];
          final isSelected = selectedBrand.toLowerCase() == brand.toLowerCase();
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
          color: isSelected ? const Color(0xFF2DD4BF) : const Color(0xFF1B2A3F),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2DD4BF)
                : const Color(0xFF2A3D57),
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
