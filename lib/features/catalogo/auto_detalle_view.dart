import 'package:flutter/material.dart';

import '../../shared/models/auto.dart';
import '../../shared/widgets/auto_card.dart' show AutoImagen;

// Detalle de un auto: foto, precio, especificaciones y CTA para agendar.
class CarDetailView extends StatelessWidget {
  final Auto auto;

  const CarDetailView({super.key, required this.auto});

  void _scheduleVisit(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visita para ${auto.titulo} — próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF0E1826),
            flexibleSpace: FlexibleSpaceBar(
              background: AutoImagen(url: auto.imagenUrl, alto: 300),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auto.titulo,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${auto.anio} • ${auto.kilometrosFormateados}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        auto.precioFormateado,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF2DD4BF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ARS',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF2DD4BF).withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Especificaciones',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _SpecTile(
                          icon: Icons.speed,
                          label: 'Kilometraje',
                          value: auto.kilometrosFormateados,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SpecTile(
                          icon: Icons.local_gas_station,
                          label: 'Combustible',
                          value: auto.combustible,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SpecTile(
                          icon: Icons.settings,
                          label: 'Transmisión',
                          value: auto.transmision,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SpecTile(
                          icon: Icons.palette_outlined,
                          label: 'Color',
                          value: auto.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Descripción',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    auto.descripcion,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFCBD5E1),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _scheduleVisit(context),
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Agendar visita'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Celda de la grilla de especificaciones.
class _SpecTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A3F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: const Color(0xFF2DD4BF)),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
