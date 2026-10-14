import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
  final String brand;
  final String model;
  final int year;
  final int kilometers;
  final double price;
  final String fuel;
  final String transmission;
  final String color;
  final String description;
  final String imageUrl;
  final List<String> images;
  final String branch;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.kilometers,
    required this.price,
    required this.fuel,
    required this.transmission,
    required this.color,
    required this.description,
    required this.imageUrl,
    this.images = const [],
    this.branch = 'Sucursal Central',
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Vehicle.fromFirestore(String docId, Map<String, dynamic> data) {
    DateTime? parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return null;
    }

    return Vehicle(
      id: docId,
      brand: data['marca'] ?? data['brand'] ?? 'Sin marca',
      model: data['modelo'] ?? data['model'] ?? 'Sin modelo',
      year: (data['anio'] ?? data['year'] ?? 0) as int,
      kilometers: (data['kilometraje'] ?? data['kilometers'] ?? 0) as int,
      price: (data['precio'] ?? data['price'] ?? 0).toDouble(),
      fuel: data['combustible'] ?? data['fuel'] ?? 'Nafta',
      transmission: data['transmision'] ?? data['transmission'] ?? 'Manual',
      color: data['color'] ?? 'No especificado',
      description: data['descripcion'] ?? data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      branch: data['sucursal'] ?? data['branch'] ?? 'Sucursal Central',
      status: data['status'] ?? 'active',
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
      deletedAt: parseTimestamp(data['deletedAt']),
    );
  }

  // Getters requeridos por la interfaz
  String get title => '$brand $model';
  bool get isDeleted => status == 'deleted' || deletedAt != null;
  bool get isActive => status != 'deleted' && deletedAt == null;
  bool get isPublished => isActive;

  String get formattedPrice {
    final priceInt = price.toInt();
    return '\$${priceInt.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m}.',
        )}';
  }

  String get formattedKilometers {
    return '${kilometers.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m}.',
        )} km';
  }
}
