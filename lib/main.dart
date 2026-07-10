import 'dart:async';

import 'package:flutter/material.dart';
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

  if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
    runApp(const _MissingConfigApp());
    return;
  }

  await Supabase.initialize(url: SupabaseConfig.url, anonKey: SupabaseConfig.anonKey);
  runApp(const ProviderScope(child: MyApp()));
}

class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Build sem as credenciais do Supabase.\n\n'
              'Confirme os Secrets SUPABASE_URL e SUPABASE_ANON_KEY no GitHub '
              'e rode o workflow novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}

/// Faz o GoRouter reavaliar as rotas sempre que o estado de autenticação
/// do Supabase mudar (login, logout, refresh de sessão).
class _AuthRefreshListenable extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  _AuthRefreshListenable(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

const _publicRoutes = {
  NamedRoutes.loginScreen,
  NamedRoutes.signUpScreen,
  NamedRoutes.forgotPasswordScreen,
  NamedRoutes.resetPasswordScreen,
};

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: NamedRoutes.loginScreen,
  refreshListenable: _AuthRefreshListenable(Supabase.instance.client.auth.onAuthStateChange),
  redirect: (context, state) {
    final loggedIn = Supabase.instance.client.auth.currentSession != null;
    final onPublicRoute = _publicRoutes.contains(state.matchedLocation);

    if (!loggedIn && !onPublicRoute) return NamedRoutes.loginScreen;
    if (loggedIn && onPublicRoute) return NamedRoutes.homeScreen;
    return null;
  },
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
