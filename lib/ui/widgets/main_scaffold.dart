import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  int _locationToIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/friends')) return 1;
    if (location.startsWith('/chat')) return 2;
    if (location.startsWith('/ticket-screen')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home-screen');
        break;
      case 1:
        context.go('/friends-screen');
        break;
      case 2:
        context.go('/chat-screen');
        break;
      case 3:
        context.go('/ticket-screen');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _locationToIndex(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      drawer: Drawer(
        backgroundColor: AppColors.whiteColor,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Text(
                  'Menu',
                  style: AppTheme.blackTextStyle.copyWith(
                    fontSize: 20,
                    fontWeight: AppTheme.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: AppColors.blackColor),
                title: Text('Configurações', style: AppTheme.blackTextStyle),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.blackColor),
                title: Text('Sair', style: AppTheme.blackTextStyle),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
      body: Builder(
        builder: (innerContext) => child,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Feed',
                selected: currentIndex == 0,
                onTap: () => _onTap(context, 0),
              ),
              _NavItem(
                icon: Icons.people_alt_rounded,
                label: 'Amigos',
                selected: currentIndex == 1,
                onTap: () => _onTap(context, 1),
              ),
              _NavItem(
                icon: Icons.chat_bubble_rounded,
                label: 'Chat',
                selected: currentIndex == 2,
                onTap: () => _onTap(context, 2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Perfil',
                selected: currentIndex == 3,
                onTap: () => _onTap(context, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.purpleColor : AppColors.greyColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.blackTextStyle.copyWith(
                fontSize: 11,
                fontWeight: AppTheme.semiBold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
