import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileView extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileView({
    super.key,
    required this.userData,
  });

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  late String _initialName;
  bool _hasChanges = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Extracción de datos actuales
    _initialName = (widget.userData['fullName'] ??
            widget.userData['name'] ??
            widget.userData['nombre'] ??
            '')
        .toString();
    
    final email = FirebaseAuth.instance.currentUser?.email ??
        (widget.userData['email'] ?? '').toString();

    _nameController = TextEditingController(text: _initialName);
    _emailController = TextEditingController(text: email);

    // Escucha de cambios para habilitar/deshabilitar el botón
    _nameController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final currentName = _nameController.text.trim();
    final changed = currentName != _initialName && currentName.isNotEmpty;

    if (changed != _hasChanges) {
      setState(() {
        _hasChanges = changed;
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkForChanges);
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges || !(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      final newName = _nameController.text.trim();

      // Actualización directa en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': newName,
        'fullName': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Color(0xFF2DD4BF),
          ),
        );
        Navigator.pop(context, true); // Devuelve 'true' para refrescar la pantalla anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgNavy = Color(0xFF0E1826);
    const cardInputBg = Color(0xFF1B2A3F);
    const textMuted = Color(0xFF94A3B8);
    const brandTeal = Color(0xFF00D2A0);
    const borderColor = Color(0xFF2A3D57);

    return Scaffold(
      backgroundColor: bgNavy,
      appBar: AppBar(
        backgroundColor: bgNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NOMBRE COMPLETO
                    _buildFieldLabel('NOMBRE COMPLETO', isRequired: true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                        hintText: 'Ej. Juan Pérez',
                        fillColor: cardInputBg,
                        borderColor: borderColor,
                        activeColor: brandTeal,
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Ingresá tu nombre completo'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // EMAIL (Lectura únicamente)
                    _buildFieldLabel('CORREO ELECTRÓNICO'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      enabled: false,
                      style: const TextStyle(color: textMuted),
                      decoration: _inputDecoration(
                        hintText: 'correo@ejemplo.com',
                        fillColor: cardInputBg.withValues(alpha: 0.5),
                        borderColor: borderColor,
                        activeColor: brandTeal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'El correo electrónico está vinculado a tu cuenta y no se puede modificar desde aquí.',
                      style: TextStyle(color: textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 40),

                    // BOTÓN GUARDAR CAMBIOS (Activo solo si _hasChanges es true)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasChanges ? brandTeal : cardInputBg,
                          foregroundColor: _hasChanges ? bgNavy : textMuted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        onPressed: (_hasChanges && !_isLoading) ? _saveChanges : null,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: bgNavy,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Guardar cambios',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _hasChanges ? bgNavy : textMuted,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    const textMuted = Color(0xFF94A3B8);
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: textMuted,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
        children: [
          TextSpan(text: label),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.redAccent),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required Color fillColor,
    required Color borderColor,
    required Color activeColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF4A5B70)),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: activeColor, width: 1.5),
      ),
    );
  }
}