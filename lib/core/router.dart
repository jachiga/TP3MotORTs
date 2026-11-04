import '../screens/account_screen.dart';
import '../screens/catalog_view.dart';
import '../screens/favorites_screen.dart';
import '../screens/my_visits_view.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_shell.dart';

import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      name: LoginScreen.name,
      path: '/',
      builder: (context, state) => const LoginScreen(),
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
                  HomeScreen(userName: state.extra as String? ?? ''),
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
              name: AccountScreen.name,
              path: '/account',
              builder: (context, state) => const AccountScreen(),
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
