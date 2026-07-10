import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/core/providers/chat_providers.dart';
import 'package:social_media_app/ui/widgets/custom_floating_nav_bar.dart';

class MainScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Garante que o Realtime do chat e o banco local já estejam prontos
    // assim que o usuário loga, independente da aba em que ele abrir o app.
    ref.watch(chatSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Stack(
        children: [
          // Camada inferior: o conteúdo de cada aba ocupa a tela inteira,
          // rolando por baixo da navbar flutuante.
          navigationShell,

          // Camada superior: navbar flutuante estilo cápsula.
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SafeArea(
              top: false,
              child: CustomFloatingNavBar(
                currentIndex: navigationShell.currentIndex,
                onTap: (index) => navigationShell.goBranch(index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
