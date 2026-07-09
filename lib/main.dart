import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/app/resources/constant/named_routes.dart';
import 'package:social_media_app/core/config/supabase_config.dart';
import 'package:social_media_app/ui/pages/chat_conversation_page.dart';
import 'package:social_media_app/ui/pages/chat_page.dart';
import 'package:social_media_app/ui/pages/forgot_password_page.dart';
import 'package:social_media_app/ui/pages/friends_page.dart';
import 'package:social_media_app/ui/pages/home_page.dart';
import 'package:social_media_app/ui/pages/login_page.dart';
import 'package:social_media_app/ui/pages/profile_page.dart';
import 'package:social_media_app/ui/pages/reset_password_page.dart';
import 'package:social_media_app/ui/pages/signup_page.dart';
import 'package:social_media_app/ui/widgets/main_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(url: SupabaseConfig.url, anonKey: SupabaseConfig.anonKey);
  runApp(const ProviderScope(child: MyApp()));
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: NamedRoutes.loginScreen,
  routes: [
    GoRoute(path: NamedRoutes.loginScreen, builder: (context, state) => const LoginPage()),
    GoRoute(path: NamedRoutes.signUpScreen, builder: (context, state) => const SignUpPage()),
    GoRoute(path: NamedRoutes.forgotPasswordScreen, builder: (context, state) => const ForgotPasswordPage()),
    GoRoute(
      path: NamedRoutes.resetPasswordScreen,
      builder: (context, state) => ResetPasswordPage(email: state.uri.queryParameters['email'] ?? ''),
    ),
    GoRoute(
      path: NamedRoutes.chatConversationScreen,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ChatConversationPage(
        otherUserId: state.uri.queryParameters['userId'] ?? '',
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: NamedRoutes.homeScreen, builder: (context, state) => const HomePage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: NamedRoutes.friendsScreen, builder: (context, state) => const FriendsPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: NamedRoutes.chatScreen, builder: (context, state) => const ChatPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: NamedRoutes.profileScreen, builder: (context, state) => const ProfilePage()),
        ]),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
