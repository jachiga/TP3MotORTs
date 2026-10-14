import '../models/visit.dart';
import 'mock_vehicles.dart';

DateTime _inDays(int days, int hour, int minute) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + days, hour, minute);
}

final List<Visit> mockVisits = [
  Visit(id: 'v1', car: mockVehicles[1], dateTime: _inDays(2, 10, 30)),
  Visit(
    id: 'v2',
    car: mockVehicles[0],
    dateTime: _inDays(4, 9, 0),
    status: VisitStatus.confirmed,
  ),
  Visit(id: 'v3', car: mockVehicles[2], dateTime: _inDays(7, 14, 0)),
  Visit(
    id: 'v4',
    car: mockVehicles[4],
    dateTime: _inDays(9, 12, 0),
    status: VisitStatus.cancelled,
  ),
];
