import 'vehicle.dart';

enum VisitStatus { pending, confirmed, cancelled }

class Visit {
  final String id;
  final Vehicle car;
  final DateTime dateTime;
  final VisitStatus status;

  const Visit({
    required this.id,
    required this.car,
    required this.dateTime,
    this.status = VisitStatus.pending,
  });

  bool get canBeCancelled => status != VisitStatus.cancelled;

  Visit copyWith({VisitStatus? status}) {
    return Visit(
      id: id,
      car: car,
      dateTime: dateTime,
      status: status ?? this.status,
    );
  }
}
