import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/models/visit.dart';
import '../../shared/repositories/visit_repository.dart';
import '../../shared/widgets/vehicle_card.dart' show VehicleImage;
import '../catalog/catalog_view.dart';

class MyVisitsView extends StatefulWidget {
  final VisitRepository repository;

  MyVisitsView({super.key, VisitRepository? repository})
    : repository = repository ?? VisitRepository();

  @override
  State<MyVisitsView> createState() => _MyVisitsViewState();
}

class _MyVisitsViewState extends State<MyVisitsView> {
  // Created once so rebuilds don't open a new Firestore listener.
  late final Stream<List<Visit>> _visits = widget.repository.getClientVisits(
    currentClientId,
  );

  Future<void> _cancelVisit(Visit visit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _CancelVisitDialog(),
    );
    if (confirmed != true || !mounted) return;

    try {
      await widget.repository.cancelVisit(visit.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos cancelar la visita')),
      );
    }
  }

  void _goToCatalog() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const CatalogView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis visitas')),
      body: StreamBuilder<List<Visit>>(
        stream: _visits,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar tus visitas'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final visits = snapshot.data!;

          if (visits.isEmpty) {
            return _EmptyVisits(onExplore: _goToCatalog);
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: visits.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final visit = visits[index];
              return _VisitTile(
                visit: visit,
                onCancel: () => _cancelVisit(visit),
              );
            },
          );
        },
      ),
    );
  }
}

class _VisitTile extends StatelessWidget {
  final Visit visit;
  final VoidCallback onCancel;

  const _VisitTile({required this.visit, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mutedColor = colors.onSurface.withValues(alpha: 0.6);
    final car = visit.car;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 104,
                child: VehicleImage(
                  url: car.imageUrl,
                  height: 76,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${car.year}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: mutedColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _StatusBadge(status: visit.status),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 24, color: theme.dividerColor),
          Row(
            children: [
              Icon(Icons.event, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatDateTime(visit.dateTime),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (visit.canBeCancelled)
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(foregroundColor: colors.error),
                  child: const Text('Cancelar visita'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    final date = DateFormat("EEE d 'de' MMMM", 'es').format(dateTime);
    final time = DateFormat('HH:mm').format(dateTime);
    return '${toBeginningOfSentenceCase(date)} · $time hs';
  }
}

class _StatusBadge extends StatelessWidget {
  final VisitStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      VisitStatus.pending => ('Esperando confirmación', Colors.amber),
      VisitStatus.confirmed => ('Confirmada', colors.primary),
      VisitStatus.cancelled => ('Cancelada', colors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CancelVisitDialog extends StatelessWidget {
  const _CancelVisitDialog();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colors.surface,
      title: const Text('Cancelar visita'),
      content: const Text('¿Seguro que querés cancelar esta visita?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Volver'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: colors.error),
          child: const Text('Sí, cancelar'),
        ),
      ],
    );
  }
}

class _EmptyVisits extends StatelessWidget {
  final VoidCallback onExplore;

  const _EmptyVisits({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 64, color: mutedColor),
            const SizedBox(height: 16),
            Text(
              'Todavía no solicitaste ninguna visita',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elegí un auto del catálogo y pedí una visita para conocerlo.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: mutedColor),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onExplore,
                icon: const Icon(Icons.directions_car),
                label: const Text('Explorar autos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
