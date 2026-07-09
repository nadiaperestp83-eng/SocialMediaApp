import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/ui/widgets/settings_bottom_sheet.dart';

class MainScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      drawer: Drawer(
        backgroundColor: AppColors.whiteColor,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Text('Menu',
                    style: AppTheme.blackTextStyle.copyWith(fontSize: 20, fontWeight: AppTheme.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: AppColors.blackColor),
                title: Text('Configurações', style: AppTheme.blackTextStyle),
                onTap: () {
                  Navigator.pop(context);
                  showSettingsBottomSheet(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
      // navigationShell já é internamente um IndexedStack — troca de aba
      // não reconstrói as telas nem perde o scroll.
      body: navigationShell,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          boxShadow: [BoxShadow(color: AppColors.blackColor.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Feed', selected: navigationShell.currentIndex == 0,
                  onTap: () => navigationShell.goBranch(0)),
              _NavItem(icon: Icons.people_alt_rounded, label: 'Amigos', selected: navigationShell.currentIndex == 1,
                  onTap: () => navigationShell.goBranch(1)),
              _NavItem(icon: Icons.chat_bubble_rounded, label: 'Chat', selected: navigationShell.currentIndex == 2,
                  onTap: () => navigationShell.goBranch(2)),
              _NavItem(icon: Icons.person_rounded, label: 'Perfil', selected: navigationShell.currentIndex == 3,
                  onTap: () => navigationShell.goBranch(3)),
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

  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

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
            Text(label, style: AppTheme.blackTextStyle.copyWith(fontSize: 11, fontWeight: AppTheme.semiBold, color: color)),
          ],
        ),
      ),
    );
  }
}
