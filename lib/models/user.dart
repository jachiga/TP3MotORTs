import 'package:cloud_firestore/cloud_firestore.dart';

class User {
final String uid;
final String username;
final String email;
final String role;
final DateTime? createdAt;

User({
required this.uid,
required this.username,
required this.email,
required this.role,
this.createdAt,
});

factory User.fromFirestore(String docId, Map<String, dynamic> data) {
DateTime? parseDate(dynamic val) {
if (val is Timestamp) return val.toDate();
return null;
}

return User(
  uid: docId,
  username: data['username'] ?? data['nombre'] ?? 'Cliente',
  email: data['email'] ?? '',
  role: data['role'] ?? data['rol'] ?? 'client',
  createdAt: parseDate(data['createdAt']),
);


}

Map<String, dynamic> toMap() {
return {
'username': username,
'email': email,
'role': role,
'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
};
}
}