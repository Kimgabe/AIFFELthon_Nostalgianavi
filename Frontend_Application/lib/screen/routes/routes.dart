import 'package:Nostalgianavi/screen/home/HomeScreen.dart';
import 'package:Nostalgianavi/screen/login/LoginScreen.dart';
import 'package:Nostalgianavi/screen/login/SignUpScreen.dart';
import 'package:Nostalgianavi/screen/splash/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/sign_up',
      name: 'sign_up',
      builder: (BuildContext context, GoRouterState state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
    )
  ],
);
