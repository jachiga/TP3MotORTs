import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyVisitsView extends StatelessWidget {
  const MyVisitsView({super.key});

  Future<void> _cancelVisit(BuildContext context, String visitId, String carTitle) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1B2A3F),
        title: const Text('Cancelar Visita', style: TextStyle(color: Colors.white)),
        content: Text('¿Estás seguro de que querés cancelar la visita para $carTitle?',
            style: const TextStyle(color: Color(0xFF94A3B8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No, mantener', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sí, cancelar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('Visitas').doc(visitId).delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visita cancelada correctamente.'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cancelar: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1826),
      appBar: AppBar(
        title: const Text('Mis Visitas Agendadas'),
        backgroundColor: const Color(0xFF0E1826),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Visitas')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar visitas: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.event_busy, size: 64, color: Color(0xFF94A3B8)),
                  SizedBox(height: 16),
                  Text(
                    'No tenés visitas agendadas',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explorá el catálogo y agendá una prueba de manejo.',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final title = data['tituloVehiculo'] ?? 'Vehículo';
              final imageUrl = data['imagenVehiculo'] ?? '';
              final sucursal = data['sucursal'] ?? 'Sucursal Central';
              final hora = data['hora'] ?? '';
              final estado = data['estado'] ?? 'Pendiente';

              DateTime? fecha;
              if (data['fecha'] is Timestamp) {
                fecha = (data['fecha'] as Timestamp).toDate();
              }

              final fechaStr = fecha != null
                  ? '${fecha.day}/${fecha.month}/${fecha.year}'
                  : 'Fecha a confirmar';

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2A3F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A3D57)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                color: const Color(0xFF2A3D57),
                                child: const Icon(Icons.directions_car, color: Colors.white54),
                              ),
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: const Color(0xFF2A3D57),
                              child: const Icon(Icons.directions_car, color: Colors.white54),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Color(0xFF2DD4BF)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  sucursal,
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Color(0xFF2DD4BF)),
                              const SizedBox(width: 4),
                              Text(
                                '$fechaStr - $hora hs',
                                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2DD4BF).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              estado,
                              style: const TextStyle(
                                color: Color(0xFF2DD4BF),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      tooltip: 'Cancelar visita',
                      onPressed: () => _cancelVisit(context, doc.id, title),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
