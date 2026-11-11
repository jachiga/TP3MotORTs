import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // 1. REGISTRO CON EMAIL Y ENVÍO DE CORREO DE VERIFICACIÓN
  // ---------------------------------------------------------------------------
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.sendEmailVerification();
        await user.updateDisplayName(fullName.trim());

        await _firestore.collection('users').doc(user.uid).set({
          'fullName': fullName.trim(),
          'email': email.trim(),
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

  // ---------------------------------------------------------------------------
  // 2. INICIO DE SESIÓN CON EMAIL Y CONTRASEÑA
  // ---------------------------------------------------------------------------
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('No se pudo obtener la información del usuario.');
      }

      await user.reload();
      final updatedUser = _auth.currentUser;

      if (updatedUser != null && !updatedUser.emailVerified) {
        await updatedUser.sendEmailVerification();
        await signOut();
        throw Exception(
          'Tu correo electrónico no ha sido verificado. Te reenviamos un enlace de confirmación a $email.',
        );
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await signOut();
        throw Exception('No se encontró el registro del usuario en la base de datos.');
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // ---------------------------------------------------------------------------
  // 3. CIERRE DE SESIÓN
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'Email o contraseña incorrectos.';
      case 'user-not-found':
        return 'No existe una cuenta registrada con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta vinculada a este correo electrónico.';
      case 'invalid-email':
        return 'El formato de correo no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      default:
        return 'Error de autenticación: ${e.message ?? e.code}';
    }
  }
}