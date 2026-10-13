import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
  final String brand;
  final String model;
  final int year;
  final int kilometers;
  final int price;
  final String fuel;
  final String transmission;
  final String color;
  final String description;
  final String imageUrl;
  final List<String> images;
  final String status;
  final String branch;
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
    required this.images,
    required this.status,
    required this.branch,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Vehicle.fromFirestore(String docId, Map<String, dynamic> data) {
    List<String> imageList = [];
    if (data['imagenes'] != null && data['imagenes'] is List) {
      imageList = List<String>.from(data['imagenes']);
    } else if (data['imagenUrl'] != null && data['imagenUrl'].toString().isNotEmpty) {
      imageList = [data['imagenUrl'].toString()];
    }

    return Vehicle(
      id: docId,
      brand: data['marca'] ?? data['brand'] ?? '',
      model: data['modelo'] ?? data['model'] ?? '',
      year: (data['anio'] ?? data['year'] ?? 0) as int,
      kilometers: (data['kilometros'] ?? data['kilometraje'] ?? 0) as int,
      price: (data['precio'] ?? data['price'] ?? 0) as int,
      fuel: data['combustible'] ?? data['fuel'] ?? '',
      transmission: data['transmision'] ?? data['transmission'] ?? '',
      color: data['color'] ?? '',
      description: data['descripcion'] ?? data['descripción'] ?? data['description'] ?? '',
      imageUrl: imageList.isNotEmpty ? imageList.first : (data['imagenUrl'] ?? ''),
      images: imageList,
      status: data['estado'] ?? 'publicado',
      branch: data['sucursal'] ?? 'Sucursal Central',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  String get title => '$brand $model';
  String get formattedPrice => '\$ $price';
  String get formattedKilometers => '$kilometers km';
  bool get isPublished => status == 'publicado' && deletedAt == null;
}
