import 'package:flutter/material.dart';

import '../models/vehicle.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle car;
  final bool isFavourite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  const VehicleCard({
    super.key,
    required this.car,
    required this.isFavourite,
    required this.onTap,
    required this.onToggleFavourite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: const Color(0xFF1B2A3F),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                VehicleImage(
                  url: car.imageUrl,
                  height: 190,
                  borderRadius: BorderRadius.zero,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _FavButton(
                    isFavourite: isFavourite,
                    onPressed: onToggleFavourite,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${car.year} • ${car.formattedKilometers}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    car.formattedPrice,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF2DD4BF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavButton extends StatelessWidget {
  final bool isFavourite;
  final VoidCallback onPressed;

  const _FavButton({required this.isFavourite, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC0E1826),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            isFavourite ? Icons.favorite : Icons.favorite_border,
            size: 22,
            color: isFavourite ? const Color(0xFF2DD4BF) : Colors.white,
          ),
        ),
      ),
    );
  }
}

class VehicleImage extends StatelessWidget {
  final String url;
  final double height;
  final BorderRadius borderRadius;

  const VehicleImage({
    super.key,
    required this.url,
    required this.height,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholder();
        },
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF243450), Color(0xFF16233A)],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.directions_car_filled,
          size: 52,
          color: Color(0xFF41567A),
        ),
      ),
    );
  }
}
