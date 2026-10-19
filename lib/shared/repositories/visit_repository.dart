import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/vehicle.dart';
import '../models/visit.dart';

const currentClientId = 'user_1';

class VisitRepository {
  final CollectionReference<Map<String, dynamic>> _visits;

  VisitRepository({FirebaseFirestore? firestore})
    : _visits = (firestore ?? FirebaseFirestore.instance).collection('visits');

  Future<void> requestVisit({
    required String clientId,
    required Vehicle car,
    required DateTime dateTime,
  }) {
    final visit = Visit(
      id: '',
      clientId: clientId,
      car: car,
      dateTime: dateTime,
    );

    return _visits.add({
      ...visit.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Visit>> getClientVisits(String clientId) {
    return _visits
        .where('clientId', isEqualTo: clientId)
        .where('deletedAt', isNull: true)
        .snapshots()
        .map((snapshot) {
          final visits = snapshot.docs.map(Visit.fromFirestore).toList();
          visits.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          return visits;
        });
  }

  Future<void> cancelVisit(String visitId) {
    return _visits.doc(visitId).update({
      'status': VisitStatus.cancelled.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
