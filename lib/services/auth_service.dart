import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as app_models;

class AuthException implements Exception {
final String message;
AuthException(this.message);

@override
String toString() => message;
}

class AuthService {
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

User? get currentUser => _auth.currentUser;

Stream<User?> get authStateChanges => _auth.authStateChanges();

/// Inicia sesión verificando que el usuario tenga rol de 'client' o 'cliente' en Firestore
Future signInWithEmailAndPassword({
required String email,
required String password,
}) async {
try {
final UserCredential credential = await _auth.signInWithEmailAndPassword(
email: email.trim(),
password: password,
);

  final User? user = credential.user;
  if (user == null) {
    throw AuthException('No se pudo obtener el usuario de Firebase Auth.');
  }

  // Validar rol en Firestore (colección 'users' o 'Usuarios')
  DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();

  if (!userDoc.exists) {
    // Fallback por si la colección se llama 'Usuarios'
    userDoc = await _firestore.collection('Usuarios').doc(user.uid).get();
  }

  if (!userDoc.exists) {
    await _auth.signOut();
    throw AuthException('El usuario no existe en la base de datos.');
  }

  final data = userDoc.data() as Map<String, dynamic>?;
  final String role = (data?['role'] ?? data?['rol'] ?? '').toString().toLowerCase();

  if (role != 'client' && role != 'cliente') {
    await _auth.signOut();
    throw AuthException(
      'Acceso denegado: Esta app es exclusiva para clientes.',
    );
  }

  return credential;
} on FirebaseAuthException catch (e) {
  throw AuthException(_handleFirebaseAuthError(e.code));
} on AuthException {
  rethrow;
} catch (e) {
  throw AuthException('Error al iniciar sesión: ${e.toString()}');
}


}

/// Obtiene los datos del modelo app_models.User desde Firestore
Future<app_models.User?> getUserProfile(String uid) async {
try {
DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
if (!doc.exists) {
doc = await _firestore.collection('Usuarios').doc(uid).get();
}
if (doc.exists && doc.data() != null) {
return app_models.User.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
}
} catch (_) {}
return null;
}

Future signOut() async {
await _auth.signOut();
}

String _handleFirebaseAuthError(String code) {
switch (code) {
case 'user-not-found':
case 'wrong-password':
case 'invalid-credential':
return 'Email o contraseña incorrectos.';
case 'invalid-email':
return 'El formato del email no es válido.';
case 'user-disabled':
return 'Esta cuenta ha sido deshabilitada.';
case 'too-many-requests':
return 'Demasiados intentos fallidos. Intente más tarde.';
default:
return 'Error de autenticación ($code).';
}
}
}