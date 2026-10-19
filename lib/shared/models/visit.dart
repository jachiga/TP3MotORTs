import 'package:cloud_firestore/cloud_firestore.dart';

import 'vehicle.dart';

enum VisitStatus { pending, confirmed, cancelled }

class Visit {
  final String id;
  final String clientId;
  final Vehicle car;
  final DateTime dateTime;
  final VisitStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const Visit({
    required this.id,
    required this.clientId,
    required this.car,
    required this.dateTime,
    this.status = VisitStatus.pending,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Visit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Visit(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      car: Vehicle.fromFirestore(
        data['vehicleId'] ?? '',
        Map<String, dynamic>.from(data['vehicle'] ?? const {}),
      ),
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      status: VisitStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => VisitStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      'vehicleId': car.id,
      'vehicle': {
        'brand': car.brand,
        'model': car.model,
        'year': car.year,
        'imageUrl': car.imageUrl,
      },
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status.name,
      'createdAt': _toTimestamp(createdAt),
      'updatedAt': _toTimestamp(updatedAt),
      'deletedAt': _toTimestamp(deletedAt),
    };
  }

  bool get canBeCancelled => status != VisitStatus.cancelled;
}

Timestamp? _toTimestamp(DateTime? date) =>
    date == null ? null : Timestamp.fromDate(date);
