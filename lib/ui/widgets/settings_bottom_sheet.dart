import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/app/resources/constant/named_routes.dart';
import 'package:social_media_app/core/providers/supabase_providers.dart';

Future<void> showSettingsBottomSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.2),
    builder: (sheetContext) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          decoration: const BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.dashedLineColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              _SettingsGroup(
                items: [
                  _SettingsItem(icon: Icons.person_outline_rounded, label: 'Editar perfil', onTap: () {}),
                  _SettingsItem(icon: Icons.lock_outline_rounded, label: 'Privacidade', onTap: () {}),
                  _SettingsItem(icon: Icons.notifications_outlined, label: 'Notificações', onTap: () {}),
                ],
              ),
              const SizedBox(height: 16),
              _SettingsGroup(
                items: [
                  _SettingsItem(icon: Icons.help_outline_rounded, label: 'Ajuda', onTap: () {}),
                  _SettingsItem(icon: Icons.info_outline_rounded, label: 'Sobre o app', onTap: () {}),
                ],
              ),
              const SizedBox(height: 16),
              _SettingsGroup(
                items: [
                  _SettingsItem(
                    icon: Icons.logout_rounded,
                    label: 'Sair',
                    destructive: true,
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await ref.read(supabaseClientProvider).auth.signOut();
                      if (context.mounted) context.go(NamedRoutes.loginScreen);
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.delete_outline_rounded,
                    label: 'Excluir conta',
                    destructive: true,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      showDeleteAccountDialog(context, ref);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsItem> items;

  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: items
            .map((item) => item)
            .toList(),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.dangerColor : AppColors.blackColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: AppTheme.blackTextStyle.copyWith(
                fontSize: 15,
                fontWeight: AppTheme.medium,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.dangerColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_rounded, color: AppColors.dangerColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Excluir sua conta?',
              style: AppTheme.blackTextStyle.copyWith(fontSize: 18, fontWeight: AppTheme.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Essa ação é permanente. Todos os seus posts, amigos e conversas serão apagados.',
              textAlign: TextAlign.center,
              style: AppTheme.greyTextStyle.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Cancelar', style: AppTheme.blackTextStyle),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      // TODO: chamar Edge Function de exclusão de conta (service role).
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dangerColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Excluir', style: AppTheme.whiteTextStyle.copyWith(fontWeight: AppTheme.semiBold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
