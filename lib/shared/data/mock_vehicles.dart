import '../models/vehicle.dart';

const List<Vehicle> mockVehicles = [
  Vehicle(
    id: '1',
    brand: 'Toyota',
    model: 'Corolla XEI',
    year: 2021,
    kilometers: 42000,
    price: 24900000,
    fuel: 'Nafta',
    transmission: 'Automática CVT',
    color: 'Gris plata',
    description:
        'Único dueño, service oficial al día y todos los mantenimientos hechos '
        'en concesionaria. Cubiertas nuevas, tapizados impecables y control de '
        'crucero adaptativo. Se entrega con VTV vigente y transferencia incluida.',
    imageUrl:
        'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&q=80&auto=format&fit=crop',
  ),
  Vehicle(
    id: '2',
    brand: 'Volkswagen',
    model: 'Golf GTI',
    year: 2019,
    kilometers: 68500,
    price: 32500000,
    fuel: 'Nafta',
    transmission: 'Automática DSG',
    color: 'Rojo tornado',
    description:
        'GTI 2.0 turbo de 230 CV con paquete de performance. Butacas deportivas, '
        'techo panorámico y sistema de audio premium. Siempre en garage, '
        'sin detalles de chapa ni pintura.',
    imageUrl:
        'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&q=80&auto=format&fit=crop',
  ),
  Vehicle(
    id: '3',
    brand: 'Ford',
    model: 'Ranger Limited',
    year: 2022,
    kilometers: 35200,
    price: 48700000,
    fuel: 'Diésel',
    transmission: 'Automática 10ª',
    color: 'Azul lightning',
    description:
        'Doble cabina 4x4 con motor 3.2 Duratorq. Cobertor de caja, barra '
        'antivuelco y enganche de remolque instalado de fábrica. Ideal para '
        'trabajo y viaje, con servicios en red oficial Ford.',
    imageUrl:
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800&q=80&auto=format&fit=crop',
  ),
  Vehicle(
    id: '4',
    brand: 'Chevrolet',
    model: 'Onix LTZ',
    year: 2023,
    kilometers: 18900,
    price: 21300000,
    fuel: 'Nafta',
    transmission: 'Manual 6ª',
    color: 'Blanco summit',
    description:
        'Prácticamente nuevo, con garantía de fábrica vigente hasta 2027. '
        'Pantalla de 8" con Android Auto y CarPlay, cámara de retroceso y '
        'seis airbags. Consumo real de 6,2 litros cada 100 km.',
    imageUrl:
        'https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=800&q=80&auto=format&fit=crop',
  ),
  Vehicle(
    id: '5',
    brand: 'Renault',
    model: 'Duster Iconic',
    year: 2020,
    kilometers: 79400,
    price: 23800000,
    fuel: 'Nafta',
    transmission: 'Manual 5ª',
    color: 'Gris cassiopée',
    description:
        'SUV 1.6 16v con excelente despeje para ruta y camino de tierra. '
        'Barras de techo, llantas de aleación y climatizador automático. '
        'Distribución cambiada a los 70.000 km con factura.',
    imageUrl:
        'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800&q=80&auto=format&fit=crop',
  ),
  Vehicle(
    id: '6',
    brand: 'Peugeot',
    model: '208 Feline',
    year: 2018,
    kilometers: 94300,
    price: 16400000,
    fuel: 'Nafta',
    transmission: 'Manual 5ª',
    color: 'Negro perla',
    description:
        'Full full, con techo panorámico de vidrio y sensores de estacionamiento. '
        'Motor 1.6 THP con mantenimiento prolijo y aceite sintético cada '
        '8.000 km. Cubiertas al 70 por ciento.',
    imageUrl:
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80&auto=format&fit=crop',
  ),
  Vehicle(
    id: '7',
    brand: 'Honda',
    model: 'Civic EXL',
    year: 2017,
    kilometers: 112600,
    price: 19900000,
    fuel: 'Nafta',
    transmission: 'Automática CVT',
    color: 'Gris modern steel',
    description:
        'Décima generación, la más buscada por confiabilidad. Tapizado de cuero, '
        'asientos eléctricos y sensor de punto ciego LaneWatch. Acaba de recibir '
        'service completo de 110.000 km.',
    imageUrl:
        'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=800&q=80&auto=format&fit=crop',
  ),
  Vehicle(
    id: '8',
    brand: 'Fiat',
    model: 'Cronos Drive',
    year: 2022,
    kilometers: 28700,
    price: 18200000,
    fuel: 'Nafta',
    transmission: 'Manual 5ª',
    color: 'Bronce moka',
    description:
        'Sedán 1.3 Firefly con muy bajo consumo y baúl de 525 litros. '
        'Primer dueño particular, sin uso comercial ni de aplicación. '
        'Se acepta permuta por vehículo de menor valor.',
    imageUrl:
        'https://images.unsplash.com/photo-1541899481282-d8bfe0b1ed37?w=800&q=80&auto=format&fit=crop',
  ),
];
