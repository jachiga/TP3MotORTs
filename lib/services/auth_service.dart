import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('No se pudo obtener la información del usuario.');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final role = (userDoc.data()?['role'] ?? '').toString().toLowerCase();
        if (role != 'client' && role != 'cliente') {
          await signOut();
          throw Exception('Acceso denegado: Esta app es solo para clientes.');
        }
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  /// Registro de nuevos clientes
  Future<UserCredential> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Crear el usuario en Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Actualizar el nombre en el perfil de Auth
        await user.updateDisplayName(fullName);

        // 2. Guardar el documento del cliente en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'email': email,
          'role': 'client',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  Future<void> signOut() async {
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
      default:
        return e.message ?? 'Ocurrió un error en la autenticación.';
    }
  }
}