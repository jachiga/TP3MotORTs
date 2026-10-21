import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Inicia sesión verificando que el rol sea de Cliente
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint("🟡 [AuthService] Intentando conectar con Firebase Auth...");

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('No se pudo obtener la información del usuario.');
      }

      debugPrint("🟢 [AuthService] Login exitoso en Auth. UID: ${user.uid}");
      debugPrint("🟡 [AuthService] Verificando rol en la colección 'users'...");

      // Consulta en la colección unificada 'users' (minúscula)
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final role = (userDoc.data()?['role'] ?? userDoc.data()?['rol'] ?? '')
            .toString()
            .toLowerCase();

        debugPrint("🟢 [AuthService] Rol encontrado en Firestore: '$role'");

        if (role != 'client' && role != 'cliente') {
          debugPrint("🔴 [AuthService] Rol no permitido para App Cliente. Cerrando sesión...");
          await signOut();
          throw Exception('Acceso denegado: Esta app es solo para clientes.');
        }
      } else {
        debugPrint("⚠️ [AuthService] El usuario existe en Auth pero no tiene documento en 'users'.");
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint("🔴 [AuthService] Error de Firebase Auth (${e.code}): ${e.message}");
      throw Exception(_handleAuthException(e));
    } catch (e) {
      debugPrint("🔴 [AuthService] Error inesperado: $e");
      rethrow;
    }
  }

  /// Registro de nuevos clientes
  Future<UserCredential> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      debugPrint("🟡 [AuthService] Registrando nuevo cliente en Auth...");

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(fullName);

        debugPrint("🟢 [AuthService] Usuario creado en Auth. Guardando documento en Firestore 'users'...");

        // Guardado estandarizado en 'users'
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'email': email.trim(),
          'role': 'client',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });

        debugPrint("🟢 [AuthService] Documento creado con éxito en 'users'.");
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint("🔴 [AuthService] Error en Registro (${e.code}): ${e.message}");
      throw Exception(_handleAuthException(e));
    }
  }

  Future<void> signOut() async {
    debugPrint("🟡 [AuthService] Cerrando sesión...");
    await _auth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'El correo ya se encuentra registrado.';
      case 'invalid-email':
        return 'El correo ingresado no es válido.';
      case 'weak-password':
        return 'La contraseña es muy débil. Debe tener al menos 8 caracteres.';
      case 'user-not-found':
        return 'No existe una cuenta registrada con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-credential':
        return 'Credenciales inválidas. Revisa el correo y la contraseña.';
      default:
        return e.message ?? 'Ocurrió un error en la autenticación.';
    }
  }
}