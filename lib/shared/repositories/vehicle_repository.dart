import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/vehicle.dart';

class VehicleRepository {
  final CollectionReference<Map<String, dynamic>> _vehicles;

  VehicleRepository({FirebaseFirestore? firestore})
    : _vehicles = (firestore ?? FirebaseFirestore.instance).collection(
        'Vehiculos',
      );

  Stream<List<Vehicle>> watchFeatured({int limit = 10}) {
    return _vehicles.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Vehicle.fromFirestore(doc.id, doc.data()))
          .where((v) => v.isPublished)
          .take(limit)
          .toList(),
    );
  }
}
