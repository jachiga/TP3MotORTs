
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/vehicle.dart';
import '../../shared/widgets/vehicle_card.dart' show VehicleImage;

class VehicleDetailView extends StatelessWidget {
  final Vehicle car;

  const VehicleDetailView({super.key, required this.car});

  void _scheduleVisit(BuildContext context) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String selectedTime = '10:00';
    bool isSubmitting = false;

    final availableTimes = ['09:00', '10:30', '12:00', '14:30', '16:00', '17:30'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B2A3F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agendar Visita',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vehículo: ${car.title}',
                    style: const TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Seleccioná la fecha:',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E1826),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2A3D57)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today, color: Color(0xFF2DD4BF)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Horarios disponibles:',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableTimes.map((time) {
                      final isSelected = selectedTime == time;
                      return ChoiceChip(
                        label: Text(time),
                        selected: isSelected,
                        selectedColor: const Color(0xFF2DD4BF),
                        backgroundColor: const Color(0xFF0E1826),
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFF0E1826) : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              selectedTime = time;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2DD4BF),
                        foregroundColor: const Color(0xFF0E1826),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setModalState(() => isSubmitting = true);

                              try {
                                await FirebaseFirestore.instance.collection('Visitas').add({
                                  'vehiculoId': car.id,
                                  'tituloVehiculo': car.title,
                                  'imagenVehiculo': car.imageUrl,
                                  'sucursal': car.branch,
                                  'fecha': Timestamp.fromDate(selectedDate),
                                  'hora': selectedTime,
                                  'estado': 'Pendiente',
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                                if (context.mounted) {
                                  Navigator.pop(modalContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('¡Visita agendada para ${car.title} el ${selectedDate.day}/${selectedDate.month} a las $selectedTime hs!'),
                                      backgroundColor: const Color(0xFF2DD4BF),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isSubmitting = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error al agendar visita: $e'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Confirmar Visita',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0E1826),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF0E1826),
            flexibleSpace: FlexibleSpaceBar(
              background: VehicleImage(url: car.imageUrl, height: 300),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${car.year} • ${car.formattedKilometers}',
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
                        car.formattedPrice,
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
                          value: car.formattedKilometers,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SpecTile(
                          icon: Icons.local_gas_station,
                          label: 'Combustible',
                          value: car.fuel,
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
                          value: car.transmission,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SpecTile(
                          icon: Icons.palette_outlined,
                          label: 'Color',
                          value: car.color,
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
                    car.description.trim().isNotEmpty
                        ? car.description
                        : 'Sin descripción cargada en Firebase para este vehículo.',
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
