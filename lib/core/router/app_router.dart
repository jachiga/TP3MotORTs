import '../../features/profile/profile_view.dart';
import '../../features/catalog/catalog_view.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/visits/my_visits_view.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/main_shell.dart';
import '../../services/auth_service.dart';
import '../../features/auth/login_view.dart';

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

const _loginPath = '/';

final _authService = AuthService();

final appRouter = GoRouter(
  refreshListenable: _StreamListenable(_authService.authStateChanges),
  redirect: (context, state) {
    final loggedIn = _authService.currentUser != null;
    final onLogin = state.matchedLocation == _loginPath;

    if (!loggedIn) return onLogin ? null : _loginPath;
    if (onLogin) return '/home';
    return null;
  },
  routes: [
    GoRoute(
      name: 'login',
      path: _loginPath,
      builder: (context, state) => const LoginView(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: HomeScreen.name,
              path: '/home',
              builder: (context, state) =>
                  HomeScreen(
                    userName:
                        state.extra as String? ??
                        _authService.currentUser?.displayName ??
                        '',
                  ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: CatalogView.name,
              path: '/catalog',
              builder: (context, state) => const CatalogView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: FavoritesScreen.name,
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: 'profile',
              path: '/profile',
              builder: (context, state) => const ProfileView(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      name: MyVisitsView.name,
      path: '/visits',
      builder: (context, state) => MyVisitsView(),
    ),
  ],
);

/// Notifica a GoRouter cada vez que cambia el estado de autenticación.
class _StreamListenable extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  _StreamListenable(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}