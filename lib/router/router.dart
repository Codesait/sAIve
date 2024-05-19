import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saive/features/mobile/auth/login.dart';
import 'package:saive/features/mobile/auth/user_auth.dart';
import 'package:saive/features/mobile/home/home.dart';
import 'package:saive/features/mobile/intro/splash_screen.dart';
import 'package:saive/features/mobile/settings/settings.dart';
import 'package:saive/features/web/dash/dashboard.dart';
import 'package:saive/features/web/into/web_splash.dart';
import 'package:saive/router/route_names.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    observers: [BotToastNavigatorObserver()],
    initialLocation: '/',
    errorBuilder: (context, state) => const SizedBox(
      child: Text('Error'),
    ),
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: NamedRoutes.splash.name,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen(
            key: Key('splash-screen-route'),
          );
        },
      ),
      GoRoute(
        path: '/login',
        name: NamedRoutes.signIn.name,
        builder: (BuildContext context, GoRouterState state) {
          return const IntroScreen(
            key: Key('login-screen-route'),
          );
        },
      ),
      GoRoute(
        path: '/auth',
        name: NamedRoutes.userAuth.name,
        builder: (BuildContext context, GoRouterState state) {
          return const UserAuth(
            key: Key('auth-screen-route'),
          );
        },
      ),
      GoRoute(
        path: '/home',
        name: NamedRoutes.homePage.name,
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage(
            key: Key('home-screen-route'),
          );
        },
      ),
        GoRoute(
        path: '/settings',
        name: NamedRoutes.settings.name,
        builder: (BuildContext context, GoRouterState state) {
          return const Settings(
            key: Key('settings-screen-route'),
          );
        },
      ),
    ],
  );
}

class WebAppRouter {
  static final GoRouter router = GoRouter(
    observers: [BotToastNavigatorObserver()],
    initialLocation: '/',
    errorBuilder: (context, state) => const SizedBox(
      child: Text('Error'),
    ),
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: NamedRoutes.splash.name,
        builder: (BuildContext context, GoRouterState state) {
          return const WebSplash(
            key: Key('splash-screen-route'),
          );
        },
      ),
      // GoRoute(
      //   path: '/login',
      //   name: NamedRoutes.signIn.name,
      //   builder: (BuildContext context, GoRouterState state) {
      //     return const IntroScreen(
      //       key: Key('login-screen-route'),
      //     );
      //   },
      // ),
      // GoRoute(
      //   path: '/auth',
      //   name: NamedRoutes.userAuth.name,
      //   builder: (BuildContext context, GoRouterState state) {
      //     return const UserAuth(
      //       key: Key('auth-screen-route'),
      //     );
      //   },
      // ),
      
      GoRoute(
        path: '/dash',
        name: NamedRoutes.dashboard.name,
        builder: (BuildContext context, GoRouterState state) {
          return const Dashboard(
            key: Key('dash-screen-route'),
          );
        },
      ),
    ],
  );
}
