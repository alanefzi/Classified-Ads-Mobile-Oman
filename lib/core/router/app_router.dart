import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_state.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/listings/presentation/pages/add_listing_page.dart';
import '../../features/listings/presentation/pages/favorites_page.dart';
import '../../features/listings/presentation/pages/chat_page.dart';
import '../../features/account/presentation/pages/account_page.dart';
import '../../features/home/presentation/pages/faqs_page.dart';

class StoresScreen extends StatelessWidget {
  const StoresScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('المتاجر')));
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('البحث')));
}

const _protectedPaths = ['/add-listing', '/favorites', '/chat'];

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  navigatorKey: _rootNavigatorKey,
  refreshListenable: AuthState.instance,
  redirect: (context, state) {
    final isSplash = state.matchedLocation == '/splash';
    if (isSplash) return null;

    final loggingIn = state.matchedLocation == '/login';
    final isProtected = _protectedPaths.any(
      (path) => state.matchedLocation.startsWith(path),
    );
    final isLoggedIn = AuthState.instance.isLoggedIn;

    if (isProtected && !isLoggedIn) {
      return '/login?redirect=${state.matchedLocation}';
    }

    if (loggingIn && isLoggedIn) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final redirect = state.uri.queryParameters['redirect'];
        return LoginPage(redirectTo: redirect);
      },
    ),
    GoRoute(
      path: '/register',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final redirect = state.uri.queryParameters['redirect'];
        return RegisterPage(redirectTo: redirect);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stores',
              builder: (context, state) => const StoresScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/account',
              builder: (context, state) => const AccountPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/add-listing',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddListingPage(),
    ),
    GoRoute(
      path: '/favorites',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FavoritesPage(),
    ),
    GoRoute(
      path: '/chat',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ChatPage(),
    ),
    GoRoute(
      path: '/faqs',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FaqsPage(),
    ),
  ],
);

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainScreen({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index) {
    if (index == 2) {
      context.push('/add-listing');
      return;
    }
    final actualIndex = index > 2 ? index - 1 : index;
    navigationShell.goBranch(actualIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, Icons.home_outlined, Icons.home, 'الرئيسية', 0),
                _buildNavItem(context, Icons.storefront_outlined, Icons.storefront, 'المتاجر', 1),
                _buildCenterButton(context),
                _buildNavItem(context, Icons.search, Icons.search, 'بحث', 3),
                _buildNavItem(context, Icons.person_outline, Icons.person, 'حسابي', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, IconData activeIcon, String label, int index) {
    final actualIndex = index > 2 ? index - 1 : index;
    final isSelected = navigationShell.currentIndex == actualIndex;
    final color = isSelected ? const Color(0xFF1A2B4A) : Colors.grey;

    return GestureDetector(
      onTap: () => _onTap(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSelected ? activeIcon : icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context, 2),
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Color(0xFF2563EB),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: 24),
            Text(
              'أضف إعلان',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}