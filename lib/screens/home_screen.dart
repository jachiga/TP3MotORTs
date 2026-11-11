import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_colors.dart';
import '../shared/models/vehicle.dart';
import '../shared/repositories/vehicle_repository.dart';
import '../widgets/catalog_banner.dart';
import '../widgets/featured_car_card.dart';
import 'vehicle_detail_view.dart';

class HomeScreen extends StatefulWidget {
  static const String name = 'home';
  final String userName;
  final Stream<List<Vehicle>>? featuredCars;

  const HomeScreen({super.key, this.userName = '', this.featuredCars});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _catalogBranchIndex = 1;

  late final Stream<List<Vehicle>> _featuredCars;

  @override
  void initState() {
    super.initState();
    _featuredCars =
        widget.featuredCars ??
        (Firebase.apps.isEmpty
            ? Stream.error(StateError('Firebase no inicializado'))
            : VehicleRepository().watchFeatured());
  }

  void _goToCatalog() {
    StatefulNavigationShell.maybeOf(context)?.goBranch(_catalogBranchIndex);
  }

  void _openDetail(Vehicle car) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => VehicleDetailView(car: car)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.userName;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
          child: ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  userName.isEmpty ? 'Hola' : 'Hola, $userName',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Autos destacados',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Semantics(
                          button: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _goToCatalog,
                            child: const Text(
                              'Ver todos',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.teal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: StreamBuilder<List<Vehicle>>(
                      stream: _featuredCars,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const _CarouselMessage(
                            'No se pudieron cargar los autos.',
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.teal,
                              ),
                            ),
                          );
                        }

                        final cars = snapshot.data ?? const <Vehicle>[];
                        if (cars.isEmpty) {
                          return const _CarouselMessage(
                            'Todavía no hay autos publicados.',
                          );
                        }

                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                          itemCount: cars.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final car = cars[index];
                            return FeaturedCarCard(
                              key: ValueKey(car.id),
                              car: car,
                              onTap: () => _openDetail(car),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CatalogBanner(onTap: _goToCatalog),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarouselMessage extends StatelessWidget {
  final String text;

  const _CarouselMessage(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.muted,
        ),
      ),
    );
  }
}
