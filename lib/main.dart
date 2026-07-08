import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/app/resources/constant/named_routes.dart';
import 'package:social_media_app/ui/pages/chat_page.dart';
import 'package:social_media_app/ui/pages/friends_page.dart';
import 'package:social_media_app/ui/pages/home_page.dart';
import 'package:social_media_app/ui/pages/profile_page.dart';
import 'package:social_media_app/ui/widgets/main_scaffold.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: NamedRoutes.homeScreen,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: NamedRoutes.homeScreen,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: NamedRoutes.friendsScreen,
          builder: (context, state) => const FriendsPage(),
        ),
        GoRoute(
          path: NamedRoutes.chatScreen,
          builder: (context, state) => const ChatPage(),
        ),
        GoRoute(
          path: NamedRoutes.profileScreen,
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Social Media App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
