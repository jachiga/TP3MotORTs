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

  const Vehicle({
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
  });


   factory Vehicle.fromFirestore(String id, Map<String, dynamic> data) {
    return Vehicle(
      id: id,
      brand: data['brand'] ?? data['marca'] ?? '',
      model: data['model'] ?? data['modelo'] ?? '',
      year: ((data['year'] ?? data['anio'] ?? 0) as num).toInt(),
kilometers: ((data['kilometers'] ?? data['kilometraje'] ?? 0) as num).toInt(),
price: ((data['price'] ?? data['precio'] ?? 0) as num).toDouble(),
      fuel: data['fuel'] ?? data['combustible'] ?? '',
      transmission: data['transmission'] ?? data['transmision'] ?? '',
      color: data['color'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? data['imagenUrl'] ?? '',
    );
  }


  String get title => '$brand $model';

  String get formattedPrice => '\$${_separateByThousand(price.round())}';

  String get formattedKilometers => '${_separateByThousand(kilometers)} km';
}

String _separateByThousand(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }

  return value < 0 ? '-$buffer' : buffer.toString();
}
