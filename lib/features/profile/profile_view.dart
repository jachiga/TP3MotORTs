import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import 'edit_profile_view.dart';


class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  void _navigateToEditProfile(BuildContext context, Map<String, dynamic> userData) async {
    final updated = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) => EditProfileView(userData: userData),
    ),
  );

  if (updated == true && context.mounted) {
    (context as Element).markNeedsBuild();
  }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;    
    
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error al cargar los datos del perfil.', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async => await AuthService().signOut(),
                    child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final fullName = data['name'] ?? data['fullName'] ?? 'Usuario';
        final email = FirebaseAuth.instance.currentUser?.email ?? data['email'] ?? 'Sin correo';
        String initials = 'U';
        if (fullName.toString().trim().isNotEmpty) {
          final parts = fullName.toString().trim().split(' ');
          if (parts.length > 1) {
            initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
          } else {
            initials = parts[0][0].toUpperCase();
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mi Cuenta'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Color(0xFF2DD4BF)),
                tooltip: 'Cerrar sesión',
                onPressed: () async => await AuthService().signOut(),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    // --- BOTÓN / CARD DEL PERFIL DEL USUARIO ---
                    Material(
                      color: Color(0xFF1B2A3F),
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _navigateToEditProfile(context, data),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Color(0xFF2DD4BF),
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fullName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      email,
                                      style: const TextStyle(
                                        color: Color(0xFFA0A0A0),
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFFA0A0A0),
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- SECCIÓN MIS VISITAS ---
                    const Text(
                      'Mis visitas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // STREAMBUILDER DE VISITAS DEL CLIENTE
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('visits')
                          .where('clientId', isEqualTo: currentUser?.uid)
                          .snapshots(),
                      builder: (context, visitSnapshot) {
                        if (visitSnapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
                            ),
                          );
                        }

                        final docs = visitSnapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Color(0xFF1B2A3F),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'No tenés visitas agendadas por el momento.',
                                style: TextStyle(color: Color(0xFFA0A0A0)),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            final vehicle = data['vehicle'] as Map<String, dynamic>? ?? {};

                            final brand = vehicle['brand'] ?? '';
                            final model = vehicle['model'] ?? '';
                            final year = vehicle['year']?.toString() ?? '';
                            final imageUrl = vehicle['imageUrl'] ?? '';
                            final status = (data['status'] ?? 'pending').toString().toLowerCase();

                            // Formateo de fecha y hora
                            String dateStr = 'Sin fecha';
                            if (data['dateTime'] != null && data['dateTime'] is Timestamp) {
                              final dt = (data['dateTime'] as Timestamp).toDate();
                              final day = dt.day.toString().padLeft(2, '0');
                              final month = dt.month.toString().padLeft(2, '0');
                              final hour = dt.hour.toString().padLeft(2, '0');
                              final minute = dt.minute.toString().padLeft(2, '0');
                              dateStr = '$day/$month/${dt.year} – $hour:$minute hs';
                            }

                            return _VisitItemCard(
                              title: '$brand $model'.trim(),
                              year: year,
                              dateStr: dateStr,
                              imageUrl: imageUrl,
                              status: status,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VisitItemCard extends StatelessWidget {
  final String title;
  final String year;
  final String dateStr;
  final String imageUrl;
  final String status;
  const _VisitItemCard({
    required this.title,
    required this.year,
    required this.dateStr,
    required this.imageUrl,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // Configuración visual según el estado (PENDIENTE, REALIZADA, CONFIRMADA, etc.)
    final (statusBg, statusFg, statusText) = switch (status) {
      'realizada' || 'completed' => (
          const Color(0xFF14B8A6),
          const Color(0xFF0E1826),
          'REALIZADA'
        ),
      'confirmed' || 'confirmada' => (
          Color(0xFF2DD4BF),
          Color(0xFF0E1826),
          'CONFIRMADA'
        ),
      'cancelled' || 'cancelada' => (
          Color(0xFFEF4444).withValues(alpha: 0.2),
          Color(0xFFEF4444),
          'CANCELADA'
        ),
      _ => (
          const Color(0xFFF59E0B),
          const Color(0xFF0E1826),
          'PENDIENTE'
        ),
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1B2A3F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // IMAGEN DEL AUTO
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 90,
              height: 65,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          // DETALLES DEL AUTO Y FECHA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isNotEmpty ? title : 'Vehículo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (year.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    year,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        dateStr,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // BADGE DE ESTADO
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusFg,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPlaceholder() {
    return Container(
      color: Color(0xFF0E1826),
      child: const Center(
        child: Icon(
          Icons.directions_car_outlined,
          color: Color(0xFF9CA3AF),
          size: 28,
        ),
      ),
    );
  }
}
