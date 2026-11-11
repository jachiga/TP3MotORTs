import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_colors.dart';
import '../shared/models/vehicle.dart';

class FeaturedCarCard extends StatelessWidget {
  final Vehicle car;
  final VoidCallback? onTap;

  const FeaturedCarCard({super.key, required this.car, this.onTap});

  static const double width = 170;
  static const double _photoHeight = 110;

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (car.year > 0) '${car.year}',
      car.formattedKilometers,
    ].join(' • ');

    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: width,
                height: _photoHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _CarPhoto(url: car.imageUrl),
                    const Positioned(top: 8, right: 8, child: _FavoriteBadge()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: DefaultTextStyle(
                  style: const TextStyle(fontFamily: 'Inter'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        car.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.muted,
                        ),
                      ),
                      if (car.price > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${car.formattedPrice} ARS',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.teal,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarPhoto extends StatelessWidget {
  final String url;

  const _CarPhoto({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _PhotoPlaceholder();

    return Image.network(
      url,
      fit: BoxFit.cover,
      cacheWidth:
          (FeaturedCarCard.width * MediaQuery.devicePixelRatioOf(context))
              .round(),
      errorBuilder: (context, error, stackTrace) => const _PhotoPlaceholder(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const _PhotoPlaceholder(),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surface,
      child: Center(
        child: Icon(
          Icons.directions_car_filled,
          size: 40,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

class _FavoriteBadge extends StatelessWidget {
  const _FavoriteBadge();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: AppColors.favoriteOverlay,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          'assets/icons/heart.svg',
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}
