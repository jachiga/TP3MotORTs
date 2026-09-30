class Auto {
  final String id;
  final String marca;
  final String modelo;
  final int anio;
  final int kilometros;
  final double precio;
  final String combustible;
  final String transmision;
  final String color;
  final String descripcion;
  final String imagenUrl;

  const Auto({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.kilometros,
    required this.precio,
    required this.combustible,
    required this.transmision,
    required this.color,
    required this.descripcion,
    required this.imagenUrl,
  });

  String get titulo => '$marca $modelo';

  String get precioFormateado => '\$${_separateByThousand(precio.round())}';

  String get kilometrosFormateados => '${_separateByThousand(kilometros)} km';
}

String _separateByThousand(int valor) {
  final digitos = valor.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digitos[i]);
  }

  return valor < 0 ? '-$buffer' : buffer.toString();
}
