import 'package:flutter/material.dart';

import '../../shared/data/mock_autos.dart';
import '../../shared/widgets/auto_card.dart';
import 'auto_detalle_view.dart';

class CatalogoView extends StatefulWidget {
  const CatalogoView({super.key});

  @override
  State<CatalogoView> createState() => _CatalogoViewState();
}

class _CatalogoViewState extends State<CatalogoView> {
  final Set<String> _favourite = {};

  void _toggleFavourite(String autoId) {
    setState(() {
      if (!_favourite.remove(autoId)) {
        _favourite.add(autoId);
      }
    });
  }

  void _openDetail(int indice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AutoDetalleView(auto: mockAutos[indice]),
      ),
    );
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
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: mockAutos.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SearchBar(),
                const SizedBox(height: 14),
                const _FilterPills(),
                const SizedBox(height: 20),
                Text(
                  '${mockAutos.length} autos disponibles',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            );
          }

          final indiceAuto = index - 1;
          final auto = mockAutos[indiceAuto];

          return VehicleCar(
            car: car,
            isFavourite: _favourite.contains(auto.id),
            onTap: () => _openDetail(indiceAuto),
            onToggleFavourite: () => _toggleFavourite(auto.id),
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

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
            child: Text(
              'Buscar marca o modelo',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF94A3B8),
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
  const _FilterPills();

  static const _filtros = ['Marca', 'Precio', 'Año', 'Ordenar'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filtros.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) => _Pill(texto: _filtros[index]),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String texto;

  const _Pill({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A3F),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF2A3D57)),
      ),
      child: Row(
        children: [
          Text(
            texto,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }
}
